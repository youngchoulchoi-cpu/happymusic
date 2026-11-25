// 해피뮤직 PC (Windows) — 휴대폰 앱과 같은 화면(index.html)을 로컬 서버로 띄우고,
// 안드로이드 브리지(window.Android)와 같은 기능을 HTTP로 제공한다.
package main

import (
	"crypto/rand"
	_ "embed"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"log"
	"mime"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"
)

const (
	AppVersion  = "1.2"
	Port        = 47831
	RepoPrefix  = "https://raw.githubusercontent.com/youngchoulchoi-cpu/happymusic/"
	RepoPrefix2 = "https://github.com/youngchoulchoi-cpu/happymusic/"
)

// 받은 업데이트 파일이 정말 새 버전인지 확인하는 표시 (exe 안에 그대로 남는다)
const versionMarker = "HM-APP-VERSION:" + AppVersion + ";"

//go:embed web/index.html
var embeddedIndex string

//go:embed web/pc.js
var shimJS string

//go:embed web/icon.png
var iconPNG []byte

var (
	dataDir  string
	token    string
	addr     = fmt.Sprintf("127.0.0.1:%d", Port)
	mu       sync.Mutex
	lastPing time.Time
	pinged   bool
	opened   []string
	dl       = struct {
		sync.Mutex
		state      string // none, run, ok, fail
		got, total int64
	}{state: "none"}
	browserDone = make(chan struct{})
	browserOn   bool
	quitCh      = make(chan struct{}, 1)
)

var audioExt = map[string]bool{".mp3": true, ".m4a": true, ".aac": true, ".flac": true, ".wav": true, ".ogg": true, ".oga": true, ".opus": true, ".weba": true, ".mp4a": true}

func main() {
	args := os.Args[1:]
	if handled := platformPreflight(args); handled {
		return
	}
	dataDir = appDataDir()
	os.MkdirAll(dataDir, 0o755)
	logf, _ := os.OpenFile(filepath.Join(dataDir, "log.txt"), os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0o644)
	if logf != nil {
		log.SetOutput(logf)
	}
	noOpen, wait := false, false
	var fileArg string
	for _, a := range args {
		if a == "--noopen" {
			noOpen = true
		} else if a == "--wait" {
			wait = true
		} else if !strings.HasPrefix(a, "--") {
			fileArg = a
		}
	}
	cleanupOld()

	ln, err := listenRetry(noOpen || wait)
	if err != nil {
		// 이미 실행 중 → 그 앱에 파일을 넘기거나 창을 다시 연다
		age, ok := helloAge()
		if ok {
			if fileArg != "" {
				postOpen(fileArg)
			}
			allowFocus()
			if !apiPost("/api/focus", "") && (fileArg == "" || age > 10) {
				openWindow(false)
			}
			return
		}
		fatal("해피뮤직을 시작할 수 없어요.\n다른 프로그램이 포트 " + strconv.Itoa(Port) + "을(를) 쓰고 있어요.")
		return
	}
	token = newToken()
	os.WriteFile(filepath.Join(dataDir, "token"), []byte(token), 0o600)
	bootCheck()
	if fileArg != "" {
		opened = append(opened, fileArg)
	}
	srv := &http.Server{Handler: guard(routes()), ReadHeaderTimeout: 10 * time.Second}
	go srv.Serve(ln)
	log.Printf("HappyMusic PC %s on %s data=%s (%s)", AppVersion, addr, dataDir, versionMarker)
	if !noOpen && os.Getenv("HM_NOBROWSER") == "" {
		openWindow(true)
	}
	lifecycle()
	ln.Close()
}

func listenRetry(wait bool) (net.Listener, error) {
	var ln net.Listener
	var err error
	tries := 1
	if wait {
		tries = 40
	}
	for i := 0; i < tries; i++ {
		ln, err = net.Listen("tcp", addr)
		if err == nil {
			return ln, nil
		}
		time.Sleep(250 * time.Millisecond)
	}
	return nil, err
}

// 창(WebView2)이 있으면 창을 닫고, 없으면 서버만 끝낸다
func requestQuit() {
	uiQuit()
	select {
	case quitCh <- struct{}{}:
	default:
	}
}

func newToken() string { b := make([]byte, 16); rand.Read(b); return hex.EncodeToString(b) }

// 화면이 연결을 끊으면(창을 닫으면) 프로그램도 끝낸다
func lifecycle() {
	start := time.Now()
	tk := time.NewTicker(2 * time.Second)
	defer tk.Stop()
	for {
		select {
		case <-quitCh:
			return
		case <-tk.C:
		}
		mu.Lock()
		lp, p := lastPing, pinged
		mu.Unlock()
		if os.Getenv("HM_STAY") != "" {
			continue
		}
		bDone := false
		select {
		case <-browserDone:
			bDone = true
		default:
		}
		if browserOn && bDone && time.Since(lp) > 12*time.Second && time.Since(start) > 8*time.Second {
			log.Print("browser closed → exit")
			return
		}
		if p && time.Since(lp) > 6*time.Minute {
			log.Print("no ping → exit")
			return
		}
		if !p && time.Since(start) > 3*time.Minute {
			log.Print("never connected → exit")
			return
		}
	}
}

// 다른 웹사이트가 이 서버를 건드리지 못하게: Host 검사 + API 토큰
func guard(h http.Handler) http.Handler {
	okHost := map[string]bool{addr: true, fmt.Sprintf("localhost:%d", Port): true}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !okHost[r.Host] {
			http.Error(w, "forbidden", 403)
			return
		}
		if strings.HasPrefix(r.URL.Path, "/api/") && r.URL.Path != "/api/hello" && r.Header.Get("X-HM-Token") != token {
			http.Error(w, "forbidden", 403)
			return
		}
		w.Header().Set("X-Content-Type-Options", "nosniff")
		h.ServeHTTP(w, r)
	})
}

var verRe = regexp.MustCompile(`const WEB_VERSION='([^']+)'`)

func webVer(h string) string {
	m := verRe.FindStringSubmatch(h)
	if m == nil {
		return ""
	}
	return m[1]
}

func vcmp(a, b string) int {
	x, y := strings.Split(strings.TrimPrefix(a, "v"), "."), strings.Split(strings.TrimPrefix(b, "v"), ".")
	for i := 0; i < len(x) || i < len(y); i++ {
		var p, q int
		if i < len(x) {
			p, _ = strconv.Atoi(x[i])
		}
		if i < len(y) {
			q, _ = strconv.Atoi(y[i])
		}
		if p != q {
			if p < q {
				return -1
			}
			return 1
		}
	}
	return 0
}

// 받은 화면이 내장 화면보다 새것일 때만 쓴다
func currentIndex() string {
	b, err := os.ReadFile(filepath.Join(dataDir, "web_index.html"))
	if err == nil && len(b) > 20000 && vcmp(webVer(string(b)), webVer(embeddedIndex)) > 0 {
		return string(b)
	}
	return embeddedIndex
}

func bootCheck() {
	flag := filepath.Join(dataDir, "booting")
	if _, err := os.Stat(flag); err == nil {
		log.Print("last boot did not finish → reset web")
		os.Remove(filepath.Join(dataDir, "web_index.html"))
	}
	os.WriteFile(flag, []byte("1"), 0o644)
}

func routes() *http.ServeMux {
	m := http.NewServeMux()
	m.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" && r.URL.Path != "/index.html" {
			http.NotFound(w, r)
			return
		}
		h := currentIndex()
		shim := "<script>window.__HM_TOKEN=" + strconv.Quote(token) + ";</script><script>" + shimJS + "</script>"
		if i := strings.Index(h, "<head>"); i >= 0 {
			h = h[:i+6] + shim + h[i+6:]
		} else {
			h = shim + h
		}
		h = strings.Replace(h, `<link rel="icon" href="data:,">`, `<link rel="icon" type="image/png" href="/icon.png">`, 1)
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Header().Set("Cache-Control", "no-store")
		io.WriteString(w, h)
	})
	m.HandleFunc("/icon.png", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "image/png")
		w.Write(iconPNG)
	})
	m.HandleFunc("/favicon.ico", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "image/png")
		w.Write(iconPNG)
	})
	m.HandleFunc("/c", serveAudio)
	m.HandleFunc("/art", serveArt)
	m.HandleFunc("/api/hello", func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		age := int(time.Since(lastPing).Seconds())
		if !pinged {
			age = 9999
		}
		mu.Unlock()
		fmt.Fprintf(w, "happymusic %d", age)
	})
	m.HandleFunc("/api/version", func(w http.ResponseWriter, r *http.Request) { io.WriteString(w, AppVersion) })
	m.HandleFunc("/api/ping", func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		lastPing, pinged = time.Now(), true
		n := len(opened)
		mu.Unlock()
		if n > 0 {
			io.WriteString(w, "open")
			return
		}
		io.WriteString(w, "ok")
	})
	m.HandleFunc("/api/open", func(w http.ResponseWriter, r *http.Request) {
		b, _ := io.ReadAll(io.LimitReader(r.Body, 8192))
		if p := strings.TrimSpace(string(b)); p != "" {
			mu.Lock()
			opened = append(opened, p)
			mu.Unlock()
		}
		io.WriteString(w, "ok")
	})
	m.HandleFunc("/api/opened", func(w http.ResponseWriter, r *http.Request) {
		mu.Lock()
		defer mu.Unlock()
		if len(opened) == 0 {
			return
		}
		p := opened[0]
		opened = opened[1:]
		j, _ := json.Marshal(map[string]string{"u": fileURI(p), "n": filepath.Base(p)})
		w.Write(j)
	})
	m.HandleFunc("/api/deepscan", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		j, _ := json.Marshal(deepScan())
		w.Write(j)
	})
	m.HandleFunc("/api/meta", func(w http.ResponseWriter, r *http.Request) {
		p := r.URL.Query().Get("p")
		w.Header().Set("Content-Type", "application/json")
		if !audioPath(p) {
			io.WriteString(w, "{}")
			return
		}
		j, _ := json.Marshal(readMeta(p))
		w.Write(j)
	})
	m.HandleFunc("/api/saveweb", func(w http.ResponseWriter, r *http.Request) {
		b, err := io.ReadAll(io.LimitReader(r.Body, 8<<20))
		if err != nil || len(b) < 20000 || !strings.Contains(string(b), "window.__ready") || webVer(string(b)) == "" {
			io.WriteString(w, "no")
			return
		}
		tmp := filepath.Join(dataDir, "web_tmp.html")
		if os.WriteFile(tmp, b, 0o644) != nil || os.Rename(tmp, filepath.Join(dataDir, "web_index.html")) != nil {
			io.WriteString(w, "no")
			return
		}
		log.Printf("saved web %s", webVer(string(b)))
		io.WriteString(w, "ok")
	})
	m.HandleFunc("/api/resetweb", func(w http.ResponseWriter, r *http.Request) {
		os.Remove(filepath.Join(dataDir, "web_index.html"))
		io.WriteString(w, "ok")
	})
	m.HandleFunc("/api/bootok", func(w http.ResponseWriter, r *http.Request) {
		os.Remove(filepath.Join(dataDir, "booting"))
		io.WriteString(w, "ok")
	})
	m.HandleFunc("/api/download", func(w http.ResponseWriter, r *http.Request) {
		b, _ := io.ReadAll(io.LimitReader(r.Body, 4096))
		u := strings.TrimSpace(string(b))
		tp := os.Getenv("HM_TEST_PREFIX")
		if !strings.HasPrefix(u, RepoPrefix) && !strings.HasPrefix(u, RepoPrefix2) && (tp == "" || !strings.HasPrefix(u, tp)) {
			io.WriteString(w, "0")
			return
		}
		go download(u)
		io.WriteString(w, "1")
	})
	m.HandleFunc("/api/dlstatus", func(w http.ResponseWriter, r *http.Request) {
		dl.Lock()
		defer dl.Unlock()
		code := map[string]string{"run": "2", "ok": "8", "fail": "16"}[dl.state]
		if code == "" {
			io.WriteString(w, "none")
			return
		}
		fmt.Fprintf(w, "%s,%d,%d", code, dl.got, dl.total)
	})
	m.HandleFunc("/api/install", func(w http.ResponseWriter, r *http.Request) {
		dl.Lock()
		st := dl.state
		dl.Unlock()
		if st != "ok" {
			io.WriteString(w, "no")
			return
		}
		if err := installUpdate(filepath.Join(dataDir, "update.exe")); err != nil {
			log.Print("install: ", err)
			io.WriteString(w, "no")
			return
		}
		io.WriteString(w, "ok")
		go func() { time.Sleep(400 * time.Millisecond); requestQuit() }()
	})
	m.HandleFunc("/api/quit", func(w http.ResponseWriter, r *http.Request) {
		io.WriteString(w, "ok")
		go func() { time.Sleep(200 * time.Millisecond); requestQuit() }()
	})
	m.HandleFunc("/api/focus", func(w http.ResponseWriter, r *http.Request) {
		if !uiFocus() {
			http.Error(w, "no window", 409)
			return
		}
		io.WriteString(w, "ok")
	})
	m.HandleFunc("/api/bars", func(w http.ResponseWriter, r *http.Request) {
		b, _ := io.ReadAll(io.LimitReader(r.Body, 64))
		p := strings.SplitN(string(b), "|", 2)
		col := ""
		if len(p) == 2 {
			col = p[1]
		}
		uiTitleBar(p[0] == "1", col)
		io.WriteString(w, "ok")
	})
	m.HandleFunc("/api/title", func(w http.ResponseWriter, r *http.Request) {
		b, _ := io.ReadAll(io.LimitReader(r.Body, 512))
		uiTitle(strings.TrimSpace(string(b)))
		io.WriteString(w, "ok")
	})
	return m
}

func fileURI(p string) string {
	p = filepath.ToSlash(p)
	segs := strings.Split(p, "/")
	for i, s := range segs {
		segs[i] = url.PathEscape(s)
	}
	j := strings.Join(segs, "/")
	if !strings.HasPrefix(j, "/") {
		j = "/" + j
	}
	return "file://" + j
}

// file:///C%3A/Users/... 또는 file:///home/... → 실제 경로
func uriPath(u string) string {
	if !strings.HasPrefix(u, "file://") {
		return ""
	}
	rest := strings.TrimPrefix(u, "file://")
	segs := strings.Split(rest, "/")
	for i, s := range segs {
		d, err := url.PathUnescape(s)
		if err != nil {
			return ""
		}
		segs[i] = d
	}
	p := strings.Join(segs, "/")
	if len(p) >= 3 && p[0] == '/' && p[2] == ':' { // /C:/...
		p = p[1:]
	}
	return filepath.FromSlash(p)
}

func audioPath(p string) bool {
	if p == "" || strings.Contains(p, "\x00") {
		return false
	}
	return audioExt[strings.ToLower(filepath.Ext(p))]
}

func serveAudio(w http.ResponseWriter, r *http.Request) {
	p := uriPath(r.URL.Query().Get("u"))
	if !audioPath(p) {
		http.NotFound(w, r)
		return
	}
	f, err := os.Open(p)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	defer f.Close()
	st, err := f.Stat()
	if err != nil || st.IsDir() {
		http.NotFound(w, r)
		return
	}
	ct := mime.TypeByExtension(strings.ToLower(filepath.Ext(p)))
	if ct == "" || strings.HasPrefix(ct, "video/") {
		ct = map[string]string{".m4a": "audio/mp4", ".mp4a": "audio/mp4", ".flac": "audio/flac", ".opus": "audio/ogg", ".oga": "audio/ogg", ".weba": "audio/webm"}[strings.ToLower(filepath.Ext(p))]
	}
	if ct == "" {
		ct = "audio/mpeg"
	}
	w.Header().Set("Content-Type", ct)
	if mx, err := strconv.ParseInt(r.URL.Query().Get("max"), 10, 64); err == nil && mx > 0 && mx < st.Size() {
		w.Header().Set("Content-Length", strconv.FormatInt(mx, 10))
		io.CopyN(w, f, mx)
		return
	}
	http.ServeContent(w, r, "", st.ModTime(), f)
}

func serveArt(w http.ResponseWriter, r *http.Request) {
	p := uriPath(r.URL.Query().Get("u"))
	if !audioPath(p) {
		http.NotFound(w, r)
		return
	}
	img, ct := readArt(p)
	if img == nil {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", ct)
	w.Header().Set("Cache-Control", "max-age=86400")
	w.Write(img)
}

type scanItem struct {
	P string `json:"p"`
	M int64  `json:"m"`
}

var skipDir = map[string]bool{"appdata": true, "windows": true, "program files": true, "program files (x86)": true, "programdata": true,
	"node_modules": true, "system volume information": true, "$recycle.bin": true, "recovery": true, "msocache": true, "perflogs": true, "intel": true, "amd": true, "nvidia": true}

// 모든 폴더 검색 (휴대폰의 '모든 폴더에서 찾기'와 같은 역할)
func deepScan() []scanItem {
	out := []scanItem{}
	seen := map[string]bool{}
	deadline := time.Now().Add(90 * time.Second)
	for _, root := range scanRoots() {
		if time.Now().After(deadline) || len(out) >= 30000 {
			break
		}
		base := strings.Count(filepath.Clean(root), string(os.PathSeparator))
		filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
			if err != nil {
				if d != nil && d.IsDir() {
					return fs.SkipDir
				}
				return nil
			}
			if time.Now().After(deadline) || len(out) >= 30000 {
				return fs.SkipAll
			}
			name := d.Name()
			if d.IsDir() {
				if p != root && (strings.HasPrefix(name, ".") || strings.HasPrefix(name, "$") || skipDir[strings.ToLower(name)] ||
					strings.Count(filepath.Clean(p), string(os.PathSeparator))-base > 14) {
					return fs.SkipDir
				}
				return nil
			}
			if d.Type()&fs.ModeSymlink != 0 || !audioExt[strings.ToLower(filepath.Ext(name))] {
				return nil
			}
			key := strings.ToLower(p)
			if seen[key] {
				return nil
			}
			info, err := d.Info()
			if err != nil || info.Size() < 16*1024 {
				return nil
			}
			seen[key] = true
			out = append(out, scanItem{P: filepath.ToSlash(p), M: info.ModTime().UnixMilli()})
			return nil
		})
	}
	sort.Slice(out, func(i, j int) bool { return out[i].M > out[j].M })
	return out
}

func download(u string) {
	dl.Lock()
	if dl.state == "run" {
		dl.Unlock()
		return
	}
	dl.state, dl.got, dl.total = "run", 0, 0
	dl.Unlock()
	fail := func(e error) {
		log.Print("download: ", e)
		dl.Lock()
		dl.state = "fail"
		dl.Unlock()
	}
	c := &http.Client{Timeout: 10 * time.Minute}
	resp, err := c.Get(u)
	if err != nil {
		fail(err)
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		fail(fmt.Errorf("http %d", resp.StatusCode))
		return
	}
	dl.Lock()
	dl.total = resp.ContentLength
	dl.Unlock()
	part := filepath.Join(dataDir, "update.part")
	f, err := os.Create(part)
	if err != nil {
		fail(err)
		return
	}
	buf := make([]byte, 64<<10)
	var head []byte
	for {
		n, er := resp.Body.Read(buf)
		if n > 0 {
			if len(head) < 2 {
				head = append(head, buf[:n]...)
			}
			if _, ew := f.Write(buf[:n]); ew != nil {
				f.Close()
				fail(ew)
				return
			}
			dl.Lock()
			dl.got += int64(n)
			dl.Unlock()
		}
		if er == io.EOF {
			break
		}
		if er != nil {
			f.Close()
			fail(er)
			return
		}
	}
	f.Close()
	dl.Lock()
	got := dl.got
	dl.Unlock()
	if got < 1<<20 || len(head) < 2 || head[0] != 'M' || head[1] != 'Z' {
		os.Remove(part)
		fail(errors.New("not an exe"))
		return
	}
	// 같은(또는 예전) 버전을 받으면 설치하지 않는다 → 업데이트 창이 계속 뜨는 일 방지
	if v := exeVersion(part); v == "" || vcmp(v, AppVersion) <= 0 {
		os.Remove(part)
		fail(fmt.Errorf("downloaded version %q is not newer than %s", v, AppVersion))
		return
	}
	dst := filepath.Join(dataDir, "update.exe")
	os.Remove(dst)
	if err := os.Rename(part, dst); err != nil {
		fail(err)
		return
	}
	dl.Lock()
	dl.state = "ok"
	dl.Unlock()
}

func exeVersion(p string) string {
	b, err := os.ReadFile(p)
	if err != nil {
		return ""
	}
	i := strings.Index(string(b), "HM-APP-VERSION:")
	if i < 0 {
		return ""
	}
	rest := string(b[i+15:])
	j := strings.IndexByte(rest, ';')
	if j < 0 || j > 20 {
		return ""
	}
	return rest[:j]
}

//go:build windows

package main

import (
	"encoding/base64"
	"encoding/binary"
	"errors"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
	"unicode/utf16"
	"unsafe"
)

var (
	user32   = syscall.NewLazyDLL("user32.dll")
	advapi32 = syscall.NewLazyDLL("advapi32.dll")
	shell32  = syscall.NewLazyDLL("shell32.dll")
	kernel32 = syscall.NewLazyDLL("kernel32.dll")

	pMessageBox       = user32.NewProc("MessageBoxW")
	pRegCreateKeyEx   = advapi32.NewProc("RegCreateKeyExW")
	pRegSetValueEx    = advapi32.NewProc("RegSetValueExW")
	pRegCloseKey      = advapi32.NewProc("RegCloseKey")
	pRegDeleteTree    = advapi32.NewProc("RegDeleteTreeW")
	pSHChangeNotify   = shell32.NewProc("SHChangeNotify")
	pShellExecute     = shell32.NewProc("ShellExecuteW")
	pGetDriveType     = kernel32.NewProc("GetDriveTypeW")
	pGetLogicalDrives = kernel32.NewProc("GetLogicalDrives")
)

const (
	appName   = "해피뮤직"
	hkcu      = 0x80000001
	uninstKey = `Software\Microsoft\Windows\CurrentVersion\Uninstall\HappyMusic`
	appsKey   = `Software\Classes\Applications\HappyMusic.exe`
)

var assocExt = []string{".mp3", ".m4a", ".aac", ".flac", ".wav", ".ogg", ".opus"}

func u16(s string) *uint16 { p, _ := syscall.UTF16PtrFromString(s); return p }

func msgBox(text string, flags uintptr) int {
	r, _, _ := pMessageBox.Call(0, uintptr(unsafe.Pointer(u16(text))), uintptr(unsafe.Pointer(u16(appName))), flags|0x10000)
	return int(r)
}

func fatal(msg string) { msgBox(msg, 0x10); os.Exit(1) }

func appDataDir() string {
	d := os.Getenv("LOCALAPPDATA")
	if d == "" {
		d, _ = os.UserConfigDir()
	}
	return filepath.Join(d, "HappyMusic")
}

func installDir() string {
	d := os.Getenv("LOCALAPPDATA")
	if d == "" {
		d, _ = os.UserConfigDir()
	}
	return filepath.Join(d, "Programs", "HappyMusic")
}

func targetExe() string { return filepath.Join(installDir(), "HappyMusic.exe") }

func selfExe() string {
	p, _ := os.Executable()
	if q, err := filepath.EvalSymlinks(p); err == nil {
		p = q
	}
	return filepath.Clean(p)
}

func hidden(name string, arg ...string) *exec.Cmd {
	c := exec.Command(name, arg...)
	c.SysProcAttr = &syscall.SysProcAttr{HideWindow: true, CreationFlags: 0x08000000}
	return c
}

func powershell(script string) error {
	u := utf16.Encode([]rune(script))
	b := make([]byte, len(u)*2)
	for i, c := range u {
		binary.LittleEndian.PutUint16(b[i*2:], c)
	}
	return hidden("powershell.exe", "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-EncodedCommand", base64.StdEncoding.EncodeToString(b)).Run()
}

func psq(s string) string { return "'" + strings.ReplaceAll(s, "'", "''") + "'" }

// 설치 프로그램 역할: 받은 exe를 실행하면 설치하고, 설치된 exe는 앱으로 동작
func platformPreflight(args []string) bool {
	for _, a := range args {
		if a == "--uninstall" {
			uninstall()
			return true
		}
		if a == "--portable" {
			return false
		}
	}
	if strings.EqualFold(selfExe(), filepath.Clean(targetExe())) {
		go regApp(targetExe()) // 버전 정보 갱신
		return false
	}
	install(args)
	return true
}

func install(args []string) {
	verb := "설치할까요?"
	if _, err := os.Stat(targetExe()); err == nil {
		verb = "새 버전으로 업데이트할까요?"
	}
	if msgBox("해피뮤직 PC 버전 "+AppVersion+"을(를) "+verb+"\n\n· 시작 메뉴와 바탕화면에 바로가기를 만들어요\n· 음악 파일의 '연결 프로그램'에 해피뮤직이 추가돼요\n· 설치 위치: "+installDir(), 0x24) != 6 {
		return
	}
	quitRunning()
	if err := os.MkdirAll(installDir(), 0o755); err != nil {
		fatal("설치 폴더를 만들 수 없어요.\n" + err.Error())
	}
	t := targetExe()
	if _, err := os.Stat(t); err == nil {
		os.Remove(t + ".old")
		if err := os.Rename(t, t+".old"); err != nil {
			fatal("이전 버전을 바꿀 수 없어요. 해피뮤직을 닫고 다시 시도해 주세요.\n" + err.Error())
		}
	}
	if err := copyFile(selfExe(), t); err != nil {
		os.Rename(t+".old", t)
		fatal("파일을 복사할 수 없어요.\n" + err.Error())
	}
	makeShortcuts(t)
	regApp(t)
	pass := []string{}
	for _, a := range args {
		if !strings.HasPrefix(a, "--") {
			pass = append(pass, a)
		}
	}
	exec.Command(t, pass...).Start()
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	if _, err := io.Copy(out, in); err != nil {
		out.Close()
		return err
	}
	return out.Close()
}

func makeShortcuts(t string) {
	s := `$W=New-Object -ComObject WScript.Shell
foreach($d in @([Environment]::GetFolderPath('Programs'),[Environment]::GetFolderPath('Desktop'))){
 if(-not $d){continue}
 $s=$W.CreateShortcut((Join-Path $d ` + psq(appName+".lnk") + `))
 $s.TargetPath=` + psq(t) + `
 $s.WorkingDirectory=` + psq(filepath.Dir(t)) + `
 $s.IconLocation=` + psq(t+",0") + `
 $s.Description=` + psq(appName) + `
 $s.Save()
}`
	if err := powershell(s); err != nil {
		log.Print("shortcut: ", err)
	}
}

func removeShortcuts() {
	powershell(`foreach($d in @([Environment]::GetFolderPath('Programs'),[Environment]::GetFolderPath('Desktop'))){ if($d){ Remove-Item -LiteralPath (Join-Path $d ` + psq(appName+".lnk") + `) -ErrorAction SilentlyContinue } }`)
}

type regKey uintptr

func regCreate(path string) (regKey, error) {
	var h uintptr
	r, _, _ := pRegCreateKeyEx.Call(hkcu, uintptr(unsafe.Pointer(u16(path))), 0, 0, 0, 0x20006, 0, uintptr(unsafe.Pointer(&h)), 0)
	if r != 0 {
		return 0, errors.New("RegCreateKeyEx failed")
	}
	return regKey(h), nil
}

func (k regKey) str(name, val string) {
	u, _ := syscall.UTF16FromString(val)
	var np uintptr
	if name != "" {
		np = uintptr(unsafe.Pointer(u16(name)))
	}
	pRegSetValueEx.Call(uintptr(k), np, 0, 1, uintptr(unsafe.Pointer(&u[0])), uintptr(len(u)*2))
}

func (k regKey) dword(name string, v uint32) {
	pRegSetValueEx.Call(uintptr(k), uintptr(unsafe.Pointer(u16(name))), 0, 4, uintptr(unsafe.Pointer(&v)), 4)
}

func (k regKey) close() { pRegCloseKey.Call(uintptr(k)) }

func setKey(path string, f func(k regKey)) {
	k, err := regCreate(path)
	if err != nil {
		log.Print(err, " ", path)
		return
	}
	f(k)
	k.close()
}

// 프로그램 추가/제거 목록 + '연결 프로그램' 등록
func regApp(t string) {
	size := uint32(0)
	if st, err := os.Stat(t); err == nil {
		size = uint32(st.Size() / 1024)
	}
	setKey(uninstKey, func(k regKey) {
		k.str("DisplayName", appName)
		k.str("DisplayVersion", AppVersion)
		k.str("Publisher", "HappyMusic")
		k.str("DisplayIcon", t+",0")
		k.str("InstallLocation", filepath.Dir(t))
		k.str("UninstallString", `"`+t+`" --uninstall`)
		k.str("URLInfoAbout", "https://github.com/youngchoulchoi-cpu/happymusic")
		k.dword("NoModify", 1)
		k.dword("NoRepair", 1)
		k.dword("EstimatedSize", size)
	})
	setKey(appsKey, func(k regKey) { k.str("FriendlyAppName", appName) })
	setKey(appsKey+`\DefaultIcon`, func(k regKey) { k.str("", t+",0") })
	setKey(appsKey+`\shell\open`, func(k regKey) { k.str("FriendlyAppName", appName) })
	setKey(appsKey+`\shell\open\command`, func(k regKey) { k.str("", `"`+t+`" "%1"`) })
	for _, e := range assocExt {
		setKey(appsKey+`\SupportedTypes`, func(k regKey) { k.str(e, "") })
		setKey(`Software\Classes\`+e+`\OpenWithList\HappyMusic.exe`, func(k regKey) {})
	}
	pSHChangeNotify.Call(0x08000000, 0, 0, 0)
}

func uninstall() {
	if msgBox("해피뮤직을 이 PC에서 제거할까요?", 0x24) != 6 {
		return
	}
	quitRunning()
	removeShortcuts()
	for _, k := range []string{uninstKey, appsKey} {
		pRegDeleteTree.Call(hkcu, uintptr(unsafe.Pointer(u16(k))))
	}
	for _, e := range assocExt {
		pRegDeleteTree.Call(hkcu, uintptr(unsafe.Pointer(u16(`Software\Classes\`+e+`\OpenWithList\HappyMusic.exe`))))
	}
	pSHChangeNotify.Call(0x08000000, 0, 0, 0)
	delData := msgBox("설정과 보관함 기록(닉네임, 좋아요, 게임 기록 등)도 지울까요?\n\n'아니요'를 누르면 남겨 두었다가 다시 설치할 때 그대로 써요.", 0x24) == 6
	if delData {
		time.Sleep(1500 * time.Millisecond)
		os.RemoveAll(appDataDir())
	}
	dir := installDir()
	hidden("cmd.exe", "/c", `ping 127.0.0.1 -n 3 >nul & rmdir /s /q "`+dir+`"`).Start()
	msgBox("해피뮤직을 제거했어요.", 0x40)
}

func cleanupOld() {
	go func() {
		old := selfExe() + ".old"
		for i := 0; i < 30; i++ {
			if _, err := os.Stat(old); err != nil {
				return
			}
			if os.Remove(old) == nil {
				return
			}
			time.Sleep(time.Second)
		}
	}()
}

// 프로그램 자체 업데이트: 실행 중인 exe 이름을 바꾸고 새 exe를 그 자리에 둔 뒤 다시 시작
func installUpdate(newExe string) error {
	self := selfExe()
	old := self + ".old"
	os.Remove(old)
	if err := os.Rename(self, old); err != nil {
		return err
	}
	if err := os.Rename(newExe, self); err != nil {
		if err2 := copyFile(newExe, self); err2 != nil {
			os.Rename(old, self)
			return err2
		}
		os.Remove(newExe)
	}
	return exec.Command(self, "--noopen").Start()
}

func findBrowser() string {
	cands := []string{}
	for _, env := range []string{"ProgramFiles(x86)", "ProgramFiles", "LOCALAPPDATA"} {
		if b := os.Getenv(env); b != "" {
			cands = append(cands, filepath.Join(b, `Microsoft\Edge\Application\msedge.exe`))
		}
	}
	for _, env := range []string{"ProgramFiles", "ProgramFiles(x86)", "LOCALAPPDATA"} {
		if b := os.Getenv(env); b != "" {
			cands = append(cands, filepath.Join(b, `Google\Chrome\Application\chrome.exe`))
		}
	}
	for _, c := range cands {
		if _, err := os.Stat(c); err == nil {
			return c
		}
	}
	return ""
}

// 앱 전용 창으로 열기 (주소창 없는 Edge 앱 창, 전용 프로필)
func openWindow(first bool) {
	b := findBrowser()
	if b == "" {
		pShellExecute.Call(0, uintptr(unsafe.Pointer(u16("open"))), uintptr(unsafe.Pointer(u16(localURL()))), 0, 0, 1)
		return
	}
	c := exec.Command(b, "--app="+localURL(), "--user-data-dir="+filepath.Join(appDataDir(), "browser"),
		"--no-first-run", "--no-default-browser-check", "--disable-features=Translate", "--window-size=1100,860",
		"--autoplay-policy=no-user-gesture-required")
	if err := c.Start(); err != nil {
		log.Print("browser: ", err)
		pShellExecute.Call(0, uintptr(unsafe.Pointer(u16("open"))), uintptr(unsafe.Pointer(u16(localURL()))), 0, 0, 1)
		return
	}
	if first {
		browserOn = true
		go func() { c.Wait(); close(browserDone) }()
	} else {
		go c.Wait()
	}
}

func scanRoots() []string {
	h, _ := os.UserHomeDir()
	roots := []string{}
	add := func(p string) {
		if st, err := os.Stat(p); err == nil && st.IsDir() {
			for _, r := range roots {
				if strings.EqualFold(r, p) || strings.HasPrefix(strings.ToLower(p), strings.ToLower(r)+`\`) {
					return
				}
			}
			roots = append(roots, p)
		}
	}
	for _, s := range []string{"Music", "Downloads", "Desktop", "Documents", "Videos"} {
		add(filepath.Join(h, s))
	}
	if ents, err := os.ReadDir(h); err == nil {
		for _, e := range ents {
			if e.IsDir() && strings.HasPrefix(strings.ToLower(e.Name()), "onedrive") {
				add(filepath.Join(h, e.Name()))
			}
		}
	}
	if p := os.Getenv("PUBLIC"); p != "" {
		add(filepath.Join(p, "Music"))
	}
	// 다른 드라이브(D:, E: …)의 고정 디스크
	mask, _, _ := pGetLogicalDrives.Call()
	for i := 3; i < 26; i++ { // D부터
		if mask&(1<<uint(i)) == 0 {
			continue
		}
		root := string(rune('A'+i)) + `:\`
		t, _, _ := pGetDriveType.Call(uintptr(unsafe.Pointer(u16(root))))
		if t == 3 { // DRIVE_FIXED
			add(root)
		}
	}
	return roots
}

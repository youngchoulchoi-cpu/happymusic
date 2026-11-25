package main

import (
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

func localURL() string { return "http://" + addr + "/" }

// 이미 켜져 있는 해피뮤직이 있으면 마지막 연결 후 몇 초 지났는지
func helloAge() (int, bool) {
	c := &http.Client{Timeout: 2 * time.Second}
	r, err := c.Get("http://" + addr + "/api/hello")
	if err != nil {
		return 0, false
	}
	defer r.Body.Close()
	b, _ := io.ReadAll(io.LimitReader(r.Body, 64))
	f := strings.Fields(string(b))
	if len(f) != 2 || f[0] != "happymusic" {
		return 0, false
	}
	n, _ := strconv.Atoi(f[1])
	return n, true
}

func runningToken() string {
	b, _ := os.ReadFile(filepath.Join(appDataDir(), "token"))
	return strings.TrimSpace(string(b))
}

func apiPost(path, body string) bool {
	req, err := http.NewRequest("POST", "http://"+addr+path, strings.NewReader(body))
	if err != nil {
		return false
	}
	req.Header.Set("X-HM-Token", runningToken())
	c := &http.Client{Timeout: 3 * time.Second}
	r, err := c.Do(req)
	if err != nil {
		return false
	}
	r.Body.Close()
	return r.StatusCode == 200
}

func postOpen(p string) {
	if abs, err := filepath.Abs(p); err == nil {
		p = abs
	}
	apiPost("/api/open", p)
}

// 실행 중인 해피뮤직을 끄고 포트가 빌 때까지 기다린다 (설치·제거 때)
func quitRunning() {
	if _, ok := helloAge(); !ok {
		return
	}
	apiPost("/api/quit", "")
	for i := 0; i < 40; i++ {
		if _, ok := helloAge(); !ok {
			return
		}
		time.Sleep(250 * time.Millisecond)
	}
}

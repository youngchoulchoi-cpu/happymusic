//go:build !windows

package main

// 윈도우가 아닌 곳(개발·자동 테스트용). 실제 배포는 platform_windows.go.

import (
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func platformPreflight(args []string) bool { return false }

func appDataDir() string {
	if d := os.Getenv("HM_DATA"); d != "" {
		return d
	}
	h, _ := os.UserHomeDir()
	return filepath.Join(h, ".happymusic")
}

func scanRoots() []string {
	if s := os.Getenv("HM_SCAN"); s != "" {
		return strings.Split(s, string(os.PathListSeparator))
	}
	h, _ := os.UserHomeDir()
	return []string{filepath.Join(h, "Music")}
}

func openWindow(first bool)              {}
func uiTitleBar(dark bool, color string) {}
func uiTitle(title string)               {}
func uiFocus() bool                      { return false }
func uiQuit()                            {}
func allowFocus()                        {}

func cleanupOld() {}

func fatal(msg string) { fmt.Fprintln(os.Stderr, msg); os.Exit(1) }

// 테스트: 받은 파일이 실제로 쓸 수 있는지만 확인하고 표시 파일을 남긴다
func installUpdate(newExe string) error {
	st, err := os.Stat(newExe)
	if err != nil || st.Size() < 1<<20 {
		return errors.New("bad update")
	}
	log.Print("install update (test mode)")
	return os.WriteFile(filepath.Join(dataDir, "installed.flag"), []byte("1"), 0o644)
}

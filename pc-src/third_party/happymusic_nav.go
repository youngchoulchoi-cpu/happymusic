package edge

// 해피뮤직: 앱 안 브라우저에 필요한 탐색 기능 (뒤로/앞으로/새로고침/멈춤/주소/제목)

import (
	"unsafe"

	"github.com/jchv/go-webview2/internal/w32"
	"golang.org/x/sys/windows"
)

func (e *Chromium) ready() bool { return e.webview != nil }

func (e *Chromium) GoBack() {
	if e.ready() {
		_, _, _ = e.webview.vtbl.GoBack.Call(uintptr(unsafe.Pointer(e.webview)))
	}
}

func (e *Chromium) GoForward() {
	if e.ready() {
		_, _, _ = e.webview.vtbl.GoForward.Call(uintptr(unsafe.Pointer(e.webview)))
	}
}

func (e *Chromium) Reload() {
	if e.ready() {
		_, _, _ = e.webview.vtbl.Reload.Call(uintptr(unsafe.Pointer(e.webview)))
	}
}

func (e *Chromium) Stop() {
	if e.ready() {
		_, _, _ = e.webview.vtbl.Stop.Call(uintptr(unsafe.Pointer(e.webview)))
	}
}

func (e *Chromium) boolProp(p ComProc) bool {
	if !e.ready() {
		return false
	}
	var v int32
	_, _, _ = p.Call(uintptr(unsafe.Pointer(e.webview)), uintptr(unsafe.Pointer(&v)))
	return v != 0
}

func (e *Chromium) CanGoBack() bool {
	if !e.ready() {
		return false
	}
	return e.boolProp(e.webview.vtbl.GetCanGoBack)
}

func (e *Chromium) CanGoForward() bool {
	if !e.ready() {
		return false
	}
	return e.boolProp(e.webview.vtbl.GetCanGoForward)
}

func (e *Chromium) strProp(p ComProc) string {
	if !e.ready() {
		return ""
	}
	var s *uint16
	_, _, _ = p.Call(uintptr(unsafe.Pointer(e.webview)), uintptr(unsafe.Pointer(&s)))
	if s == nil {
		return ""
	}
	out := w32.Utf16PtrToString(s)
	windows.CoTaskMemFree(unsafe.Pointer(s))
	return out
}

func (e *Chromium) Source() string {
	if !e.ready() {
		return ""
	}
	return e.strProp(e.webview.vtbl.GetSource)
}

func (e *Chromium) Title() string {
	if !e.ready() {
		return ""
	}
	return e.strProp(e.webview.vtbl.GetDocumentTitle)
}

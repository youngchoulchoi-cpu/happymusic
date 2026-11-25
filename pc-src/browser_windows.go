//go:build windows

package main

// 앱 안 인터넷 브라우저 (PC): 두 번째 WebView2를 메인 창 안의 자식 창에 띄운다.
// 위 주소창·아래 버튼은 해피뮤직 화면(HTML)이 그리고, 가운데만 이 창이 차지한다.

import (
	"encoding/json"
	"log"
	"path/filepath"
	"strings"
	"syscall"
	"unsafe"

	"github.com/jchv/go-webview2/pkg/edge"
)

var (
	pCreateWindowEx = user32.NewProc("CreateWindowExW")
	pMoveWindow     = user32.NewProc("MoveWindow")
	pSetWindowPos   = user32.NewProc("SetWindowPos")
	pDestroyWindow  = user32.NewProc("DestroyWindow")
	pGetModuleH     = kernel32.NewProc("GetModuleHandleW")

	br     *edge.Chromium
	brHwnd uintptr
)

// 페이지 안에 넣는 작은 스크립트: 제목/주소 바뀜을 알리고, 새 창(target=_blank)은 같은 창에서 연다
const brInject = `(function(){if(window.top!==window)return;
var post=function(e){try{chrome.webview.postMessage(JSON.stringify({e:e,u:location.href,t:document.title||''}))}catch(_){}};
post('start');
addEventListener('DOMContentLoaded',function(){post('title');var t=document.querySelector('title');if(t)new MutationObserver(function(){post('title')}).observe(t,{childList:true,characterData:true,subtree:true})});
addEventListener('popstate',function(){post('hist')});addEventListener('hashchange',function(){post('hist')});
var ps=history.pushState,rs=history.replaceState;history.pushState=function(){var r=ps.apply(this,arguments);post('hist');return r};history.replaceState=function(){var r=rs.apply(this,arguments);post('hist');return r};
document.addEventListener('click',function(ev){var a=ev.target&&ev.target.closest&&ev.target.closest('a[target]');if(a&&a.target!=='_self'&&a.href&&/^https?:/i.test(a.href)){a.target='_self'}},true);
var wo=window.open;window.open=function(u){if(u){try{location.href=new URL(u,location.href).href}catch(_){}return null}return wo.apply(window,arguments)};
})();`

type brEvent struct {
	E string `json:"e"`
	U string `json:"u"`
	T string `json:"t"`
	P int    `json:"p"`
	B bool   `json:"b"`
	F bool   `json:"f"`
}

// 메인 화면으로 알림 (값은 항상 Go에서 다시 만들어 넣으므로 웹페이지가 메인 화면에 코드를 넣을 수 없다)
func brEmit(ev brEvent) {
	v := wv
	if v == nil || br == nil {
		return
	}
	ev.B, ev.F = br.CanGoBack(), br.CanGoForward()
	if len(ev.U) > 4096 {
		ev.U = ev.U[:4096]
	}
	if len(ev.T) > 300 {
		ev.T = ev.T[:300]
	}
	j, _ := json.Marshal(ev)
	v.Eval("window.onBrowser&&onBrowser(" + string(j) + ")")
}

func brHas() bool { return wv != nil }

func brCreate() bool {
	if br != nil {
		return true
	}
	v := wv
	if v == nil {
		return false
	}
	parent := uintptr(v.Window())
	hinst, _, _ := pGetModuleH.Call(0)
	cls, _ := syscall.UTF16PtrFromString("STATIC")
	// WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN | WS_CLIPSIBLINGS
	h, _, _ := pCreateWindowEx.Call(0, uintptr(unsafe.Pointer(cls)), 0, 0x40000000|0x10000000|0x02000000|0x04000000, 0, 0, 10, 10, parent, 0, hinst, 0)
	if h == 0 {
		return false
	}
	c := edge.NewChromium()
	c.DataPath = filepath.Join(appDataDir(), "webview")
	c.MessageCallback = func(m string) {
		var ev brEvent
		if json.Unmarshal([]byte(m), &ev) != nil {
			return
		}
		switch ev.E {
		case "start", "title", "hist":
		default:
			return
		}
		ev.P = -1
		if ev.E == "start" {
			ev.P = 10
		}
		brEmit(brEvent{E: ev.E, U: br.Source(), T: br.Title(), P: ev.P})
	}
	c.NavigationCompletedCallback = func(_ *edge.ICoreWebView2, _ *edge.ICoreWebView2NavigationCompletedEventArgs) {
		brEmit(brEvent{E: "finish", U: br.Source(), T: br.Title(), P: 100})
	}
	if !c.Embed(h) {
		pDestroyWindow.Call(h)
		log.Print("browser: embed failed")
		return false
	}
	if s, err := c.GetSettings(); err == nil {
		_ = s.PutAreDevToolsEnabled(false)
		_ = s.PutIsStatusBarEnabled(true)
	}
	c.Init(brInject)
	br, brHwnd = c, h
	return true
}

func brSetBounds(x, y, w, h int) {
	if brHwnd == 0 {
		return
	}
	if w < 1 {
		w = 1
	}
	if h < 1 {
		h = 1
	}
	pMoveWindow.Call(brHwnd, uintptr(x), uintptr(y), uintptr(w), uintptr(h), 1)
	pSetWindowPos.Call(brHwnd, 0, 0, 0, 0, 0, 0x0001|0x0002|0x0010) // HWND_TOP, NOSIZE|NOMOVE|NOACTIVATE
	br.Resize()
}

func safeURL(u string) bool {
	l := strings.ToLower(strings.TrimSpace(u))
	return strings.HasPrefix(l, "https://") || strings.HasPrefix(l, "http://")
}

func uiBrOpen(u string, x, y, w, h int) bool {
	v := wv
	if v == nil {
		return false
	}
	v.Dispatch(func() {
		if !brCreate() {
			brEmit(brEvent{E: "fail"})
			return
		}
		brSetBounds(x, y, w, h)
		pShowWindow.Call(brHwnd, 5) // SW_SHOW
		if u != "" && safeURL(u) {
			br.Navigate(u)
		}
	})
	return true
}

func uiBrLoad(u string) {
	if v := wv; v != nil && safeURL(u) {
		v.Dispatch(func() {
			if br != nil {
				br.Navigate(u)
			}
		})
	}
}

func uiBrBounds(x, y, w, h int) {
	if v := wv; v != nil {
		v.Dispatch(func() { brSetBounds(x, y, w, h) })
	}
}

// 2 뒤로 3 앞으로 4 새로고침 5 멈춤 6 숨김 7 보임 9 닫기(숨김)
func uiBrCmd(op int) {
	v := wv
	if v == nil {
		return
	}
	v.Dispatch(func() {
		if br == nil {
			return
		}
		switch op {
		case 2:
			br.GoBack()
		case 3:
			br.GoForward()
		case 4:
			br.Reload()
		case 5:
			br.Stop()
		case 6, 9:
			pShowWindow.Call(brHwnd, 0) // SW_HIDE
			if op == 9 {
				br.Navigate("about:blank")
			}
		case 7:
			pShowWindow.Call(brHwnd, 5)
		}
	})
}

func openURL(u string) bool {
	if !safeURL(u) {
		return false
	}
	pShellExecute.Call(0, uintptr(unsafe.Pointer(u16("open"))), uintptr(unsafe.Pointer(u16(u))), 0, 0, 1)
	return true
}

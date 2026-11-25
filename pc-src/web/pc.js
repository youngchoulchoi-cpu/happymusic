(function(){
/* 해피뮤직 PC: 휴대폰 앱의 window.Android 와 같은 기능을 PC 프로그램이 제공 */
var TK=window.__HM_TOKEN||'';
function x(m,u,b){try{var r=new XMLHttpRequest();r.open(m,u,false);r.setRequestHeader('X-HM-Token',TK);if(b!=null)r.setRequestHeader('Content-Type','text/plain;charset=utf-8');r.send(b==null?null:b);return r.status===200?r.responseText:''}catch(e){return ''}}
function f(u,o){o=o||{};o.headers=Object.assign({'X-HM-Token':TK},o.headers||{});return fetch(u,o)}
var ver=null;
/* 프로그램이 새로 시작되면(업데이트 등) 토큰이 바뀌므로 화면을 다시 불러온다 */
var A={platform:'pc',
 sdk:function(){return 0},hasPerm:function(){return true},hasAllFiles:function(){return true},
 requestPerm:function(){},requestAllFiles:function(){},openSettings:function(){},
 scan:function(){return '[]'},
 deepScan:function(){f('/api/deepscan').then(function(r){return r.text()}).then(function(j){window.onDeepScan&&window.onDeepScan(j)}).catch(function(){window.onDeepScan&&window.onDeepScan('[]')})},
 meta:function(p){return x('GET','/api/meta?p='+encodeURIComponent(p))||'{}'},
 mediaScan:function(){},setState:function(){},
 setBars:function(d){setTimeout(function(){var c=getComputedStyle(document.documentElement).getPropertyValue('--bg').trim();f('/api/bars',{method:'POST',body:(d?'1':'0')+'|'+c}).catch(function(){})},0)},
 takeOpened:function(){return x('GET','/api/opened')},
 appVersion:function(){return ver||(ver=x('GET','/api/version')||'-')},
 saveWeb:function(h){return x('POST','/api/saveweb',h)==='ok'},
 resetWeb:function(){x('POST','/api/resetweb','')},
 bootOk:function(){x('POST','/api/bootok','')},
 canInstall:function(){return true},requestInstallPermission:function(){},
 downloadUpdate:function(u){return +x('POST','/api/download',u)||0},
 updateStatus:function(){return x('GET','/api/dlstatus')||'none'},
 installUpdate:function(){return x('POST','/api/install','')==='ok'}
};
window.Android=A;
var openBusy=false;
function ping(){f('/api/ping',{cache:'no-store'}).then(function(r){if(r.status===403){location.reload();return ''}return r.text()}).then(function(t){if(t==='open'&&window.onAndroidOpen&&!openBusy){openBusy=true;Promise.resolve(window.onAndroidOpen()).finally(function(){openBusy=false})}}).catch(function(){})}
ping();setInterval(ping,3000);
/* 창 제목 = 지금 재생 중인 곡 (작업 표시줄에 보임) */
var lastT='';function title(){var t=document.title||'';if(t&&t!==lastT){lastT=t;f('/api/title',{method:'POST',body:t}).catch(function(){})}}
document.addEventListener('DOMContentLoaded',function(){title();var el=document.querySelector('title');if(el)new MutationObserver(title).observe(el,{childList:true,characterData:true,subtree:true})});
})();

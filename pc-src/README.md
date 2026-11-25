# 해피뮤직 PC (Windows)

휴대폰 앱과 **같은 화면 파일**(`web/index.html`)을 씁니다. 화면 업데이트(`update.json`의 `version`/`web`)는 휴대폰과 PC에 동시에 적용돼요.

- `update.json`의 `native`/`apkUrl` → 안드로이드 앱, `pc`/`pcUrl` → PC 프로그램 업데이트
- 빌드: `cp ../index.html web/index.html && GOOS=windows GOARCH=amd64 go build -trimpath -ldflags "-s -w -H windowsgui" -o HappyMusic-Setup.exe .`
- 아이콘·버전 정보: `res/` → `llvm-rc` + `llvm-cvtres`로 `rsrc_windows_amd64.syso` 생성

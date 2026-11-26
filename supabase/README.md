# 해피톡 서버 만들기 (Supabase, 무료)

해피톡(계정·채팅·파일·초대)은 관리자가 만든 Supabase 서버에 저장됩니다. 처음 한 번만 하면 됩니다. 10분쯤 걸립니다.

## 1. 프로젝트 만들기
1. https://supabase.com 에 가입하고 로그인합니다.
2. **New project**를 누릅니다.
   - 이름: `happymusic` (아무거나)
   - Database Password: 아무 비밀번호나 만들고 따로 적어 둡니다 (앱에는 필요 없음)
   - Region: **Northeast Asia (Seoul)**
3. 만들어질 때까지 1~2분 기다립니다.

## 2. 설정 SQL 실행
1. 왼쪽 메뉴 **SQL Editor** → **New query**
2. 이 폴더의 [`schema.sql`](schema.sql) 내용을 **전부** 복사해 붙여 넣고 **Run**
3. 아래쪽에 `Success. No rows returned`가 나오면 성공입니다. (여러 번 실행해도 안전합니다)

## 3. 이메일 확인 끄기 (권장)
기본값은 가입할 때 확인 메일을 눌러야 해서 불편하고, 무료 메일 발송 한도도 작습니다.

- **Authentication** → **Sign In / Providers** (또는 **Providers**) → **Email** → **Confirm email** 끄기 → Save

## 4. 주소와 공개 키 복사
- **Project Settings** → **API Keys** (또는 **API**) 에서
  - **Project URL**: `https://xxxx.supabase.co`
  - **Publishable key** (`sb_publishable_…`) 또는 **anon public** 키 (`eyJ…`)

⚠️ **secret / service_role 키는 절대 앱에 넣거나 다른 사람에게 보내지 마세요.** 공개 키는 앱에 들어가도 괜찮습니다 (권한은 서버 규칙이 지킵니다).

## 5. 앱에 연결
- 이 두 값을 개발 담당에게 보내면 앱에 넣어 업데이트로 배포합니다. 모든 휴대폰·PC가 자동으로 같은 서버를 씁니다.
- 바로 써 보려면: 해피뮤직 → 홈 › **해피톡** → **서버 연결**에 붙여 넣기.

## 6. 관리자 되기
- 서버를 연결한 뒤 **가장 먼저 가입한 사람이 관리자**가 됩니다. 관리자가 먼저 가입하세요.
- 그다음부터는 초대 코드가 있어야 가입할 수 있습니다 (해피톡 › 해피앱으로 초대하기).

## 무료 요금제 한도
- 파일 저장 1GB, 한 달 전송 5GB, 데이터베이스 500MB
- **1주일 동안 아무도 안 쓰면 일시정지**됩니다. Supabase 대시보드에서 **Restore**를 누르면 다시 켜집니다.

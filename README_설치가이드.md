# 놀러가요 후쿠오카! 📒🌴

**2026.10.31 ~ 11.03 · 가족 4인 · 후쿠오카/유후인/벳푸 모바일 다이어리**

이 폴더 **안의 모든 파일과 폴더**를 GitHub 저장소의 최상위(root)에 업로드하세요. ZIP 파일 자체를 GitHub에 올리는 방식이 아닙니다.

## 0. 가장 먼저 읽어주세요

- `config.js`를 **빈 값 그대로** 올리면 **체험 모드**가 열립니다. 화면, 장소 검색, 일정 및 기기별 메모를 시험할 수 있지만 **누구나 내부를 열 수 있고**, 데이터는 사용 중인 **그 아이폰 브라우저에만** 저장됩니다.
- 가족 Google 로그인과 비공개 메모/가족별 동기화를 쓰려면 **Supabase + Google OAuth 설정**이 별도로 필요합니다. HTML/CSV를 GitHub에 올리는 것만으로 로그인 및 클라우드 저장이 자동으로 켜지지 않습니다.
- GitHub Pages에 배포한 `index.html`, `data/*.json`, 공개 사진과 JavaScript는 **URL을 아는 누구든 읽을 수 있습니다.** 화면의 로그인 게이트는 공개 정적 파일을 비밀로 만들 수 없습니다. **여권번호, 실제 예약번호, 진짜 탑승용 바코드·QR, 가족 이메일 주소, 비공개 개인기록은 GitHub 파일에 넣지 마세요.** 개인 기록은 Supabase의 비공개 DB/Storage에만 저장됩니다.
- 인터넷에 연결되었을 때 사이트를 한 번 방문해야 오프라인 화면 자료를 저장할 수 있습니다. 오프라인에서 실시간 지도 타일/현재 날씨/로그인은 작동하지 않을 수 있습니다.

## 1. GitHub Pages 배포하기 (먼저 이것만으로 화면 확인 가능)

1. [GitHub](https://github.com)에 로그인한 후 `New repository`를 눌러 새 저장소를 만듭니다. 예: `fukuoka-diary-2026`.
2. 생성된 저장소에서 **Add file → Upload files**를 클릭합니다.
3. 압축을 푼 폴더 **안의** `index.html`, `app.js`, `style.css`, `config.js`, `sw.js`, `manifest.webmanifest`, `data` 폴더, `assets` 폴더, `.nojekyll` 파일 등을 전부 선택하여 업로드합니다. `index.html`이 저장소 최상단에 있어야 합니다.
4. Commit changes를 누릅니다.
5. **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch: main → Folder: /(root) → Save**.
6. 나타나는 주소 `https://사용자이름.github.io/fukuoka-diary-2026/`로 접속합니다. 배포가 완료되기 전에는 404가 잠깐 나올 수 있습니다.
7. iPhone Safari에서 주소를 열고 공유 메뉴 → **홈 화면에 추가**를 사용하면 앱처럼 실행됩니다.

## 2. 가족 전용 기능 연결하기 (체험 후 진행)

> 준비물: GitHub Pages 실제 주소, 본인의 Google 계정 1개, 부모님·언니 Google 계정. 계정 주소를 나에게 보내지 않아도 됩니다.

### A. Supabase 만들기

1. [Supabase](https://supabase.com)에서 무료 계정을 만듭니다.
2. **New project**를 선택하고 프로젝트 이름과 DB 암호를 설정합니다. DB 암호는 어디에도 붙여넣지 말고 개인적으로 보관하세요.
3. 프로젝트의 **SQL Editor** → 새 쿼리 → 이 폴더의 `supabase_setup.sql` 내용 전체 복사 → **Run**을 누릅니다. Tables와 `memo-media` 비공개 버킷이 생성됩니다.
4. **Project Settings / API**(화면에 따라 **Connect** 또는 API Keys)에서 **Project URL**과 **publishable key 또는 anon public key**를 확인합니다. 서버용 `service_role` / `secret` 키는 웹사이트에 절대 넣으면 안 됩니다.

### B. Google OAuth 연결

1. Supabase **Authentication → Sign In / Providers → Google**을 찾아 켭니다. 화면에 나오는 **Callback URL**을 복사하세요. 대체로 `https://프로젝트ID.supabase.co/auth/v1/callback` 형식입니다.
2. [Google Cloud Console](https://console.cloud.google.com)에서 프로젝트 생성 → **Google Auth Platform** 설정 → OAuth 동의 화면 구성. 테스트 모드라면 가족 4명의 Google 계정을 **Test users**에 추가해야 로그인할 수 있습니다.
3. **Clients → Create client → Web application**을 생성합니다.
   - Authorized JavaScript origins: `https://사용자이름.github.io`
   - Authorized redirect URIs: 1번에서 복사한 **Supabase Callback URL**
4. 생성된 **Client ID**와 **Client Secret**을 **Supabase Google Provider 설정**에만 붙여넣습니다. **Google Client Secret을 `config.js`나 GitHub에 넣지 마세요.**
5. Supabase **Authentication → URL Configuration**에서 Site URL과 Redirect URLs에 정확한 GitHub Pages 전체 주소를 추가합니다. 예: `https://사용자이름.github.io/fukuoka-diary-2026/`.

### C. GitHub `config.js` 두 값 수정

GitHub 저장소에서 `config.js` → 연필 아이콘 → 아래 두 값을 Supabase에서 받은 **공개용 값**으로 바꿔서 Commit합니다.

```javascript
window.FUKUOKA_CONFIG = {
  supabaseUrl: 'https://내프로젝트.supabase.co',
  supabaseAnonKey: '내프로젝트의 publishable 또는 anon PUBLIC key',
  adminEmail: '',
  siteTitle: '놀러가요 후쿠오카!'
};
```

`adminEmail`은 기밀정보 노출 방지를 위해 비워두세요. **이 값으로 관리자 권한을 부여하지 않습니다.** SQL에서만 권한을 부여합니다.

이제 사이트 새로고침 → Google 로그인 → **가족 승인 대기 중** 화면이 뜨면 정상입니다.

### D. 본인을 관리자 승인하기 (중요)

Supabase의 **SQL Editor**에서 **아래 한 줄의 이메일만 본인 Google 이메일로 바꾼 뒤** 실행합니다.

```sql
UPDATE public.family_members SET approved=true, role='admin'
WHERE id=(SELECT id FROM auth.users WHERE email='본인구글메일@gmail.com' LIMIT 1);
```

그 다음 사이트의 **승인 확인하기**를 누르면 내부에 입장할 수 있습니다. 관리자만 일정 수정이 가능합니다.

### E. 부모님/언니 승인하기

1. 각 가족이 사이트에 접속해 각자의 Google 계정으로 한 번 로그인합니다.
2. Supabase SQL Editor에서 아래 세 주소를 **실제 가족 계정 이메일로 수정하여** 실행합니다.

```sql
UPDATE public.family_members SET approved=true
WHERE id IN (SELECT id FROM auth.users WHERE email IN (
 '가족1@gmail.com','가족2@gmail.com','가족3@gmail.com'
));
```

3. 가족이 **승인 확인하기**를 누르면 입장 가능합니다. 개인 메모·체크리스트는 계정별로 분리됩니다.

**주의:** 사이트의 `data/itinerary.json`은 공개 기본 일정입니다. 관리자(본인)가 사이트에서 일정을 수정하면 Supabase `travel_days`에 저장되고, 승인된 가족 계정에만 공유됩니다.

## 3. 다이어리 사용법

- 표지 아무 곳이나 터치 → 여행 전 안내 → `OK!` → 우측 인덱스.
- 안내문 `다음부터 보지 않기`를 누르면 이후 생략됩니다. 설정 메뉴에서 다시 볼 수 있습니다.
- **여권:** 왕복 티켓 터치 시 방향 전환, `프로필`에서 새 가족 캐릭터 4종 포함 14종 선택 및 닉네임 편집.
- **주차장 / 맛집 / 토벌:** 검색, 종류/지역 필터, 현재 위치, Google 길찾기. 지도 핀은 정확한 좌표가 확인된 장소에 표시됩니다. `목록 핀 찾기`로 일부 매장 주소를 지도 서비스에서 검색할 수 있습니다. 완전한 실시간 재고/영업 상태를 보장하지 않습니다.
- **숙소:** 같은 크기로 자른 호텔 사진 두 장, 체크인 준비 체크리스트, 주소 및 지도 링크.
- **관광 코스:** 4일 차별 시간표, 상단 날씨, `↗` 장소 정보 검색, 날짜 전환, `↻ 뒤집기` 대체 코스. 관리자만 일정 추가·수정·순서 변경.
- **메모:** 자유메모·체크리스트·토벌 전리품·영수증 템플릿, 사진 및 개인 스티커 업로드. 사진은 자동 압축됩니다. 계정 연결 전에 작성한 **체험 모드 메모는 자동으로 계정에 옮겨지지 않으니** 필요하면 설정의 JSON 백업 기능을 이용하세요.
- **오프라인:** 사전에 사이트를 열어 저장한 정적 여행 정보 열람 가능. 실시간 지도·외부 검색·클라우드 업로드·최신 날씨 업데이트는 온라인 필요.

## 4. 자료 정확도와 여행 안전

- 자료 원본: `data` 폴더의 조사 CSV 및 JSON. 맛집 **타베로그/Google 평점은 확인된 값만** 표시하고 미확인 값은 비워뒀습니다. 영업시간, 휴무, 주차요금, 팝업 입장권은 여행 전에 다시 확인하세요.
- 렌터카 인수 **10월 31일 08:00 예약**, 반납 기한 **11월 3일 20:00 예약**. 실제 공항 도착이 **21:05 출발** 항공편에 충분한 여유가 있도록 **17:30~18:00쯤 조기 반납 목표**를 따로 표시했습니다. 조기 반납 가능 여부는 현장에서 확인하세요.
- `기내 액체류 100mL`는 **개별 용기 기준**이고, 보조배터리는 일반적으로 **위탁 수하물에 넣으면 안 됩니다**. 운항 항공사의 최신 규정을 반드시 우선 확인하세요.
- 장식용 항공권의 바코드는 **탑승권으로 사용할 수 없습니다.** 실제 항공권은 항공사가 발급한 e-ticket/탑승권을 보관하세요.
- 동물의 숲 등 원작 이미지에서 파생된 캐릭터 및 사용자 제공 사진 일부는 개인 사용을 염두에 두었습니다. 공개 게시 시 저작권·초상권 등 사용 권한을 확인하세요.

## 5. 주요 파일

```
index.html               웹사이트 첫 화면
app.js / style.css       화면과 기능
config.js                Supabase 공개용 URL/API 키 설정
sw.js / manifest.webmanifest   홈 화면 추가·기본 오프라인 지원
assets/                  로고, 캐릭터, 아이콘, 호텔 사진
data/                    장소 CSV/JSON와 4일 시간표
supabase_setup.sql       가족 계정/RLS/개인 파일 저장 보안 정책
```

업로드나 로그인에서 막히면 **어느 단계, 어느 화면인지 캡처**해서 질문하면 다음 클릭을 안내할 수 있어요. 단, API 비밀키/Client Secret, 이메일 주소와 예약번호는 가려서 보내주세요.

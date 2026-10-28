# 🌿 Our Little Trip · 후쿠오카 & 벳푸 가족여행

2026년 10월 31일 ~ 11월 3일, 가족 4명이 사용하는 모바일 우선 여행 여권 PWA입니다.

## 바로 실행하기

1. 이 폴더 전체를 GitHub 저장소에 업로드합니다. **index.html**, **styles.css**, **app.js**, **data.js**, **assets/** 등을 삭제하거나 따로 분리하지 마세요.
2. GitHub → 저장소 **Settings → Pages → Deploy from a branch → main / (root)** 를 선택합니다.
3. 배포된 `https://<사용자>.github.io/<저장소>/` 주소를 휴대폰에서 엽니다.
4. iPhone Safari → 공유 → **홈 화면에 추가**를 선택하면 홈 화면 아이콘으로 실행할 수 있습니다.

> GitHub Pages는 HTTPS를 제공하므로 PWA 서비스 워커 오프라인 캐시가 활성화됩니다. 최초 접속 및 앱 업데이트에는 인터넷이 필요합니다. 지도 및 외부 링크는 오프라인에서 사용할 수 없습니다.

## 지금 사용 가능한 것 (별도 설정 불필요)

- 전체 화면/인덱스 7개: 여권, 주차장, 숙소, 관광 코스, 맛집, 토벌, 메모
- 동물의 숲(인간) / 먼작귀 4인씩 **최종 선택한 8개 캐릭터** 이미지
- 로컬 체험 모드에서 가족별 캐릭터 스타일 및 별명 선택
- 왕복 항공권 카드, 4일 일정, 일정 추가/수정/삭제 (체험 모드에서 '나' 선택 시)
- 대체 코스 뒤집기, 지역·이름별 검색, 장소 구글 지도/길찾기/검색 열기
- 가족 구성원별 준비물 체크리스트, 쇼핑 토벌 목록/체크/엔화 기록
- 로컬 메모, 영수증 이미지, 사진, 스티커 업로드 및 JSON 백업
- GitHub Pages에서 설치 가능한 모바일 PWA와 여행 정보 오프라인 캐시

**주의:** '로컬'이라는 글자가 나오면 모든 정보는 **그 브라우저의 저장 공간**에 보관됩니다. 다른 가족 기기와 동기화되지 않으며, 가족별 메모의 비밀 유지가 되지 않습니다. 각자 실제 Google 로그인 및 비공개 기록은 아래 Firebase 연결 후 가능합니다.

## Google 로그인과 가족별 동기화 활성화 (선택)

1. Firebase Console에서 프로젝트를 생성하고 **Authentication → Sign-in method → Google**을 활성화하세요.
2. **Authentication → Settings → Authorized domains**에서 실제 사용하는 `github.io` 호스트를 등록하세요. Firebase 프로젝트 웹 앱을 만들고 표시된 웹 설정 정보(apiKey, authDomain, projectId, storageBucket, appId)를 복사하세요.
3. 프로젝트의 **Cloud Firestore**와 **Cloud Storage**를 만듭니다. 가능하면 사용 지역을 여행이나 가족의 데이터 접근에 적절한 곳으로 선택하세요.
4. `firebase-config.js`의 `firebase: null`을 실제 웹 설정 객체로 교체합니다. `ownerEmail`은 여행 일정 수정 권한을 갖는 **나**의 Google 이메일, `familyEmails` 4개는 각각 아빠/엄마/언니/나 이메일로 교체합니다. 이메일 주소의 **대소문자를 통일**하세요.
5. `firestore.rules`, `storage.rules` 파일 안의 **OWNER_EMAIL_HERE, DAD_EMAIL_HERE, MOM_EMAIL_HERE, SISTER_EMAIL_HERE**를 위와 정확히 동일한 이메일로 교체하고 Firebase Console의 Firestore Rules 및 Storage Rules에 각각 붙여넣어 **게시**합니다. **임시 공개 규칙**으로 배포하지 마세요.
6. GitHub에 변경 사항을 올린 다음 새로고침하고, 각자 자신의 계정으로 로그인하세요. 일정을 수정할 수 있는 사람은 `ownerEmail` 사용자 한 명뿐입니다. 다른 가족은 자신의 아바타/메모를 편집할 수 있고, 준비물/쇼핑 체크를 공유할 수 있습니다.

Firebase 자체 이용 약관 및 무료 할당량/결제 정책은 프로젝트 설정 시 확인하세요. 별도 설정 없이는 Google 인증이나 실시간 동기화가 자동으로 되지 않습니다.

### Firestore 저장 범위

- `trips/fukuoka2026/shared/plan` : 가족 공통 일정 (소유자만 수정)
- `trips/fukuoka2026/shared/checks` : 가족별 준비물 체크 (가족 접근)
- `trips/fukuoka2026/shared/quest` : 방문·쇼핑·엔화 기록 (가족 공유)
- `trips/fukuoka2026/profiles/<email>` : 가족별 닉네임/아바타 (자기 것만 수정)
- `trips/fukuoka2026/private/<email>` : 자기 메모/사진 메타데이터 (본인만 접근)
- Firebase Storage `trips/fukuoka2026/users/<uid>/*` : 자신만 업로드/열람 가능한 사진 및 스티커 (다운로드 토큰 URL을 타인에게 공유하지 마세요)

## 데이터 범위 및 주의사항

제작 시 확인한 2026-10-28 후쿠오카·벳푸 확장 데이터 요약을 바탕으로 **맛집 기본 후보 24개, 쇼핑 18개, 관광 17개, 주차장 9개**를 우선 수록했습니다. 원래 대형 조사표의 모든 행을 포함한 것은 아닙니다. 실제 매장 정보는 변동될 수 있으므로 지도와 공식 사이트를 확인하세요. 특히 공항 렌터카 영업 방식, 숙소 주차 제휴 요금, 치이카와 팝업과 임시 휴업, 예약 및 4인 좌석을 현장에서 다시 확인해야 합니다.

일정 중 구체적 시간이 확정되지 않은 구간은 임의로 지어내지 않고 `오전`/`낮`/`오후`/`저녁`으로 표기했습니다. '나카스 마츠리'도 방문 후보이며 개최 확인을 뜻하지 않습니다.

## 수정 포인트

- 일정 / 항공권 / 숙소 / 장소 / 준비물: `data.js`
- 디자인 색상 · 레이아웃: `styles.css`
- 상호작용 · 저장: `app.js`
- 가족별 캐릭터 이미지: `assets/forest-*.webp`, `assets/chiikawa-*.webp`
- 오프라인 캐시 목록: `sw.js` (파일을 업데이트할 때 `CACHE` 버전을 올려 새 파일 캐시)

## 안전한 가족 사용 팁

공유 기기에서 체험 모드 메모는 보안이 없으므로 실제 사적인 내용을 입력하지 마세요. Firebase 로그인 후 공용 기기를 떠날 때는 로그아웃하고, 사진 다운로드 URL을 임의로 공유하지 마세요. 여행 후에는 계정 접근 권한과 보관할 사진/메모를 정리하면 좋아요.

Made with ♡ for our family.

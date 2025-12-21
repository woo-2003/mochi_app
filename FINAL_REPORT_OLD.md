# 모찌 (Mochi) 앱 개발 최종 보고서

**개발자**: 개인 개발  
**개발 기간**: 2025-11-13 ~ 2025-11-19  
**플랫폼**: Flutter (Android/iOS)  
**제출일**: 2025-11-19

---

## 목차

1. [앱 주제 및 핵심 기능 설명](#1-앱-주제-및-핵심-기능-설명)
2. [전체 화면 구성 요약 및 스크린샷](#2-전체-화면-구성-요약-및-스크린샷)
3. [사용 기술 및 패키지](#3-사용-기술-및-패키지)
4. [기능별 구현 상세 내용](#4-기능별-구현-상세-내용)
5. [역할 분담 및 팀원별 기여도](#5-역할-분담-및-팀원별-기여도)
6. [구현 중 문제와 해결 전략](#6-구현-중-문제와-해결-전략)
7. [회고 및 개선 아이디어](#7-회고-및-개선-아이디어)

---

## 1. 앱 주제 및 핵심 기능 설명

### 1.1 앱 주제

**모찌 (Mochi)**는 실시간 위치 기반 소셜 앱으로, 친구들과 현재 위치를 공유하고 상태 메시지를 통해 소통할 수 있는 서비스입니다. 사용자는 지도에서 친구들의 실시간 위치를 확인하고, AI가 추론한 상황별 상태 메시지를 통해 친구들의 현재 상황을 파악할 수 있습니다.

### 1.2 핵심 기능

#### 1.2.1 실시간 위치 공유
- GPS를 활용한 실시간 위치 추적
- Google Maps를 통한 지도 표시
- 커스텀 마커를 사용한 친구 위치 표시
- 내 위치로 빠르게 이동하는 기능

#### 1.2.2 AI 기반 상태 추론
- Google Gemini AI를 활용한 상황별 상태 메시지 생성
- 위치와 시간 정보를 기반으로 한 지능형 상태 추론
- 사용자가 직접 상태를 선택할 수 있는 기능

#### 1.2.3 실시간 채팅
- Firestore를 활용한 실시간 1:1 채팅
- 카카오톡 스타일의 세련된 메시지 UI
- 채팅 목록에서 마지막 메시지 미리보기

#### 1.2.4 친구 관리
- 연락처 기반 친구 찾기
- 친구 요청 및 수락 기능
- 친구 목록 관리

#### 1.2.5 소셜 로그인
- Google 로그인
- Kakao 로그인
- Firebase Authentication 연동

---

## 2. 전체 화면 구성 요약 및 스크린샷

### 2.1 화면 구성도

```
앱 실행
  ↓
[스플래시 스크린] (2초)
  ↓
[인증 게이트]
  ├─ 로그인 안됨 → [로그인 화면]
  │                    ├─ Google 로그인
  │                    └─ Kakao 로그인
  │
  └─ 로그인 됨 → [메인 네비게이터]
                    ├─ [지도 화면] (Tab 1)
                    │     ├─ Google Maps
                    │     ├─ 내 위치 마커
                    │     ├─ 친구 위치 마커
                    │     ├─ AI 추천 버튼
                    │     ├─ 상태 변경 버튼
                    │     └─ 내 위치로 이동 버튼
                    │
                    ├─ [채팅 목록 화면] (Tab 2)
                    │     └─ [채팅 화면]
                    │           ├─ 메시지 목록
                    │           └─ 메시지 입력
                    │
                    └─ [친구 목록 화면] (Tab 3)
                          ├─ 내 모찌 탭
                          ├─ 모찌 추가 탭
                          └─ 알림 탭
```

### 2.2 주요 화면 설명

#### 2.2.1 스플래시 스크린
- 앱 로고 표시
- 페이드 인/아웃 애니메이션
- 2초 후 자동으로 인증 게이트로 이동

#### 2.2.2 로그인 화면
- 앱 로고 표시
- Google 로그인 버튼
- Kakao 로그인 버튼
- 소셜 로그인을 통한 간편 인증

#### 2.2.3 지도 화면 (메인 화면)
- Google Maps 지도 표시
- 내 위치 커스텀 마커 (모찌 이미지)
- 친구 위치 커스텀 마커 (친구 마커 이미지)
- AI 상태 추천 버튼 (우측 하단)
- 상태 변경 버튼 (우측 하단)
- 내 위치로 이동 버튼 (좌측 하단)
- 프로필 버튼 (우측 상단)

#### 2.2.4 채팅 목록 화면
- 참여 중인 채팅방 목록
- 각 채팅방의 마지막 메시지 미리보기
- 최근 메시지 시간 표시
- 읽지 않은 메시지 배지

#### 2.2.5 채팅 화면
- 실시간 메시지 송수신
- 카카오톡 스타일 메시지 말풍선
- 메시지 전송 시간 표시
- 자동 스크롤 기능

#### 2.2.6 친구 목록 화면
- 내 모찌 탭: 추가한 친구 목록
- 모찌 추가 탭: 연락처 기반 친구 찾기
- 알림 탭: 친구 요청 알림

#### 2.2.7 마이페이지/설정 화면
- 프로필 정보 표시
- 공지사항 메뉴
- 친구 관리 메뉴
- 앱 정보 메뉴
- 로그아웃 버튼

---

## 3. 사용 기술 및 패키지

### 3.1 개발 환경

- **프레임워크**: Flutter 3.9.2+
- **언어**: Dart
- **개발 도구**: Android Studio, VS Code
- **버전 관리**: Git

### 3.2 주요 패키지

#### 3.2.1 Firebase 관련
```yaml
firebase_core: ^3.3.0          # Firebase 핵심
firebase_auth: ^5.1.2          # 인증 서비스
cloud_firestore: ^5.1.0        # 실시간 데이터베이스
firebase_messaging: ^15.1.3    # 푸시 알림 (FCM)
```

#### 3.2.2 인증 관련
```yaml
google_sign_in: ^6.2.1         # Google 로그인
kakao_flutter_sdk_user: ^1.9.0 # Kakao 로그인
```

#### 3.2.3 지도 및 위치
```yaml
google_maps_flutter: ^2.6.1    # Google Maps
geolocator: ^14.0.2            # GPS 위치 추적
geocoding: ^4.0.0              # 좌표 → 주소 변환
```

#### 3.2.4 AI 및 유틸리티
```yaml
google_generative_ai: ^0.4.4   # Google Gemini AI
intl: ^0.20.2                  # 날짜/시간 포맷팅
flutter_contacts: ^1.1.8       # 연락처 접근
```

#### 3.2.5 UI/UX
```yaml
provider: ^6.1.2               # 상태 관리
flutter_local_notifications: ^17.2.3 # 로컬 알림
```

#### 3.2.6 개발 도구
```yaml
flutter_launcher_icons: ^0.13.1 # 앱 아이콘 생성
```

### 3.3 아키텍처 패턴

- **상태 관리**: Provider 패턴
- **서비스 계층**: 싱글톤 패턴 (AuthService, DatabaseService, ChatService 등)
- **데이터 모델**: Firestore 문서를 Dart 객체로 변환
- **UI 구조**: Material Design 3 기반

---

## 4. 기능별 구현 상세 내용

### 4.1 인증 시스템

#### 4.1.1 Google 로그인
- `google_sign_in` 패키지를 사용하여 Google 계정으로 로그인
- Firebase Authentication과 연동
- 신규 사용자 자동 계정 생성
- 사용자 정보 Firestore에 저장

#### 4.1.2 Kakao 로그인
- `kakao_flutter_sdk_user` 패키지 사용
- 카카오톡 설치 여부에 따라 다른 로그인 방식 제공
- 카카오 ID를 Firebase 이메일로 변환하여 통합 인증
- 사용자 닉네임 자동 저장

#### 4.1.3 인증 게이트
- `StreamBuilder`를 사용하여 로그인 상태 실시간 감지
- 로그인 상태에 따라 자동 화면 전환
- 전화번호 등록 여부 확인 후 적절한 화면으로 라우팅

### 4.2 위치 추적 시스템

#### 4.2.1 LocationProvider 구현
- `geolocator` 패키지를 사용한 GPS 위치 추적
- 권한 요청 및 위치 서비스 활성화 확인
- 실시간 위치 스트림 구독
- 위치 변경 시 Firestore에 자동 업데이트

#### 4.2.2 지도 표시
- Google Maps API를 사용한 지도 렌더링
- 커스텀 마커 이미지 적용 (모찌, 친구 마커)
- 초기 위치로 자동 카메라 이동
- 안전한 카메라 이동 로직 (try-catch, mounted 체크)

#### 4.2.3 위치 기반 기능
- 내 위치로 이동 버튼
- 친구들의 실시간 위치 표시
- 위치 기반 AI 상태 추론

### 4.3 AI 상태 추론 시스템

#### 4.3.1 Gemini AI 연동
- Google Gemini Pro 모델 사용
- 위치(주소)와 시간 정보를 프롬프트로 제공
- 상황별 센스 있는 상태 메시지 생성
- 결과 정제 로직 (불필요한 문구 제거, 형식 통일)

#### 4.3.2 상태 메시지 형식
- "한글 3~6글자 + 이모지 1개" 형식
- 예시: "열일 중 🔥", "커피 수혈 ☕", "과제 폭파 중 💣"

#### 4.3.3 상태 변경 기능
- 사용자가 직접 상태 선택 가능
- 4가지 기본 상태: 굽기, 말랑, 단단, 꼬치
- 상태 변경 시 즉시 Firestore에 반영

### 4.4 채팅 시스템

#### 4.4.1 실시간 채팅 구현
- Firestore의 `chat_rooms/{roomId}/messages` 컬렉션 구조
- 두 사용자 간 고유 채팅방 ID 생성
- 실시간 메시지 송수신 (`StreamBuilder` 사용)
- 메시지 전송 시간 자동 기록

#### 4.4.2 채팅 UI
- 카카오톡 스타일 메시지 말풍선
- 내 메시지: 오른쪽, 보라색 배경
- 상대 메시지: 왼쪽, 회색 배경
- 메시지 전송 시간 표시
- 자동 스크롤 기능

#### 4.4.3 채팅 목록 동기화
- 채팅 목록의 마지막 메시지 실시간 업데이트
- 메시지 전송 시 채팅 목록에 즉시 반영
- 최근 메시지 시간 표시

### 4.5 친구 관리 시스템

#### 4.5.1 친구 찾기
- 연락처 접근 권한 요청
- 연락처의 전화번호와 Firestore 사용자 매칭
- 모찌에 가입한 친구와 미가입 친구 분류

#### 4.5.2 친구 요청
- 친구 요청 전송 기능
- 친구 요청 수락/거절 기능
- 트랜잭션을 사용한 안전한 친구 추가

#### 4.5.3 친구 목록
- 실시간 친구 목록 표시
- 친구의 현재 상태 메시지 표시
- 친구 클릭 시 채팅 화면으로 이동

### 4.6 UI/UX 디자인

#### 4.6.1 테마 및 브랜딩
- 메인 컬러: `#6C5CE7` (모찌 퍼플)
- AppBar: 플랫 디자인 (elevation: 0)
- Card: 둥근 모서리 (borderRadius: 16)
- 일관된 버튼 스타일

#### 4.6.2 Empty State
- 데이터가 없을 때 친절한 안내 메시지
- 아이콘과 설명을 포함한 재사용 가능한 위젯

#### 4.6.3 리스트 디자인
- Card 기반 리스트 아이템
- 프로필 이미지 테두리
- 읽지 않은 메시지 배지

---

## 5. 역할 분담 및 팀원별 기여도

### 5.1 개발 방식

본 프로젝트는 **개인 개발**로 진행되었습니다.

### 5.2 개발 범위

- 전체 아키텍처 설계 및 구현
- 모든 화면 UI/UX 디자인 및 구현
- Firebase 연동 및 데이터베이스 설계
- AI 연동 및 상태 추론 로직 구현
- 위치 추적 및 지도 기능 구현
- 채팅 시스템 구현
- 친구 관리 시스템 구현
- 테스트 및 디버깅

### 5.3 기여도

- **기획 및 설계**: 100%
- **프론트엔드 개발**: 100%
- **백엔드 설계 (Firestore)**: 100%
- **AI 연동**: 100%
- **UI/UX 디자인**: 100%
- **테스트 및 디버깅**: 100%

---

## 6. 구현 중 문제와 해결 전략

### 6.1 Firebase 초기 설정 문제

#### 문제
- `flutterfire` CLI 자동 앱 등록 실패
- Java 11 오류, npm 보안 정책 문제
- SHA-1 키 등록 위치 혼동

#### 해결 전략
- Firebase 콘솔에서 수동으로 앱 등록
- `.\gradlew signingReport`로 실제 SHA-1 키 추출
- Firebase 프로젝트 설정과 Google Cloud OAuth 클라이언트 양쪽에 등록
- 최신 `google-services.json` 파일 다운로드 및 적용

### 6.2 패키지 충돌 문제

#### 문제
- `location` 패키지와 `geocoding` 패키지의 클래스 이름 충돌
- `firebase_auth`와 `kakao_flutter_sdk_user`의 `User` 클래스 충돌

#### 해결 전략
- `location` 패키지를 `geolocator`로 완전 교체
- 카카오 SDK import에 `as kakao` 별칭 추가
- 모든 카카오 관련 클래스에 `kakao.` 접두사 사용

### 6.3 상태 관리 문제

#### 문제
- `setState() called during build` 오류
- `StreamBuilder`의 `builder` 내에서 상태 변경 시도

#### 해결 전략
- `setState` 로직을 모두 제거
- Reactive 방식으로 `StreamBuilder` 중첩 사용
- `builder`가 실행될 때마다 새로운 마커 세트 생성

### 6.4 지도 카메라 이동 타이밍 문제

#### 문제
- 앱 실행 시 카메라가 기본 위치에 먼저 표시됨
- 위치 로딩 전에 카메라 이동 시도로 인한 오류
- 지도 dispose 후 카메라 이동 시도로 `StateError` 발생

#### 해결 전략
- `_hasMovedToInitialLocation` 플래그 추가
- `WidgetsBinding.instance.addPostFrameCallback` 사용
- `try-catch` 블록으로 안전한 카메라 이동 처리
- `mounted` 및 `_mapController` null 체크

### 6.5 채팅 목록 동기화 문제

#### 문제
- 채팅 화면에서 메시지를 보내도 채팅 목록이 업데이트되지 않음
- 채팅 목록의 마지막 메시지가 실제 채팅의 마지막 메시지와 불일치

#### 해결 전략
- `ChatListScreen`을 `StatefulWidget`으로 변경
- 채팅방 데이터를 Map으로 관리하여 특정 채팅방만 업데이트
- `Navigator.push`의 결과를 받아서 마지막 메시지 업데이트
- AppBar 뒤로가기 버튼 커스터마이즈하여 결과 반환

### 6.6 데모 모드 메시지 전송 문제

#### 문제
- 데모 모드에서 메시지 전송이 불가능하여 부자연스러움
- SnackBar만 표시되고 실제 메시지가 추가되지 않음

#### 해결 전략
- `_demoMessages` 리스트를 상태로 관리
- 메시지 전송 시 `setState`로 즉시 화면에 표시
- `ScrollController`를 사용한 자동 스크롤 구현

---

## 7. 회고 및 개선 아이디어

### 7.1 프로젝트 회고

#### 7.1.1 잘된 점
- **체계적인 개발 과정**: 오퍼레이션 단위로 기능을 나누어 단계적으로 개발
- **코드 품질**: Provider 패턴 도입으로 비즈니스 로직과 UI 로직 분리
- **사용자 경험**: 실제 상용 앱 수준의 UI/UX 구현
- **문서화**: README에 모든 개발 과정을 상세히 기록

#### 7.1.2 아쉬운 점
- **테스트 코드 부재**: 단위 테스트 및 통합 테스트 미구현
- **에러 처리**: 일부 예외 상황에 대한 사용자 친화적 에러 메시지 부족
- **성능 최적화**: 이미지 캐싱, 리스트 가상화 등 최적화 여지
- **접근성**: 스크린 리더 지원 등 접근성 기능 미구현

### 7.2 개선 아이디어

#### 7.2.1 단기 개선 사항

1. **푸시 알림 개선**
   - 친구 요청 알림
   - 새 메시지 알림
   - 친구 위치 변경 알림 (선택적)

2. **프로필 이미지 업로드**
   - Firebase Storage를 사용한 이미지 업로드
   - 프로필 이미지 편집 기능

3. **그룹 채팅**
   - 여러 명과 동시에 채팅할 수 있는 그룹 채팅방
   - 그룹 초대 및 관리 기능

4. **위치 히스토리**
   - 친구의 위치 이동 경로 표시
   - 특정 시간대 위치 조회

5. **상태 메시지 커스터마이징**
   - 사용자 정의 상태 메시지 추가
   - 상태 메시지 템플릿 저장

#### 7.2.2 중장기 개선 사항

1. **AI 기능 강화**
   - 대화 내용 분석을 통한 상태 추론
   - 위치 패턴 학습을 통한 예측 기능
   - 개인화된 상태 메시지 추천

2. **소셜 기능 확장**
   - 친구 그룹 생성 및 관리
   - 위치 기반 이벤트 생성
   - 공개/비공개 위치 공유 설정

3. **성능 최적화**
   - 이미지 캐싱 및 압축
   - 리스트 가상화 (ListView.builder 최적화)
   - 오프라인 모드 지원

4. **보안 강화**
   - 위치 정보 암호화
   - 친구 요청 승인 프로세스 강화
   - 개인정보 보호 설정

5. **다국어 지원**
   - 영어, 일본어 등 다국어 지원
   - 지역별 시간대 자동 인식

#### 7.2.3 기술적 개선

1. **아키텍처 개선**
   - Clean Architecture 도입
   - Repository 패턴 적용
   - 의존성 주입 (get_it 등) 도입

2. **테스트 코드 작성**
   - Unit Test 작성
   - Widget Test 작성
   - Integration Test 작성

3. **CI/CD 파이프라인**
   - GitHub Actions를 사용한 자동 빌드
   - 자동 테스트 실행
   - 자동 배포

4. **모니터링 및 분석**
   - Firebase Analytics 연동
   - Crashlytics를 사용한 오류 추적
   - 사용자 행동 분석

### 7.3 학습한 점

1. **Flutter 상태 관리**: Provider 패턴을 통한 효율적인 상태 관리 방법 학습
2. **Firebase 연동**: Firestore를 활용한 실시간 데이터베이스 구현 경험
3. **AI 연동**: Google Gemini AI를 활용한 자연어 처리 경험
4. **지도 API**: Google Maps API를 활용한 위치 기반 서비스 구현
5. **소셜 로그인**: Google, Kakao 소셜 로그인 구현 경험
6. **UI/UX 디자인**: Material Design 3 기반의 현대적 UI 구현

### 7.4 결론

본 프로젝트를 통해 실시간 위치 기반 소셜 앱의 전체적인 구조와 구현 방법을 학습할 수 있었습니다. 특히 Firebase, AI, 지도 API 등 다양한 서비스를 통합하여 하나의 완성된 앱을 만드는 경험을 얻었습니다. 앞으로는 테스트 코드 작성, 성능 최적화, 보안 강화 등의 부분을 개선하여 더욱 완성도 높은 앱으로 발전시킬 계획입니다.

---

## 부록

### A. 프로젝트 구조

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── user_model.dart
│   └── chat_model.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── auth_gate.dart
│   │   ├── login_screen.dart
│   │   └── phone_verification_screen.dart
│   ├── map_screen.dart
│   ├── chat/
│   │   └── chat_screen.dart
│   ├── chat_list_screen.dart
│   ├── friends_list_screen.dart
│   ├── tabs/
│   │   └── friends/
│   │       ├── my_friends_tab.dart
│   │       ├── add_friend_tab.dart
│   │       └── friend_requests_tab.dart
│   ├── profile_screen.dart
│   └── main_navigator.dart
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── chat_service.dart
│   ├── gemini_service.dart
│   └── notification_service.dart
├── providers/
│   └── location_provider.dart
├── widgets/
│   ├── empty_state_widget.dart
│   ├── auth/
│   │   └── social_login_button.dart
│   └── chat/
│       └── message_bubble.dart
└── utils/
    ├── image_utils.dart
    └── marker_generator.dart
```

### B. 주요 데이터 모델

#### B.1 UserModel
```dart
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
}
```

#### B.2 ChatMessage
```dart
class ChatMessage {
  final String senderId;
  final String text;
  final Timestamp timestamp;
}
```

### C. Firestore 데이터베이스 구조

```
users/
  {uid}/
    - email
    - displayName
    - phoneNumber
    friends/
      {friendUid}/
        - addedAt

locations/
  {uid}/
    - position: GeoPoint
    - status: String
    - updatedAt: Timestamp

friend_requests/
  {requestId}/
    - fromUid
    - toUid
    - status: "pending" | "accepted" | "rejected"
    - createdAt

chat_rooms/
  {roomId}/
    messages/
      {messageId}/
        - senderId
        - text
        - timestamp
```

---

**보고서 작성 완료**

*본 보고서는 모찌 앱 개발 프로젝트의 전체 과정과 결과를 정리한 문서입니다.*


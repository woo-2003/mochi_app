# '모찌 (Mochi)' 앱 개발 프로젝트

본 프로젝트는 Flutter를 사용한 실시간 위치 기반 소셜 앱 '모찌'의 MVP를 개발하는 것을 목표로 합니다.

## [오퍼레이션 1: 스켈레톤] (2025-11-13)

### 작업 내용

1.  **프로젝트 생성:** `flutter create mochi`
2.  **폴더 구조:** `lib` 내에 `screens`, `widgets`, `models` 폴더를 생성하여 기본 아키텍처를 잡았습니다.
3.  **메인 네비게이터:** 3개의 하단 탭(지도, 채팅, 친구)을 가진 `main_navigator.dart`를 `lib/screens`에 생성했습니다.
4.  **임시 화면:** `MapScreen`, `ChatListScreen`, `FriendsListScreen` 3개의 빈 화면을 생성하고 네비게이터에 연결했습니다.
5.  **앱 진입점:** `main.dart`에서 `MainNavigator`를 `home`으로 지정하여 앱 실행 시 3-탭 UI가 보이도록 설정했습니다.

## [오퍼레이션 2: 로그인 관문] (2025-11-13)

### 작업 내용

1.  **화면/위젯 분리:** `auth` 관련 스크린과 위젯을 위한 폴더를 `lib/screens`와 `lib/widgets` 내부에 신설했습니다.
2.  **로그인 버튼:** 재사용 가능한 `SocialLoginButton` 위젯을 `lib/widgets/auth`에 생성했습니다. (임시 아이콘 사용)
3.  **로그인 화면:** '모찌' 임시 로고와 2개의 소셜 로그인 버튼(Google, Kakao)을 포함한 `LoginScreen`을 `lib/screens/auth`에 생성했습니다.
4.  **진입점 수정:** `main.dart`의 `home`을 `MainNavigator`에서 `LoginScreen`으로 변경하여, 앱 실행 시 로그인 화면이 가장 먼저 나타나도록 수정했습니다.
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

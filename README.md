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

## [오퍼레이션 3: 점화] (2025-11-13)

### 작업 내용

1.  **Firebase 프로젝트 생성:** 웹 콘솔에서 'Mochi' Firebase 프로젝트를 생성했습니다.
2.  **FlutterFire CLI 연동:** `flutterfire configure` 실행 및 Firebase 콘솔 '수동' 앱 등록, SHA-1 키 등록 준비 완료.
3.  **핵심 패키지 설치:** `firebase_core`, `firebase_auth`, `google_sign_in` 패키지를 `pubspec.yaml`에 추가했습니다. (이 작업으로 `firebase_options.dart` 오류 해결)
4.  **Firebase 초기화:** `main.dart`에서 `Firebase.initializeApp()`을 호출하여, 앱 실행 시 Firebase 서비스가 준비되도록 수정했습니다.
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 4: Google 로그인 구현] (2025-11-13)

### 작업 내용

1.  **난관 봉착:** `flutterfire`의 자동 앱 등록 실패, `Java 11` 오류, `npm` 보안 정책, `firebase-tools` 및 `login` 누락, `SHA-1` 키 등록 위치 혼동, `google-services.json` 비동기화, 윈도우 `개발자 모드` 비활성화 등 모든 초기 설정 장애물을 해결함.
2.  **핵심 설정 완료:**
    * Firebase 콘솔에서 'Mochi' 앱을 '수동' 등록함.
    * `.\gradlew signingReport`로 '진짜' `debug SHA-1` 키를 추출하여, `Firebase 프로젝트 설정`과 `Google Cloud OAuth 클라이언트` 양쪽에 '이중 등록' 완료함.
    * Firebase에서 '최신' `google-services.json` 파일을 다운로드하여 프로젝트에 '덮어쓰기'함.
3.  **SHA-1 키 등록:** Android `signingReport`에서 `debug`용 SHA-1 키를 추출하여 Firebase 콘솔에 '수동' 등록했습니다.
4.  **Google 제공업체 활성화:** Firebase Authentication에서 'Google' 로그인 제공업체를 활성화했습니다.
5.  **인증 서비스:** `lib/services/auth_service.dart` 파일을 생성, `signInWithGoogle()` 메서드를 구현하여 Google SDK와 Firebase Auth를 연동하는 핵심 로직을 작성했습니다.
6.  **로그인 화면 연동:** `LoginScreen`을 `StatefulWidget`으로 변경하고, 'Google' 버튼을 눌렀을 때 `AuthService`를 호출하도록 로직을 연결했습니다.
7.  **로딩/화면전환:** 로그인 시도 시 로딩 인디케이터를 표시하고, 성공 시 `MainNavigator`로 `pushReplacement`하는 UX를 구현했습니다.
8.  **성공:** Google 로그인 팝업 -> 계정 선택 -> **로그인 성공 후 `MainNavigator` (지도 화면)로 자동 전환**되는 것을 확인함.
9.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 5: 데이터베이스 연결] (2025-11-13)

### 작업 내용

1.  **Firestore 활성화:** Firebase 콘솔에서 'Firestore Database'를 '테스트 모드' 및 '서울 리전'으로 생성했습니다.
2.  **패키지 설치:** `cloud_firestore` 패키지를 `pubspec.yaml`에 추가했습니다.
3.  **DB 서비스:** `DatabaseService`를 생성, `saveUser` 메서드를 구현했습니다. 이 메서드는 '신규' 유저일 경우에만 'users' 컬렉션에 `uid`를 문서 ID로 하여 유저 정보를 저장합니다.
4.  **Auth 서비스 연동:** `AuthService`의 `signInWithGoogle` 로직을 수정하여, Google 로그인 성공 시 `DatabaseService.saveUser`를 호출하도록 로직을 추가했습니다.
5.  **[MultiDex 활성화]** 'cloud_firestore' 추가로 인한 65k 메서드 제한을 해결하기 위해, `android/app/build.gradle.kts` 파일에 `multiDexEnabled = true` 설정을 추가함.
6.  **[Firestore DB]** 'users' 컬렉션에 사용자 생성 확인.
7.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 6: 인증 게이트] (2025-11-13)

### 작업 내용

1.  **AuthGate 생성:** `authStateChanges()` 스트림을 구독하는 `StreamBuilder` 기반의 `AuthGate` 위젯을 생성했습니다.
2.  **게이트 로직:** 로그인 상태에 따라 '로딩', '지도 화면(MainNavigator)', '로그인 화면(LoginScreen)'을 자동으로 보여주도록 라우팅 로직을 구현했습니다.
3.  **진입점 변경:** `main.dart`의 `home`을 `AuthGate`로 변경하여, 앱 실행 시 인증 게이트가 가장 먼저 실행되도록 수정했습니다.
4.  **로그아웃 기능:** 테스트를 위해 `AuthService`에 `signOut()` 메서드를 추가했습니다. (Google/Firebase 동시 로그아웃)
5.  **로그아웃 버튼(UI):** `MapScreen`의 `AppBar`에 로그아웃 테스트용 버튼 UI를 추가했습니다.
6.  **로그아웃 기능 연결:** `MapScreen`의 AppBar에 로그아웃 버튼 UI를 추가하고, `onPressed`에 `AuthService.signOut()`을 '연결'하여 로그아웃 기능을 '완성'함. (로그아웃 버튼 클릭 시 AuthGate가 자동으로 로그인 화면으로 라우팅하는 것을 확인함)
7.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 7: 친구 수첩] (2025-11-16)

### 작업 내용

1.  **폴더 구조:** `lib/screens/tabs/friends` 폴더를 신설하여, '친구' 탭의 하위 화면들을 분리했습니다.
2.  **하위 탭 생성:** `MyFriendsTab`, `AddFriendTab`, `FriendRequestsTab` 3개의 임시 탭 화면을 생성했습니다.
3.  **TabBar 구현:** `FriendsListScreen`을 `StatefulWidget`으로 변경하고, `TabController`와 `TabBarView`를 사용하여 3개의 하위 탭을 가진 인터페이스를 완성했습니다. (3개 탭 전환 및 애니메이션이 정상 작동하는 것을 확인함)
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 8 (수정): 연락처 패키지 교체] (2025-11-16)

### 작업 내용

1.  **문제 발견:** `contacts_service` 패키지(`v0.6.3`)가 4년 전 업데이트가 중단되어, 최신 안드로이드 빌드 시스템의 'Namespace' 요구사항과 호환되지 않는 치명적 오류를 발견함.
2.  **전략 수정:** 기존 `contacts_service`와 `permission_handler` 패키지를 '폐기'함.
3.  **패키지 교체:** 유지보수가 잘 되고 권한 처리가 내장된 `flutter_contacts` 패키지로 '교체' 설치함.
4.  **권한 수정:** `AndroidManifest.xml`에 `WRITE_CONTACTS` 권한을 추가함.
5.  **로직 수정:** `AddFriendTab` 화면의 로직을 `flutter_contacts`의 `requestPermission()` 및 `getContacts()` 메서드를 사용하도록 전면 수정함. (권한 팝업이 정상 작동하고 연락처 리스트가 표시되는 것을 확인함)
6.  **[치명적 버그 수정]** AAPT 빌드 오류: `<uses-permission>` 태그가 `<application>` 내부에 잘못 위치했던 문제를 수정함. 모든 권한 태그를 `<manifest>`의 최상위 레벨로 이동시켜 빌드 오류를 해결함.
7.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 9: 전화번호 수집] (2025-11-16)

### 작업 내용

1.  **Firestore 색인:** `users` 컬렉션의 `phoneNumber` 필드는 '단일 필드'로 Firebase가 '자동' 색인함을 확인함. (별도 콘솔 작업 불필요)
2.  **전화번호 화면:** 신규 사용자의 전화번호를 입력받는 `PhoneVerificationScreen` UI를 생성했습니다.
3.  **DB 서비스 수정:** `checkIfUserHasPhoneNumber` (확인), `savePhoneNumber` (저장) 메서드를 `DatabaseService`에 추가했습니다.
4.  **AuthGate 수정:** `StreamBuilder` (로그인)와 `FutureBuilder` (DB 확인)를 '중첩'하여, 신규 사용자가 `PhoneVerificationScreen`을 강제로 거치도록 라우팅 로직을 전면 수정했습니다.
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

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

## [오퍼레이션 4.5: 카카오 로그인] (2025-11-19)

### 작업 내용

1.  **패키지 설치:** `kakao_flutter_sdk_user: ^1.9.0` 패키지를 추가하여 카카오 SDK를 연동했습니다.
2.  **SDK 초기화:** `main.dart`에서 `KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY')`를 호출하여 카카오 SDK를 초기화했습니다. (주의: `nativeAppKey`는 팀장님이 직접 입력해야 함)
3.  **Android 설정:** `AndroidManifest.xml`에 카카오 로그인을 위한 `AuthCodeCustomTabsActivity`를 추가하여 Redirect URI를 처리하도록 설정했습니다.
4.  **인증 서비스 구현:** `AuthService`에 `signInWithKakao()` 메서드를 구현했습니다. 이 메서드는 다음 로직을 수행합니다:
    * 카카오톡 설치 여부 확인 (`isKakaoTalkInstalled()`)
    * 설치되어 있으면 `loginWithKakaoTalk()`, 없으면 `loginWithKakaoAccount()` 호출
    * 로그인 성공 시 `UserApi.instance.me()`로 사용자 정보(ID, 이메일, 닉네임) 가져오기
    * 카카오 ID를 이용해 가짜 이메일(`kakao_{id}@mochi.app`)과 비밀번호 생성
    * `FirebaseAuth`로 `signInWithEmailAndPassword` 시도 (실패 시 `createUserWithEmailAndPassword`로 계정 생성)
    * `DatabaseService.saveUser` 호출하여 카카오 닉네임 저장
5.  **로그인 화면 연결:** `LoginScreen`의 카카오 버튼 `onPressed`에 `signInWithKakao()` 로직을 연결했습니다.
6.  **키 해시 확인:** `LoginScreen`의 `initState`에 `KakaoSdk.origin` 출력 코드를 추가하여 키 해시 확인이 가능하도록 구현했습니다.
7.  **로그아웃 개선:** `signOut()` 메서드에 카카오 로그아웃 로직을 추가했습니다.
8.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 4.6: 카카오 로그인 버그 수정] (2025-11-19)

### 작업 내용

1.  **Import 충돌 해결:** `firebase_auth`와 `kakao_flutter_sdk_user` 패키지 모두 `User` 클래스를 가지고 있어서 발생한 이름 충돌(Ambiguous import)을 해결하기 위해 `kakao_flutter_sdk_user` import에 `as kakao` 별칭을 추가했습니다.
2.  **코드 수정:** 모든 카카오 관련 클래스 사용 시 `kakao.` 접두사를 붙이도록 수정했습니다:
    * `UserApi` -> `kakao.UserApi`
    * `User` (카카오 유저) -> `kakao.User`
    * `KakaoException` -> `kakao.KakaoException`
3.  **API 변경 대응:** `isKakaoTalkInstalled()` 메서드가 `UserApi`에서 제거되어 전역 함수로 변경된 것을 확인하고, `kakao.isKakaoTalkInstalled()`로 수정했습니다.
4.  **불필요한 코드 제거:** `unused_local_variable` 경고가 뜬 `token`, `email` 변수를 제거했습니다.
5.  **Null-aware 연산자 수정:** `invalid_null_aware_operator` 경고가 뜬 `?.` 연산자를 `.`으로 수정했습니다.
6.  **로그인 로직 개선:** Firebase의 에러 메시지 변경으로 인해 신규 유저가 `signInWithEmailAndPassword` 실패 후 `createUserWithEmailAndPassword`로 넘어가지 못하는 문제를 해결했습니다. 에러 코드 확인 없이 로그인 실패 시 무조건 회원가입을 시도하도록 `try-catch` 로직을 수정했습니다.
7.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

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
4.  **AuthGate 수정:** `StreamBuilder` (로그인)와 `FutureBuilder` (DB 확인)를 '중첩'하여, 신규 사용자가 `PhoneVerificationScreen`을 강제로 거치도록 라우팅 로직을 전면 수정했습니다. (전화번호 입력/저장 후 자동으로 메인 화면으로 이동하는 것을 확인함)
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 10: 친구 찾기 로직] (2025-11-16)

### 작업 내용

1.  **DB 서비스 수정:** `DatabaseService`에 `findFriendsFromContacts` 메서드를 추가했습니다. 이 메서드는 'phoneNumber' 리스트를 받아 `whereIn` 쿼리로 'users' 컬렉션을 검색합니다.
2.  **'모찌 추가' 탭 수정:** `_loadContacts` 로직을 전면 수정했습니다.
    * A) `flutter_contacts`로 모든 연락처를 가져옵니다.
    * B) 전화번호 목록을 추출하여 `findFriendsFromContacts`를 호출합니다.
    * C) DB 결과와 연락처를 비교하여, `_foundMochiFriends`와 `_contactsToInvite` 두 개의 리스트로 분류합니다.
3.  **UI 수정:** `AddFriendTab`의 `body`를 "모찌에 가입한 친구" 섹션과 "초대하기" 섹션으로 나누어 표시하도록 UI를 전면 수정했습니다. (UI 분리 확인)
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 11: 친구 요청] (2025-11-16)

### 작업 내용

1.  **UserModel 생성:** `users` 컬렉션 데이터를 Dart 객체로 다루기 위해 `lib/models/user_model.dart`를 생성했습니다.
2.  **AuthService 수정:** `AuthService.currentUser` getter를 추가하여 현재 로그인한 유저의 `uid`에 쉽게 접근할 수 있도록 수정했습니다.
3.  **DB 서비스 수정:**
    * `findFriendsFromContacts`가 `List<UserModel>`을 반환하도록 리팩토링했습니다.
    * `friend_requests` 컬렉션에 'pending' 상태의 요청 문서를 생성하는 `sendFriendRequest` 메서드를 '신규' 구현했습니다.
4.  **'모찌 추가' 탭 수정:** `[친구 추가]` 버튼을 눌렀을 때, `sendFriendRequest`가 호출되도록 `onPressed` 로직을 '연결'했습니다.
5.  **[버그 수정]** '자기 자신'에게 친구 요청을 보내는 오류를 수정함: (1) `findFriendsFromContacts` 쿼리 결과에서 '자기 자신'의 uid를 필터링 (2) `sendFriendRequest` 메서드에 'fromUid == toUid' 방어 로직 추가 (3) `saveUser` 메서드에서 `displayName` 기본값('Mochi User') 설정. (버그 수정 성공 확인)
6.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 12: 알림 탭] (2025-11-16)

### 작업 내용

1.  **DB 서비스 수정:** '나에게 온 보류 중인' 친구 요청을 실시간(`Stream`)으로 감지하는 `getFriendRequests` 메서드를 구현했습니다. 또한, `uid`로 사용자 정보를 가져오는 `getUserProfile` 메서드를 추가했습니다.
2.  **'알림' 탭 수정:** `FriendRequestsTab`에 `StreamBuilder` (요청 목록)와 `FutureBuilder` (요청자 정보)를 '중첩'하여, '나에게' 친구 요청을 보낸 사람의 '이름'이 목록에 뜨도록 UI를 구현했습니다.
3.  **UI 추가:** 요청 목록에 `[수락]` / `[거절]` 버튼 UI를 추가했습니다. (기능 미연결)
4.  **[버그 수정]** '알림' 탭에서 존재하지 않는 `fromUid`를 조회할 때 `null` 충돌이 발생하던 문제를 수정함: (1) `getUserProfile`이 `UserModel?` (Nullable)을 반환하도록 수정. (2) `FutureBuilder`에서 `null` 체크 로직을 추가하여 '알 수 없는 사용자'로 안전하게 표시함. ('알 수 없는 사용자' 테스트 성공)
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 13: 친구 수락] (2025-11-16)

### 작업 내용

1.  **보안 규칙 적용:** Firestore '규칙' 탭을 수정하여, 'users', 'friend_requests', 'users/{userId}/friends' 하위 컬렉션에 대한 '본인'만 수정 가능한 보안 규칙을 적용했습니다.
2.  **트랜잭션 구현:** `DatabaseService`에 `acceptFriendRequest` 메서드를 추가했습니다. 이 메서드는 '트랜잭션'을 사용하여 3가지 작업(요청 상태 변경, 내 친구 목록 추가, 상대 친구 목록 추가)을 '안전하게' 동시에 처리합니다.
3.  **'알림' 탭 연결:** `[수락]` 버튼의 `onPressed:`에 `acceptFriendRequest` 로직을 '연결'했습니다.
4.  **테스트:** '보안 규칙' 적용까지만 기록하고, '테스트'는 (Op 14로) 건너뛰었음.
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 14: "내 모찌" 탭] (2025-11-16)

### 작업 내용

1.  **테스트 시뮬레이션:** '친구 수락' UI 테스트가 'null' 사용자로 인해 교착 상태에 빠져, Firestore 콘솔에서 '수동'으로 `users/{내 uid}/friends/{fake_friend_abc}` 문서를 생성하여 '친구 수락'이 성공했다고 '가정'함.
2.  **DB 서비스 수정:** `users/{uid}/friends` 하위 컬렉션을 실시간(`Stream`)으로 읽어오는 `getMyFriendsStream` 메서드를 구현했습니다.
3.  **'내 모찌' 탭 수정:** `MyFriendsTab`에 `StreamBuilder` (친구 목록)와 `FutureBuilder` (친구 상세 정보)를 '중첩'하여, '나의 친구' 목록이 이름과 전화번호와 함께 표시되도록 UI를 구현했습니다.
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 15: "Hello, Map!"] (2025-11-17)

### 작업 내용

1.  **패키지 설치:** `google_maps_flutter: ^2.6.1` 패키지를 `pubspec.yaml`에 추가했습니다.
2.  **Android API 키 설정:** `AndroidManifest.xml`에 Google Maps API 키를 위한 `meta-data`를 추가했습니다. (주의: `"YOUR_API_KEY_HERE"` 부분을 팀장님이 복사한 실제 API 키로 수정해야 함)
3.  **Android Gradle 확인:** `build.gradle.kts`에서 `minSdkVersion`이 `flutter.minSdkVersion`으로 설정되어 있음을 확인했습니다. (Google Maps는 최소 SDK 21이 필요하며, Flutter 기본값이 21 이상이므로 문제 없음)
4.  **지도 화면 수정:** `MapScreen`을 `StatefulWidget`으로 변경하고, `GoogleMap` 위젯을 추가하여 서울 시청 근처를 초기 위치로 하는 지도를 표시하도록 구현했습니다. (지도 렌더링 성공)
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 16: "내 위치 찾기"] (2025-11-17)

### 작업 내용

1.  **권한 설정:** `AndroidManifest.xml`에 `ACCESS_FINE_LOCATION` 및 `ACCESS_COARSE_LOCATION` 권한 2줄을 추가했습니다.
2.  **패키지 설치:** `location` 패키지를 `pubspec.yaml`에 추가했습니다.
3.  **'지도' 탭 수정:** `MapScreen`의 `initState`에서 `location` 패키지를 사용해 'GPS 권한'과 '서비스'를 요청하도록 로직을 추가했습니다.
4.  **카메라 이동:** 권한이 허용되면, '현재 GPS 위치'를 가져와 `GoogleMapController.animateCamera`를 호출하여 지도를 '내 위치'로 이동시켰습니다. (GPS 팝업, 카메라 이동 성공)
5.  **UI 수정:** `GoogleMap` 위젯에 `myLocationEnabled: true` (파란 점)와 `myLocationButtonEnabled: true` 옵션을 활성화했습니다.
6.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 17: "실시간 위치 공유"] (2025-11-17)

### 작업 내용

1.  **Firestore 규칙:** `locations` 컬렉션에 '본인 쓰기 / 인증자 읽기' 보안 규칙을 '추가'했습니다.
2.  **DB 서비스 수정:** `locations` 컬렉션에 `uid`를 문서 ID로 하여 `GeoPoint`와 `Timestamp`를 '덮어쓰는(set)' `updateUserLocation` 메서드를 구현했습니다.
3.  **'지도' 탭 수정:** `MapScreen`이 `location.onLocationChanged` 스트림을 '구독(listen)'하도록 수정했습니다. GPS 위치가 변경될 때마다 `updateUserLocation`을 호출하여 '내 위치'를 Firestore에 실시간으로 공유합니다. (locations 컬렉션 생성 성공)
4.  **배터리 최적화:** `dispose()` 메서드에서 `_locationSubscription.cancel()`을 호출하여, 화면이 꺼지면 GPS 구독을 중지하도록 구현했습니다.
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 18 (수정): "Reactive 친구 마커"] (2025-11-17)

### 작업 내용

1.  **[치명적 버그 수정]** `setState() called during build`: `StreamBuilder`의 `builder` 함수 내에서 `setState`를 호출하여 발생한 ANR(앱 응답 없음) 오류를 수정했습니다.
2.  **로직 전면 수정:** `MapScreen`에서 `setState` 로직을 '전부 제거'했습니다.
3.  **Reactive UI:** `StreamBuilder` (친구 목록) 안에 `StreamBuilder` (친구 위치)를 중첩하는 'Reactive' 방식으로 변경했습니다.
4.  **마커 렌더링:** '친구 위치' `StreamBuilder`의 `builder`가 '실행될 때마다' `Set<Marker>`를 '새로' 생성하여 `GoogleMap` 위젯에 전달, '자동'으로 UI가 갱신되도록 수정했습니다.
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 19: "커스텀 마커 & 상태 표시"] (2025-11-19)

### 작업 내용

1.  **마커 생성 유틸리티:** `MarkerGenerator` 클래스를 생성하여 `PictureRecorder`와 `Canvas`를 사용해 이모지와 텍스트를 결합한 커스텀 마커 비트맵을 실시간으로 생성하는 로직을 구현했습니다.
2.  **지도 화면 수정:** 기본 '빨간 핀' 대신, 친구의 '상태(이모지)'와 '이름'이 보이는 커스텀 마커를 지도에 표시하도록 `MapScreen`을 수정했습니다.
3.  **DB 서비스 수정:** `updateUserLocation` 메서드에서 `status` 필드가 누락되어 있을 경우 기본값 '☁️ 말랑 (수신 대기)'를 저장하도록 수정했습니다.
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 20: "의도 휠" (상태 변경)] (2025-11-19)

### 작업 내용

1.  **상태 옵션 정의:** '굽기', '말랑', '단단', '꼬치' 4가지 상태를 이모지와 함께 정의했습니다.
2.  **상태 변경 로직:** 상태 선택 시 `_currentStatus` 변수를 갱신하고, 즉시 `DatabaseService.updateUserLocation`을 호출하여 Firestore에 동기화하는 로직을 구현했습니다.
3.  **UI 구현:** `FloatingActionButton`을 통해 현재 상태를 표시하고, 클릭 시 `showModalBottomSheet`로 상태 선택창을 띄우도록 구현했습니다. (이미지 자산 없이 네이티브 위젯 사용)
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 21: "실시간 채팅"] (2025-11-19)

### 작업 내용

1.  **데이터 모델:** `ChatMessage` 모델과 `chat_rooms > messages` 하위 컬렉션 구조를 설계했습니다.
2.  **채팅 서비스:** 두 사용자 간의 고유 방 ID 생성, 메시지 전송/수신(Stream), 채팅방 목록 로드(Stream) 기능을 `ChatService`에 구현했습니다.
3.  **UI 구현:**
    * `ChatScreen`: 실시간 메시지 수신 및 전송 UI.
    * `MyFriendsTab`: 친구 목록에서 바로 채팅으로 연결되는 버튼 추가.
    * `ChatListScreen`: 참여 중인 채팅방 목록 및 마지막 메시지 표시.
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 22: "모찌의 뇌" (Gemini AI 연동)] (2025-11-19)

### 작업 내용

1.  **패키지 설치:** `google_generative_ai: ^0.4.4` 패키지를 추가하여 Google Gemini AI SDK를 연동했습니다.
2.  **AI 서비스 구현:** `AIService` 클래스를 생성하여 현재 위치(위도/경도)와 시간을 기반으로 사용자 상태를 추천하는 `suggestStatus` 메서드를 구현했습니다. Gemini Pro 모델을 사용하여 4가지 상태(굽기, 말랑, 단단, 꼬치) 중 하나를 추천합니다.
3.  **UI 구현:** `MapScreen`에 AI 추천 버튼(`FloatingActionButton.small`)을 추가하고, 클릭 시 현재 위치를 가져와 AI 추천을 받은 후 다이얼로그로 결과를 표시하며, 사용자가 원하면 상태를 즉시 변경할 수 있도록 구현했습니다.
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 23: 채팅 UI 리마스터] (2025-11-19)

### 작업 내용

1.  **패키지 설치:** `intl: ^0.19.0` 패키지를 추가하여 날짜 및 시간 포맷팅 기능을 제공했습니다.
2.  **MessageBubble 위젯 생성:** `lib/widgets/chat/message_bubble.dart` 파일을 생성하여 카카오톡 스타일의 세련된 메시지 말풍선 위젯을 구현했습니다. 내 메시지는 오른쪽에 보라색(`Colors.deepPurple`), 상대 메시지는 왼쪽에 회색(`Colors.grey[300]`)으로 표시되며, 카카오톡처럼 특정 모서리만 직각으로 처리했습니다.
3.  **시간 표시:** `intl` 패키지의 `DateFormat`을 사용하여 메시지 전송 시간을 '오후 2:30' 형식으로 말풍선 바깥쪽 하단에 표시하도록 구현했습니다.
4.  **프로필 사진:** 상대방 메시지의 경우 말풍선 왼쪽에 작은 `CircleAvatar`를 표시하도록 구현했습니다. (이미지가 없으면 기본 아이콘 표시)
5.  **채팅 화면 수정:** `ChatScreen`의 기존 투박한 `ListTile` 기반 UI를 제거하고, 새로운 `MessageBubble` 위젯을 사용하도록 전면 수정했습니다. 넉넉한 패딩을 적용하여 보기 편한 UI로 개선했습니다.
6.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 23.5: 버그 수정] (2025-11-19)

### 작업 내용

1.  **로케일 초기화:** `intl` 패키지 사용 시 'Locale data has not been initialized' 오류를 해결하기 위해 `main.dart`에 `initializeDateFormatting('ko_KR', null)` 호출을 추가했습니다.
2.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 24: "푸시 알림 (FCM)"] (2025-11-19)

### 작업 내용

1.  **패키지 설치:** `firebase_messaging: ^15.1.3`과 `flutter_local_notifications: ^17.2.3` 패키지를 추가하여 Firebase Cloud Messaging (FCM) 기능을 연동했습니다.
2.  **알림 서비스 구현:** `lib/services/notification_service.dart` 파일을 생성하여 `NotificationService` 클래스를 구현했습니다. 이 서비스는 다음 기능을 제공합니다:
    * 알림 권한 요청 (`requestPermission`)
    * 포그라운드 메시지 핸들러 (앱 실행 중 알림 수신 및 로컬 알림 표시)
    * 백그라운드 메시지 핸들러 (`_firebaseMessagingBackgroundHandler` - top-level 함수로 선언)
    * 알림 탭 핸들러 (앱이 백그라운드에 있을 때 알림 탭 처리)
    * FCM 토큰 가져오기 및 출력 (테스트용)
3.  **앱 진입점 수정:** `main.dart`에서 `NotificationService.instance.initialize()`와 `NotificationService.instance.getToken()`을 호출하여 앱 시작 시 알림 서비스를 초기화하고 FCM 토큰을 콘솔에 출력하도록 구현했습니다.
4.  **로컬 알림 설정:** `flutter_local_notifications`를 사용하여 앱이 실행 중일 때 FCM 메시지를 받으면 상단 알림을 표시하도록 구현했습니다.
5.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 25: 구조 리팩토링 - Provider 도입] (2025-11-19)

### 작업 내용

1.  **패키지 설치:** `provider: ^6.1.2` 패키지를 `pubspec.yaml`에 추가하여 상태 관리 패턴을 도입했습니다.
2.  **LocationProvider 생성:** `lib/providers/location_provider.dart` 파일을 생성하여 위치 관련 비즈니스 로직을 분리했습니다. 이 Provider는 다음 기능을 제공합니다:
    * GPS 권한 요청 및 위치 서비스 활성화
    * 실시간 위치 스트림 구독 및 관리
    * 위치 변경 시 Firestore에 자동 업데이트 (`_updateLocation`)
    * 현재 상태(`_currentStatus`) 관리 및 변경
    * `ChangeNotifier`를 상속하여 위치 변경 시 `notifyListeners()` 호출
3.  **Main 등록:** `lib/main.dart`에서 `MultiProvider`로 `MyApp`을 감싸고, `ChangeNotifierProvider<LocationProvider>`를 등록하여 앱 전역에서 위치 상태를 관리할 수 있도록 설정했습니다.
4.  **MapScreen 리팩토링:** `lib/screens/map_screen.dart`를 수정하여 내부의 위치 관리 로직을 모두 제거하고, 대신 `Provider.of<LocationProvider>` 또는 `Consumer<LocationProvider>`를 사용하여 위치 데이터를 구독하도록 변경했습니다. 주요 변경 사항:
    * `Location` 인스턴스 및 위치 스트림 구독 제거
    * `_requestLocationPermissionAndMoveCamera` 메서드 제거
    * 상태 변경 로직을 Provider의 `changeStatus` 메서드로 위임
    * AI 추천 시 위치는 Provider에서 가져오도록 수정
    * 카메라 이동은 Provider의 위치 데이터를 사용
5.  **코드 품질 향상:** 비즈니스 로직과 UI 로직의 분리로 코드 가독성 및 유지보수성이 크게 향상되었습니다.
6.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 26: 초기 카메라 위치 개선] (2025-11-19)

### 작업 내용

1.  **상태 변수 추가:** `MapScreen`에 `_isFirstLocationLoaded` 변수를 추가하여 앱 실행 후 처음으로 위치를 잡았는지 체크하도록 구현했습니다.
2.  **자동 카메라 이동 로직:** `build` 메서드 내의 `Consumer<LocationProvider>`에서 위치가 로딩되면 자동으로 사용자의 현재 위치로 카메라를 이동시키는 로직을 추가했습니다:
    * `locationProvider.currentLocation`이 `null`이 아니고
    * `_isFirstLocationLoaded`가 `false`일 때만 카메라 이동
    * 이동 후 `_isFirstLocationLoaded = true`로 설정하여 계속 따라다니지 않도록 함
3.  **onMapCreated 콜백 개선:** `GoogleMapController`가 생성된 시점에 위치가 이미 로딩되어 있다면 즉시 카메라를 이동하도록 `_onMapCreated` 메서드를 수정했습니다.
4.  **초기 줌 레벨 설정:** 카메라 이동 시 줌 레벨을 `15.5`로 설정하여 적당한 확대/축소 수준을 제공합니다.
5.  **UX 개선:** 앱 실행 시 기본 좌표(서울 시청)를 먼저 보여주던 문제를 해결하여, 사용자의 실제 위치가 로딩되면 자동으로 해당 위치로 이동하도록 개선했습니다.
6.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 26.5: 컴파일 에러 수정] (2025-11-19)

### 작업 내용

1.  **타입 불일치 해결:** `_moveCameraToLocation` 함수에서 `LocationData` 타입을 찾을 수 없는 컴파일 에러를 해결하기 위해 `geolocator` 패키지의 `Position` 타입으로 변경했습니다.
2.  **Import 추가:** `lib/screens/map_screen.dart` 파일에 `import 'package:geolocator/geolocator.dart';`와 `import 'package:location/location.dart';`를 추가했습니다.
3.  **타입 변환 헬퍼 메서드:** `LocationProvider`가 반환하는 `LocationData` 타입을 `Position` 타입으로 변환하는 `_locationDataToPosition` 헬퍼 메서드를 추가했습니다.
4.  **함수 시그니처 변경:** `_moveCameraToLocation` 함수의 매개변수 타입을 `LocationData`에서 `Position`으로 변경하고, `latitude`, `longitude` 속성 사용 방식을 유지했습니다.
5.  **호출부 수정:** `_onMapCreated`와 `Consumer` 내부에서 `LocationData`를 `Position`으로 변환한 후 `_moveCameraToLocation` 함수에 전달하도록 수정했습니다.
6.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 27: 커스텀 마커 적용 - 1단계] (2025-11-19)

### 작업 내용

1.  **pubspec.yaml 설정:** `lib/assets/images/marker_mochi.png` 파일을 assets 섹션에 등록하여 앱에서 사용할 수 있도록 설정했습니다.
2.  **이미지 유틸리티 생성:** `lib/utils/image_utils.dart` 파일을 생성하여 에셋 이미지를 Google Maps 마커로 사용할 수 있도록 변환하는 `getBytesFromAsset` 함수를 구현했습니다:
    * 에셋 이미지 경로와 원하는 너비를 받아서 `BitmapDescriptor`로 변환
    * 이미지 크기를 조절할 수 있도록 `targetWidth` 매개변수 사용
    * `dart:ui`와 `flutter/services`를 사용하여 이미지 로드 및 변환
3.  **MapScreen 수정 (내 마커 적용):** `lib/screens/map_screen.dart`에서 현재 사용자의 위치를 표시하는 마커에 커스텀 이미지를 적용했습니다:
    * `_myLocationIcon` 변수를 추가하여 마커 아이콘을 저장
    * `initState`에서 `_loadMyLocationIcon()` 메서드를 호출하여 마커 아이콘을 미리 로드 (비동기 처리)
    * `_buildMyLocationMarker` 메서드를 추가하여 현재 사용자 위치 마커를 생성
    * 모든 `GoogleMap` 위젯에서 `myLocationEnabled: false`로 변경하여 기본 파란 점 제거
    * 현재 사용자 위치 마커를 `markers` 세트에 추가하여 커스텀 이미지 마커 표시
    * 마커 크기는 110픽셀로 설정 (100~120 범위)
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 28: 패키지 교체 - location → geolocator] (2025-11-19)

### 작업 내용

1.  **LocationProvider 전면 수정:** `lib/providers/location_provider.dart`를 `geolocator` 패키지만 사용하도록 리팩토링했습니다:
    * `location` 패키지 import 제거, `geolocator` 패키지만 사용
    * `LocationData` 타입을 모두 `Position` 타입으로 변경
    * `Location` 객체 대신 `Geolocator` 클래스의 static 메서드 사용:
      * `Geolocator.isLocationServiceEnabled()` - GPS 서비스 활성화 확인
      * `Geolocator.checkPermission()` - 위치 권한 확인
      * `Geolocator.requestPermission()` - 위치 권한 요청
      * `Geolocator.getCurrentPosition()` - 현재 위치 가져오기
      * `Geolocator.getPositionStream()` - 실시간 위치 스트림 구독
    * `Geolocator.distanceBetween()` 사용하여 거리 계산 로직 간소화
    * `StreamSubscription<LocationData>` → `StreamSubscription<Position>` 변경
    * 모든 메서드의 매개변수 및 반환 타입을 `Position`으로 통일
2.  **DatabaseService 수정:** `lib/services/database_service.dart`의 `updateUserLocation` 메서드를 수정했습니다:
    * `LocationData` import 제거, `geolocator` 패키지 import 추가
    * `updateUserLocation` 메서드의 매개변수를 `LocationData`에서 `Position`으로 변경
    * `latitude`, `longitude` 접근 시 null 체크 제거 (Position은 항상 값이 있음)
3.  **MapScreen 수정:** `lib/screens/map_screen.dart`에서 `LocationData` 사용 부분을 제거했습니다:
    * `location` 패키지 import 제거
    * `_locationDataToPosition` 헬퍼 메서드 제거 (더 이상 필요 없음)
    * `LocationProvider.currentLocation`이 이제 `Position?`을 반환하므로 직접 사용
    * 모든 null 체크 로직 간소화 (`Position`은 항상 `latitude`, `longitude` 값이 있음)
4.  **pubspec.yaml 정리:** `location` 패키지 의존성 제거
5.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **타입 안정성 향상:** `Position` 타입은 항상 유효한 좌표값을 보장하므로 null 체크 로직이 간소화되었습니다.
*   **코드 간소화:** `Geolocator.distanceBetween()` 사용으로 거리 계산 로직이 더 간결해졌습니다.
*   **패키지 충돌 해결:** `location` 패키지와 `geocoding` 패키지의 클래스 이름 충돌(Ambiguous import) 문제가 해결되었습니다.
*   **일관성:** 앱 전체에서 `geolocator` 패키지만 사용하여 위치 관련 로직이 통일되었습니다.

## [오퍼레이션 29: 지도 카메라 이동 안정성 개선] (2025-11-19)

### 작업 내용

1.  **상태 변수 개선:** `lib/screens/map_screen.dart`에서 카메라 이동 상태 관리 개선:
    * `_isFirstLocationLoaded` → `_hasMovedToInitialLocation`으로 변수명 변경 (의도 명확화)
2.  **안전한 카메라 이동 함수:** `_moveCameraToLocation` → `_moveCameraToPosition`으로 함수명 변경 및 안전성 강화:
    * `mounted` 및 `_mapController` null 체크 추가
    * `try-catch` 블록으로 `StateError` 방지 (지도 dispose 후 호출 시에도 안전)
3.  **타이밍 이슈 해결 (Race Condition 방지):**
    * `build` 메서드에서 `WidgetsBinding.instance.addPostFrameCallback` 사용하여 화면 렌더링 완료 후 카메라 이동
    * `mounted` 및 `_hasMovedToInitialLocation` 이중 체크로 중복 이동 방지
    * `onMapCreated` 콜백에서도 위치 데이터가 이미 있으면 즉시 이동하도록 처리
4.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **안정성 향상:** 지도가 dispose된 후에도 `StateError`가 발생하지 않도록 안전하게 처리
*   **타이밍 개선:** Race Condition 방지로 카메라 이동이 안정적으로 동작
*   **명확성:** 변수명과 함수명이 의도를 명확히 표현

## [오퍼레이션 30: AI 프롬프트 강화 - 상태 메시지 개선] (2025-11-19)

### 작업 내용

1.  **프롬프트 전면 개선:** `lib/services/gemini_service.dart`의 `guessActivity` 메서드 프롬프트를 강화했습니다:
    * **페르소나 설정:** "너는 한국인들이 일상에서 자주 쓰는 센스 있고 유쾌한 상태 메시지 작성기야."로 명확히 정의
    * **입력 정보 구조화:** 위치와 시간을 명확히 구분하여 제공
    * **요청사항 구체화:**
      * 딱딱한 표현("업무 중", "이동 중") 지양
      * 어린 표현("수업 째기") 지양
      * 누구나 공감할 수 있는 위트 있는 표현 사용
      * 형식: "한글 3~6글자 + 이모지 1개" (이 포맷만 출력)
    * **상황별 예시 제공:**
      * 회사/오피스: "열일 중 🔥", "월급 루팡 🤫"
      * 식당/번화가: "맛집 탐방 😋", "배에 기름칠 🍖"
      * 공원/산책로: "광합성 중 🌿", "힐링 타임 ✨"
      * 집 + 밤/주말: "이불 밖 위험 🛌", "넷플릭스 🍿"
      * 카페: "커피 수혈 ☕", "여유 만끽 🍰"
      * 헬스장: "득근 득근 💪"
      * 기타 상황별 예시 포함
2.  **결과 정제 로직 개선:**
    * 추가 패턴 제거 ("상태 메시지:", "상태:", "추천:" 등)
    * 결과 길이 검증 추가 (15자 초과 시 기본값 반환)
3.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **사용자 경험 향상:** "활동 중" 같은 단조로운 응답 대신, 모든 연령대가 공감할 수 있는 위트 있는 상태 메시지 생성
*   **맥락 이해 개선:** 위치와 시간 정보를 더 효과적으로 활용하여 상황에 맞는 메시지 생성
*   **일관성:** 프롬프트 형식과 예시를 명확히 제공하여 AI 응답의 일관성 향상

## [오퍼레이션 31: 시연용 데모 모드 구현] (2025-11-19)

### 작업 내용

1.  **데모 친구 마커 생성:** `lib/screens/map_screen.dart`에 `_buildDemoFriendsMarkers()` 메서드를 추가하여 시연 영상 촬영을 위한 가상 친구 3명을 지도에 표시했습니다:
    * **미소**: 성결대학교 학술정보관 근처 (37.3805, 126.9265) - "과제 폭파 중 💣"
    * **성결**: 성결대학교 운동장 벤치 (37.3795, 126.9275) - "농구 한 판? 🏀"
    * **공대**: 학교 앞 카페 (37.3810, 126.9255) - "아아 수혈 시급 ☕"
2.  **모든 마커에 데모 친구 추가:** 지도의 모든 `markers` Set 생성 지점에 데모 친구 마커를 추가하여 항상 표시되도록 구현
3.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **시연 준비:** 실제 친구가 없어도 앱의 기능을 시연할 수 있는 환경 구성
*   **일관성:** 지도에 항상 4개의 마커(나 + 친구 3명)가 표시되어 꽉 찬 느낌 제공

## [오퍼레이션 32: 마커 디자인 구분 - 나와 친구 마커 분리] (2025-11-19)

### 작업 내용

1.  **아이콘 상태 변수 추가:** `lib/screens/map_screen.dart`에 친구 마커 아이콘을 저장하는 `BitmapDescriptor? _friendMarkerIcon;` 변수 추가
2.  **이미지 로딩 로직 수정:**
    * `_loadMyLocationIcon()` → `_loadMarkerIcons()`로 메서드명 변경
    * `marker_mochi.png` → `_myLocationIcon`에 저장 (내 위치 마커)
    * `marker_friend.png` → `_friendMarkerIcon`에 저장 (친구 마커)
    * 두 이미지를 모두 비동기로 로드
3.  **마커 적용:**
    * '나(me)' 마커: `icon: _myLocationIcon` 사용
    * 데모 친구들(미소, 성결, 공대) 마커: `icon: _friendMarkerIcon` 사용
4.  **pubspec.yaml 업데이트:** `marker_friend.png`를 assets에 등록
5.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **시각적 구분:** 지도에서 내 위치와 친구 위치를 마커 디자인으로 명확히 구분 가능
*   **일관성:** 모든 친구 마커가 동일한 디자인을 사용하여 통일감 제공

## [오퍼레이션 33: 데모 데이터 동기화 - 친구 목록 및 채팅 목록] (2025-11-19)

### 작업 내용

1.  **친구 목록 화면 수정:** `lib/screens/tabs/friends/my_friends_tab.dart`에 데모 친구 3명 추가:
    * `_getDemoFriends()` 메서드 추가: 미소, 성결, 공대의 이름, 상태 메시지, 전화번호 데이터
    * 각 친구의 ListTile 구성:
      * **Leading**: `CircleAvatar` (보라색 배경, 흰색 person 아이콘)
      * **Title**: 이름 (미소, 성결, 공대)
      * **Subtitle**: 상태 메시지 (지도와 동일: "과제 폭파 중 💣", "농구 한 판? 🏀", "아아 수혈 시급 ☕")
      * **Trailing**: 위치 아이콘 (`Icons.location_on`, 빨간색)
    * 데모 친구는 항상 먼저 표시되고, 실제 친구가 있으면 그 다음에 표시
    * 데모 친구 클릭 시 SnackBar로 데모 모드 안내
2.  **채팅 목록 화면 수정:** `lib/screens/chat_list_screen.dart`에 데모 채팅방 3개 추가:
    * `_getDemoChatRooms()` 메서드 추가: 미소, 성결, 공대와의 데모 채팅방 데이터
    * 각 채팅방의 ListTile 구성:
      * **Leading**: `CircleAvatar` (보라색 배경, 흰색 person 아이콘)
      * **Title**: 이름 (미소, 성결, 공대)
      * **Subtitle**: 최근 대화 내용 ("야 어디야?", "밥 먹었어?", "지금 가는 중")
      * **Trailing**: 최근 시간 ("방금", "10분 전", "30분 전")
    * 데모 채팅방은 항상 먼저 표시되고, 실제 채팅방이 있으면 그 다음에 표시
    * 데모 채팅방 클릭 시 SnackBar로 데모 모드 안내
3.  **데이터 통일성:** MapScreen의 데모 친구 이름과 상태 메시지와 동일하게 설정하여 사용자가 탭을 이동해도 동일한 친구 데이터를 인지할 수 있도록 구성
4.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **일관성:** 지도, 친구 목록, 채팅 목록 화면에서 동일한 데모 친구 3명(미소, 성결, 공대)이 표시되어 시연 영상 촬영에 적합
*   **사용자 경험:** 실제 친구가 없어도 앱의 모든 기능을 시연할 수 있는 환경 제공
*   **데이터 동기화:** 모든 화면에서 동일한 이름과 상태 메시지를 사용하여 일관된 사용자 경험 제공

## [오퍼레이션 34: 시연용 대본(Scenario) 모드 구현] (2025-11-19)

### 작업 내용

1.  **목록 정리:** `ChatListScreen`과 `FriendsScreen`에서 '테스트친구' 데이터를 완전히 삭제하고, 오직 '미소', '성결', '공대' 3명만 남기도록 수정했습니다.
2.  **채팅방 내부 구현:** `lib/screens/chat/chat_screen.dart`에 데모 친구별 대화 기록을 하드코딩하여 표시하도록 구현했습니다:
    * **미소**: 과제 관련 대화 4개 ("야 과제 다 했냐?", "아니.. 교수님 진짜 너무하심 ㅠㅠ", "오늘 밤새야겠네 ㅋㅋ 도서관 ㄱ?", "이미 자리 잡음. 빨리 와라")
    * **성결**: 농구 약속 대화 3개 ("오늘 날씨 좋은데 농구 콜?", "콜. 몇 시에 모임?", "3시에 운동장으로 와. 애들 다 모임")
    * **공대**: 카페인 부족 대화 3개 ("살려줘... 카페인 부족해", "나 지금 학교 앞 카페임. 아아 사갈까?", "너는 진짜 천사다 😇 사이즈 업 부탁")
3.  **데모 모드 감지:** `_isDemoFriend` getter를 추가하여 데모 친구인지 확인하고, 데모 친구의 경우 하드코딩된 대화 기록을 표시하도록 구현했습니다.
4.  **메시지 전송 처리:** 데모 친구와의 채팅에서는 실제 메시지 전송 대신 SnackBar로 안내 메시지를 표시하도록 수정했습니다.
5.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **시연 준비:** 실제 친구와의 채팅이 없어도 앱의 채팅 기능을 시연할 수 있는 환경 구성
*   **현실감:** 각 데모 친구별로 상황에 맞는 자연스러운 대화 기록 제공

## [오퍼레이션 35: Firebase 연동 일시 중지 및 데모 데이터 강제 적용] (2025-11-19)

### 작업 내용

1.  **ChatListScreen 수정:** `lib/screens/chat_list_screen.dart`를 전면 수정했습니다:
    * `StreamBuilder` 제거 (Firebase 연동 일시 중지)
    * `ListView.builder`를 사용하여 하드코딩된 데모 채팅방 3개만 표시
    * 각 채팅방 데이터: 이름, 마지막 메시지, 시간
    * 클릭 시 `ChatScreen`으로 이동하며 각 이름에 맞는 대본이 표시됨
2.  **FriendsScreen 수정:** `lib/screens/tabs/friends/my_friends_tab.dart`를 전면 수정했습니다:
    * `StreamBuilder` 제거 (Firebase 연동 일시 중지)
    * `ListView.builder`를 사용하여 하드코딩된 데모 친구 3명만 표시
    * 각 친구 데이터: 이름, 상태 메시지, 전화번호
    * 아이콘은 `assets/images/marker_friend.png` 사용
3.  **목표 달성:** Firebase에 무슨 데이터가 있든 상관없이, 화면에는 오직 데모 친구 3명(미소, 성결, 공대)만 깔끔하게 표시되도록 구현
4.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **시연 안정성:** Firebase 데이터와 무관하게 일관된 데모 환경 제공
*   **예측 가능성:** 시연 영상 촬영 시 항상 동일한 데이터가 표시되어 안정적인 시연 가능

## [오퍼레이션 36: UI/UX Phase 1 구현 - 스플래시, 앱 아이콘, 마이페이지] (2025-11-19)

### 작업 내용

1.  **앱 아이콘 설정:** `pubspec.yaml`에 `flutter_launcher_icons` 패키지를 추가하고 설정 코드를 작성했습니다:
    * 이미지 경로: `assets/images/app_icon.png`
    * Android/iOS 모두 지원
    * 필요한 에셋을 assets에 등록
2.  **스플래시 스크린 구현:** `lib/screens/splash_screen.dart`를 생성했습니다:
    * 중앙에 `splash_logo.png` 이미지 표시 (width: 200)
    * 페이드 인/아웃 애니메이션 적용 (2초)
    * 배경색: 흰색 (`Colors.white`)
    * 2초 후 자동으로 `AuthGate`로 이동
    * `main.dart`의 `home`을 `SplashScreen`으로 변경
3.  **마이페이지 구현:** `lib/screens/profile_screen.dart`를 생성했습니다:
    * **AppBar**: 타이틀 "설정", 뒤로가기 버튼
    * **상단**: 프로필 이미지 (`profile_placeholder.png`) + 이름 + 이메일
    * **중단**: 공지사항, 친구 관리, 앱 정보 (v1.0.0) ListTile
    * **하단**: 로그아웃 버튼 (빨간색 텍스트, 중앙 정렬)
    * 로그아웃 기능 연결 (확인 다이얼로그 포함)
4.  **지도 화면 연결:** `MapScreen`의 AppBar 우측에 원형 프로필 버튼 추가:
    * `profile_placeholder.png` 이미지 사용
    * 클릭 시 `ProfileScreen`으로 네비게이션
    * 기존 로그아웃 버튼 제거
5.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **브랜딩:** 앱 실행 시 스플래시 스크린으로 브랜드 인지도 향상
*   **사용자 경험:** 마이페이지를 통해 사용자 정보 확인 및 설정 관리 가능
*   **일관성:** 앱 전체에서 프로필 이미지가 통일되게 표시

## [오퍼레이션 37: UI/UX Phase 2 구현 - 테마 브랜딩 및 Empty State UI 개선] (2025-11-19)

### 작업 내용

1.  **테마 및 스타일 통일:** `lib/main.dart`의 `ThemeData`를 전면 수정했습니다:
    * **메인 컬러**: `Color(0xFF6C5CE7)` (Deep Purple 계열 - 모찌 퍼플)
    * **AppBar**: 배경색 흰색, 타이틀 검은색, `elevation: 0` (플랫 디자인), 아이콘 색상 검은색
    * **BottomNavigationBar**: 선택된 아이템은 메인 컬러, 비선택은 회색
    * **ElevatedButton**: 메인 컬러 배경, 둥근 모서리 (`BorderRadius.circular(12)`)
    * **FloatingActionButton**: 메인 컬러 배경 (테마 추가)
    * **Card**: `borderRadius: 16`, `elevation: 2`, 여백 적용
2.  **EmptyStateWidget 생성:** `lib/widgets/empty_state_widget.dart`를 생성했습니다:
    * 아이콘 또는 이미지, 제목, 설명을 표시하는 재사용 가능한 위젯
    * 이미지 로드 실패 시 아이콘으로 대체
3.  **FriendsScreen 디자인 개선:** `lib/screens/tabs/friends/my_friends_tab.dart` 수정:
    * ListTile을 Card로 감싸서 입체감 추가
    * Card `borderRadius: 16` 적용
    * 프로필 이미지에 메인 컬러 테두리 추가
    * Empty State 적용 (친구가 없을 때)
4.  **ChatListScreen 디자인 개선:** `lib/screens/chat_list_screen.dart` 수정:
    * ListTile을 Card로 감싸서 입체감 추가
    * Card `borderRadius: 16` 적용
    * `contentPadding` 여백 적용
    * 마지막 메시지 시간을 작고 회색 폰트로 표시
    * 읽지 않은 메시지 배지 표시
    * Empty State 적용 (채팅방이 없을 때)
5.  **ProfileScreen 메뉴 아이콘:** 메뉴 리스트 아이콘에 메인 컬러 적용
6.  **BottomNavigationBar 개선:** 선택된 아이템에 `activeIcon` 추가 (아이콘 채움 효과)
7.  **MapScreen FloatingActionButton:** AI 추천 버튼 배경색을 메인 컬러로 변경
8.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **브랜드 통일성:** 앱 전체에 모찌 퍼플(`#6C5CE7`) 브랜드 컬러가 통일감 있게 적용
*   **현대적 디자인:** 리스트 UI가 카드형 디자인으로 개선되어 시각적 완성도 향상
*   **사용자 경험:** Empty State 위젯으로 데이터가 없을 때도 친절한 안내 제공

## [오퍼레이션 38: '내 위치로 이동' FloatingActionButton 추가] (2025-11-19)

### 작업 내용

1.  **버튼 추가:** `lib/screens/map_screen.dart`에 '내 위치로 이동' FloatingActionButton을 추가했습니다:
    * **위치**: 화면 좌측 하단 (`Positioned` 위젯 사용, `left: 16`, `bottom: 80`)
    * **디자인**:
      * 배경색: `Theme.of(context).primaryColor` (모찌 퍼플 `#6C5CE7`)
      * 아이콘: `Icons.my_location` (흰색)
      * 모양: `CircleBorder()` (둥근 원형)
      * `heroTag: 'my_location_btn'` (기존 FAB와 충돌 방지)
2.  **기능 구현:**
    * 버튼 클릭 시 `LocationProvider`의 `currentLocation`을 사용하여 카메라 이동
    * `_moveCameraToPosition` 메서드 활용 (기존 메서드 재사용)
    * 현재 위치가 null인 경우 사용자에게 SnackBar로 알림 표시
    * `_mapController` null 체크 포함
3.  **구조 개선:**
    * `body`를 `Stack`으로 감싸서 지도 위에 버튼 오버레이
    * 기존 우측 하단 FAB들(AI 버튼, 상태 변경 버튼)과 겹치지 않도록 좌측 하단에 배치
4.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **사용자 경험 향상:** 지도 탐색 후 버튼 한 번 클릭으로 현재 위치로 복귀 가능
*   **직관적 UI:** 좌측 하단에 배치하여 기존 FAB들과 충돌 없이 접근성 향상
*   **안정성:** null 체크 및 예외 처리로 안전한 동작 보장

## [오퍼레이션 39: 채팅 기능 개선 - 메시지 전송 및 동기화] (2025-11-19)

### 작업 내용

1.  **채팅 목록과 실제 채팅 화면 동기화:** `lib/screens/chat_list_screen.dart`를 `StatefulWidget`으로 변경하여 채팅방 데이터를 상태로 관리하도록 수정했습니다:
    * `_demoChatRooms`를 Map으로 관리하여 특정 채팅방의 마지막 메시지만 업데이트 가능
    * 채팅 목록의 마지막 메시지를 실제 `ChatScreen`의 마지막 메시지와 일치하도록 수정
2.  **데모 모드에서 메시지 전송 가능:** `lib/screens/chat/chat_screen.dart`를 수정하여 데모 모드에서도 메시지 전송이 가능하도록 구현했습니다:
    * `_demoMessages` 리스트를 상태로 관리하여 메시지 추가/삭제 가능
    * 메시지 전송 시 즉시 화면에 표시되도록 `setState` 사용
    * 자동 스크롤 기능 추가 (`ScrollController` 사용)
3.  **채팅 목록 실시간 업데이트:** 채팅 화면에서 메시지를 보내고 뒤로가기를 누르면 채팅 목록이 자동으로 업데이트되도록 구현했습니다:
    * `ChatScreen`의 AppBar 뒤로가기 버튼을 커스터마이즈하여 내가 보낸 마지막 메시지 정보를 반환
    * `ChatListScreen`에서 `Navigator.push`의 결과를 받아서 `_updateLastMessage`로 업데이트
    * 시간은 "방금"으로 자동 변경
4.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **사용자 경험 향상:** 채팅 화면에서 메시지를 보내면 채팅 목록에 즉시 반영되어 실제 상용 앱 수준의 UX 제공
*   **데이터 일관성:** 채팅 목록의 마지막 메시지가 실제 채팅 화면의 마지막 메시지와 항상 일치
*   **자연스러운 동작:** 데모 모드에서도 실제 앱처럼 메시지 전송 및 표시가 자연스럽게 동작

## [오퍼레이션 40: '내 위치로 이동' 버튼 위치 조정] (2025-11-19)

### 작업 내용

1.  **버튼 위치 변경:** `lib/screens/map_screen.dart`의 '내 위치로 이동' FloatingActionButton 위치를 조정했습니다:
    * 우측 하단 → 좌측 하단으로 이동 (`right: 16` → `left: 16`)
    * 기존 우측 하단의 AI 추천 버튼 및 상태 변경 버튼과 겹치지 않도록 배치
    * `bottom: 80`으로 설정하여 BottomNavigationBar 위에 표시
2.  **주석:** 모든 변경 사항에 한국어 주석을 추가했습니다.

### 기술적 개선 사항

*   **사용자 경험 향상:** 버튼들이 겹치지 않아 클릭하기 쉬워짐
*   **직관적 UI:** 좌측 하단에 '내 위치로 이동' 버튼이 배치되어 접근성 향상

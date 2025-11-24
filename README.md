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

## [오퍼레이션 15: "Hello, Map!"] (2025-11-16)

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

## [오퍼레이션 20: "의도 휠" (상태 변경)] (2025-11-19)

### 작업 내용

1.  **상태 옵션 정의:** '굽기', '말랑', '단단', '꼬치' 4가지 상태를 이모지와 함께 정의했습니다.
2.  **상태 변경 로직:** 상태 선택 시 `_currentStatus` 변수를 갱신하고, 즉시 `DatabaseService.updateUserLocation`을 호출하여 Firestore에 동기화하는 로직을 구현했습니다.
3.  **UI 구현:** `FloatingActionButton`을 통해 현재 상태를 표시하고, 클릭 시 `showModalBottomSheet`로 상태 선택창을 띄우도록 구현했습니다. (이미지 자산 없이 네이티브 위젯 사용)
4.  **주석:** 모든 신규 코드에 한국어 주석을 추가했습니다.

## [오퍼레이션 19: "커스텀 마커 & 상태 표시"] (2025-11-19)

### 작업 내용

1.  **마커 생성 유틸리티:** `MarkerGenerator` 클래스를 생성하여 `PictureRecorder`와 `Canvas`를 사용해 이모지와 텍스트를 결합한 커스텀 마커 비트맵을 실시간으로 생성하는 로직을 구현했습니다.
2.  **지도 화면 수정:** 기본 '빨간 핀' 대신, 친구의 '상태(이모지)'와 '이름'이 보이는 커스텀 마커를 지도에 표시하도록 `MapScreen`을 수정했습니다.
3.  **DB 서비스 수정:** `updateUserLocation` 메서드에서 `status` 필드가 누락되어 있을 경우 기본값 '☁️ 말랑 (수신 대기)'를 저장하도록 수정했습니다.
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

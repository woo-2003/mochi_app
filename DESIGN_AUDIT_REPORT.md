# Mochi 앱 UI/UX 디자인 감사 보고서

**작성일**: 2025-11-19  
**목적**: 실제 스토어 출시 수준의 퀄리티 점검 및 개선 제안

---

## 1. 필수 화면 누락 점검

### ❌ 1.1 스플래시 스크린 (Splash Screen)
**현재 상태**: 미구현
- `main.dart`에서 바로 `AuthGate`로 이동
- Android/iOS 네이티브 스플래시는 기본 흰색 배경만 있음
- 앱 로고나 브랜딩 요소 없음

**개선 제안**:
- **우선순위: 높음**
- `lib/screens/splash_screen.dart` 생성
- 앱 로고 이미지 표시 + 페이드 인 애니메이션
- Firebase 초기화 완료 후 자동으로 `AuthGate`로 이동
- Android/iOS 네이티브 스플래시에도 로고 이미지 추가

**필요한 에셋**:
- `lib/assets/images/logo_mochi.png` (1024x1024px 권장)
- `lib/assets/images/logo_mochi_white.png` (다크 모드용)

---

### ❌ 1.2 마이페이지/설정 화면 (Profile/Settings)
**현재 상태**: 미구현
- `MapScreen`에 로그아웃 버튼만 있음
- 사용자 프로필 정보 표시 화면 없음
- 설정 메뉴 없음

**개선 제안**:
- **우선순위: 높음**
- `lib/screens/profile_screen.dart` 생성
- **구성 요소**:
  - 프로필 이미지 (CircleAvatar)
  - 사용자 이름, 이메일, 전화번호 표시
  - 설정 메뉴 리스트:
    - 내 정보 수정
    - 알림 설정
    - 위치 권한 설정
    - 앱 정보 (버전 등)
    - 로그아웃
- `MainNavigator`에 4번째 탭으로 추가하거나, `MapScreen` AppBar에 프로필 아이콘 추가

**필요한 에셋**:
- 기본 프로필 이미지 플레이스홀더: `lib/assets/images/profile_placeholder.png`

---

### ⚠️ 1.3 앱 아이콘 (Launcher Icon)
**현재 상태**: 기본 Flutter 아이콘 사용 중
- Android: `android/app/src/main/res/mipmap-*/ic_launcher.png` (기본)
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (기본)

**개선 제안**:
- **우선순위: 중간**
- 커스텀 앱 아이콘 디자인 필요
- `flutter_launcher_icons` 패키지 사용 권장

**필요한 에셋**:
- `lib/assets/images/app_icon.png` (1024x1024px, 투명 배경)
- 또는 각 플랫폼별 사이즈별 아이콘 세트

---

## 2. UI/UX 디테일 점검

### ⚠️ 2.1 Empty State (빈 상태)
**현재 상태**: 텍스트만 표시
- 친구 없음: `Text('아직 추가된 모찌가 없습니다.')`
- 채팅 없음: `Text('채팅방이 없습니다. 친구와 채팅을 시작해보세요!')`
- 메시지 없음: `Text('메시지가 없습니다. 메시지를 보내보세요!')`

**개선 제안**:
- **우선순위: 중간**
- 각 Empty State에 일러스트 이미지 추가
- 친근한 안내 문구와 함께 CTA(행동 유도) 버튼 추가

**필요한 에셋**:
- `lib/assets/images/empty_friends.png` (친구 없음 일러스트)
- `lib/assets/images/empty_chat.png` (채팅 없음 일러스트)
- `lib/assets/images/empty_messages.png` (메시지 없음 일러스트)

**예시 UI 구조**:
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Image.asset('lib/assets/images/empty_friends.png', width: 200),
    SizedBox(height: 16),
    Text('아직 추가된 모찌가 없습니다.', style: TextStyle(fontSize: 16)),
    SizedBox(height: 8),
    ElevatedButton(
      onPressed: () => /* 친구 추가 화면으로 이동 */,
      child: Text('친구 추가하기'),
    ),
  ],
)
```

---

### ⚠️ 2.2 Loading State (로딩 상태)
**현재 상태**: 기본 `CircularProgressIndicator`만 사용
- 모든 로딩 화면에서 동일한 스타일 사용
- 스켈레톤 UI 없음

**개선 제안**:
- **우선순위: 낮음** (시연 영상에는 영향 적음)
- 로딩 중일 때 스켈레톤 UI 적용 (선택적)
- 또는 커스텀 로딩 인디케이터 디자인

**필요한 에셋**:
- 없음 (코드로 구현 가능)

---

### ⚠️ 2.3 일관성 (Consistency)
**현재 상태**: 기본 Material 디자인 사용
- `ThemeData(primarySwatch: Colors.deepPurple)` 기본 설정
- 버튼 스타일, 폰트 크기 등이 화면마다 다를 수 있음

**개선 제안**:
- **우선순위: 중간**
- 통일된 색상 테마 정의
- 커스텀 버튼 스타일 위젯 생성
- 텍스트 스타일 통일 (TextTheme)

**예시**:
```dart
ThemeData(
  primaryColor: Color(0xFF6C5CE7), // 모찌 브랜드 컬러
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF6C5CE7),
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
  ),
)
```

---

## 3. 필요한 이미지 에셋 리스트

### 필수 (High Priority)
1. **앱 로고**
   - `lib/assets/images/logo_mochi.png` (1024x1024px, 투명 배경)
   - `lib/assets/images/logo_mochi_white.png` (다크 모드용)

2. **스플래시 스크린용**
   - `lib/assets/images/splash_logo.png` (512x512px, 중앙 배치용)

3. **앱 아이콘**
   - `lib/assets/images/app_icon.png` (1024x1024px, 투명 배경)
   - 또는 `flutter_launcher_icons` 패키지로 자동 생성

### 권장 (Medium Priority)
4. **Empty State 일러스트**
   - `lib/assets/images/empty_friends.png` (400x400px)
   - `lib/assets/images/empty_chat.png` (400x400px)
   - `lib/assets/images/empty_messages.png` (400x400px)

5. **프로필 플레이스홀더**
   - `lib/assets/images/profile_placeholder.png` (200x200px, 원형)

### 선택 (Low Priority)
6. **로딩 인디케이터** (선택적)
   - 커스텀 로딩 애니메이션 이미지 (GIF 또는 Lottie)

---

## 4. 우선순위별 개선 작업 계획

### Phase 1: 필수 (시연 영상 전 필수)
1. ✅ 스플래시 스크린 구현
2. ✅ 마이페이지/설정 화면 구현
3. ✅ 앱 아이콘 커스터마이징

### Phase 2: 권장 (시연 영상 품질 향상)
4. ✅ Empty State 일러스트 추가
5. ✅ 테마 일관성 개선

### Phase 3: 선택 (출시 전 개선)
6. ⚠️ 스켈레톤 UI 적용
7. ⚠️ 커스텀 로딩 인디케이터

---

## 5. 추가 개선 제안

### 5.1 네비게이션 개선
- 현재: `MainNavigator`에 3개 탭 (지도, 채팅, 친구)
- 제안: 4번째 탭으로 "마이페이지" 추가 또는 지도 화면 AppBar에 프로필 아이콘 추가

### 5.2 에러 처리 UI
- 현재: `Text('오류가 발생했습니다: ${snapshot.error}')`
- 제안: 에러 일러스트 + 재시도 버튼 추가

### 5.3 온보딩 화면 (선택)
- 첫 실행 시 앱 사용법 안내 화면
- 시연 영상에는 필수 아님

---

## 6. 결론

**현재 상태**: 기능 구현은 완료되었으나, 프로덕션 수준의 디자인 완성도는 부족

**시연 영상 촬영 전 필수 작업**:
1. 스플래시 스크린 구현
2. 마이페이지/설정 화면 구현
3. 앱 아이콘 커스터마이징
4. Empty State 일러스트 추가

**예상 소요 시간**: 디자인 에셋 준비 포함 약 2-3일

**최종 목표 달성 가능성**: ✅ 위 작업 완료 시 "와, 디자인 완성도 높네" 반응 기대 가능


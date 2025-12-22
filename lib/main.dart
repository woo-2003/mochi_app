import 'package:flutter/material.dart';
import 'package:mochi_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mochi_app/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mochi_app/services/notification_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:mochi_app/providers/location_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase SDK를 Flutter 앱이 실행되기 전에 초기화합니다.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 카카오 SDK 초기화 (과제 제출용: 실제 키는 YOUR_KAKAO_NATIVE_APP_KEY로 교체 필요)
  KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY');
  // 한국어 날짜 형식 데이터 초기화 (intl 패키지)
  await initializeDateFormatting('ko_KR', null);
  // 알림 서비스 초기화 (FCM)
  await NotificationService.instance.initialize();
  // FCM 토큰 출력 (테스트용)
  await NotificationService.instance.getToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // LocationProvider 등록
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'Mochi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 모찌 브랜드 컬러: Deep Purple 계열의 세련된 색상
          primaryColor: const Color(0xFF6C5CE7),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C5CE7),
            brightness: Brightness.light,
          ),
          // AppBar 스타일: 배경색 흰색, 타이틀 검은색, 플랫 디자인
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          // BottomNavigationBar 스타일
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: const Color(0xFF6C5CE7),
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          // ElevatedButton 스타일: 메인 컬러 배경, 둥근 모서리
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          // TextButton 스타일
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6C5CE7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Card 스타일: 입체감과 여백
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          // FloatingActionButton 스타일: 메인 컬러 배경
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
          ),
          // 폰트 스타일
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
            bodySmall: TextStyle(fontSize: 12),
          ),
        ),
        // 앱의 첫 화면을 스플래시 스크린으로 설정
        home: const SplashScreen(),
      ),
    );
  }
}

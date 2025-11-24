import 'package:flutter/material.dart';
import 'package:mochi_app/screens/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mochi_app/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mochi_app/services/notification_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase SDK를 Flutter 앱이 실행되기 전에 초기화합니다.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 카카오 SDK 초기화 (주의: nativeAppKey는 팀장님이 직접 입력해야 함)
  KakaoSdk.init(nativeAppKey: '909997524e10fd9237f44b9b3447b0a2');
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
    return MaterialApp(
      title: 'Mochi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      // 앱의 첫 화면을 '로그인 화면'이 아닌 '인증 게이트'로 변경합니다.
      home: const AuthGate(),
    );
  }
}

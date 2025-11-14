import 'package:flutter/material.dart';
import 'package:mochi_app/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mochi_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase SDK를 Flutter 앱이 실행되기 전에 초기화합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // 앱의 첫 화면을 로그인 화면으로 변경합니다.
      home: const LoginScreen(),
    );
  }
}

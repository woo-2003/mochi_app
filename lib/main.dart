import 'package:flutter/material.dart';
import 'package:mochi_app/screens/auth/login_screen.dart';

void main() {
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

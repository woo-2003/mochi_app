// 사용자의 로그인 상태를 실시간으로 감지하여 적절한 화면으로 라우팅하는 인증 게이트입니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mochi_app/screens/auth/login_screen.dart';
import 'package:mochi_app/screens/main_navigator.dart';

/// 인증 게이트 위젯
///
/// Firebase Auth의 로그인 상태를 실시간으로 감지하여,
/// 로그인된 사용자는 메인 화면으로, 로그인되지 않은 사용자는 로그인 화면으로
/// 자동으로 라우팅합니다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Firebase Auth의 실시간 로그인 상태(Stream)를 감지합니다.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. 연결 대기 중... (로딩)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. 로그인 성공! (데이터가 있음)
        if (snapshot.hasData) {
          // 사용자가 로그인되어 있으면 메인 네비게이터(지도 화면)로 이동합니다.
          return const MainNavigator();
        }

        // 3. 로그인 실패 (데이터가 없음)
        // 사용자가 로그인되어 있지 않으면 로그인 화면으로 이동합니다.
        return const LoginScreen();
      },
    );
  }
}


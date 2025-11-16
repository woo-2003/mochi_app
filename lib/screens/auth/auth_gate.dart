// 사용자의 로그인 상태를 실시간으로 감지하여 적절한 화면으로 라우팅하는 인증 게이트입니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mochi_app/screens/auth/login_screen.dart';
import 'package:mochi_app/screens/auth/phone_verification_screen.dart';
import 'package:mochi_app/screens/main_navigator.dart';
import 'package:mochi_app/services/database_service.dart';

/// 인증 게이트 위젯
///
/// Firebase Auth의 로그인 상태를 실시간으로 감지하여,
/// 로그인된 사용자는 전화번호 유무를 확인한 후 적절한 화면으로 라우팅하고,
/// 로그인되지 않은 사용자는 로그인 화면으로 자동으로 라우팅합니다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. (StreamBuilder) 로그인 상태를 감지.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 연결 대기 중... (로딩)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. (FutureBuilder) 로그인했다면, `DatabaseService.checkIfUserHasPhoneNumber(user.uid)`를 '호출(future)'
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<bool>(
            future: DatabaseService.instance.checkIfUserHasPhoneNumber(user.uid),
            builder: (context, futureSnapshot) {
              // 3. (FutureBuilder snapshot) 전화번호 '확인 중'일 때는 '로딩' 화면.
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // 4. (FutureBuilder snapshot) '확인 완료'했는데,
              if (futureSnapshot.data == true) {
                // 전화번호 있음 -> 지도 화면으로 이동
                return const MainNavigator();
              } else {
                // 전화번호 없음 -> 전화번호 입력 화면으로 이동
                return const PhoneVerificationScreen();
              }
            },
          );
        }

        // 로그인 실패 (데이터가 없음)
        // 사용자가 로그인되어 있지 않으면 로그인 화면으로 이동합니다.
        return const LoginScreen();
      },
    );
  }
}


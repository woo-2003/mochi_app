// 사용자가 앱에 처음 진입했을 때 보게 될 로그인 화면입니다.
import 'package:flutter/material.dart';
import 'package:mochi_app/widgets/auth/social_login_button.dart';

/// 로그인 화면
///
/// 사용자가 앱에 처음 진입했을 때 보게 되는 화면으로,
/// 소셜 로그인(Google, Kakao)을 통해 앱에 접근할 수 있습니다.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: 여기에 '모찌' 로고가 들어갈 예정 (팀장님 자산)
                // 임시로 텍스트 로고를 표시합니다.
                const Text(
                  '모찌',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 100),
                // Google 소셜 로그인 버튼
                SocialLoginButton(
                  text: 'Google로 계속하기',
                  icon: Icons.email,
                  backgroundColor: Colors.white,
                  textColor: Colors.black87,
                  onPressed: () {
                    // TODO: 구글 로그인 로직 연결
                  },
                ),
                const SizedBox(height: 16),
                // Kakao 소셜 로그인 버튼
                SocialLoginButton(
                  text: 'Kakao로 계속하기',
                  icon: Icons.chat,
                  backgroundColor: const Color(0xFFFEE500), // Kakao 브랜드 색상
                  textColor: Colors.black87,
                  onPressed: () {
                    // TODO: 카카오 로그인 로직 연결
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

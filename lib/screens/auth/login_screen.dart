// 사용자가 앱에 처음 진입했을 때 보게 될 로그인 화면입니다.
import 'package:flutter/material.dart';
import 'package:mochi_app/screens/main_navigator.dart';
import 'package:mochi_app/services/auth_service.dart';
import 'package:mochi_app/widgets/auth/social_login_button.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 로그인 화면
///
/// 사용자가 앱에 처음 진입했을 때 보게 되는 화면으로,
/// 소셜 로그인(Google, Kakao)을 통해 앱에 접근할 수 있습니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 현재 로그인 시도 중인지 여부를 나타내는 상태 값입니다.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 카카오 SDK origin 출력 (키 해시 확인용)
    _printKakaoOrigin();
  }

  /// 카카오 SDK origin을 출력합니다. (키 해시 확인용)
  Future<void> _printKakaoOrigin() async {
    try {
      // ignore: avoid_print
      print('Kakao SDK Origin: ${await KakaoSdk.origin}');
    } catch (e) {
      // ignore: avoid_print
      print('Error getting Kakao origin: $e');
    }
  }

  /// 카카오 로그인 버튼을 눌렀을 때 실행되는 로직입니다.
  Future<void> _handleKakaoSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.instance.signInWithKakao();

      if (!mounted) {
        return;
      }

      if (user != null) {
        // 로그인 성공! 메인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MainNavigator()),
        );
      } else {
        // 로그인 실패. 사용자에게 알림 (예: SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해 주세요.')),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      // 로그인 실패. 사용자에게 알림 (예: SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예상치 못한 오류가 발생했습니다. 다시 시도해 주세요.')),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Google 로그인 버튼을 눌렀을 때 실행되는 로직입니다.
  Future<void> _handleGoogleSignIn() async {
    // Google 로그인 버튼 로직
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.instance.signInWithGoogle();

      if (!mounted) {
        return;
      }

      if (user != null) {
        // 로그인 성공! 메인 화면으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MainNavigator()),
        );
      } else {
        // 로그인 실패. 사용자에게 알림 (예: SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해 주세요.')),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      // 로그인 실패. 사용자에게 알림 (예: SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예상치 못한 오류가 발생했습니다. 다시 시도해 주세요.')),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

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
                // 스플래시 로고 이미지 표시
                Image.asset(
                  'lib/assets/images/splash_logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // 이미지 로드 실패 시 텍스트 로고 표시
                    return const Text(
                      '모찌',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
                if (_isLoading)
                  // 로그인 중임을 사용자에게 보여주기 위해 로딩 인디케이터를 표시합니다.
                  const CircularProgressIndicator()
                else ...[
                  // Google 소셜 로그인 버튼
                  SocialLoginButton(
                    text: 'Google로 계속하기',
                    icon: Icons.email,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    onPressed: () async {
                      // Google 로그인 버튼 로직
                      await _handleGoogleSignIn();
                    },
                  ),
                  const SizedBox(height: 16),
                  // Kakao 소셜 로그인 버튼
                  SocialLoginButton(
                    text: 'Kakao로 계속하기',
                    icon: Icons.chat,
                    backgroundColor: const Color(0xFFFEE500), // Kakao 브랜드 색상
                    textColor: Colors.black87,
                    onPressed: () async {
                      // 카카오 로그인 버튼 로직
                      await _handleKakaoSignIn();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

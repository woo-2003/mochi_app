// 스플래시 스크린
//
// 앱 실행 시 첫 화면으로 표시되는 스플래시 스크린입니다.
// 앱 로고를 표시하고 자동으로 인증 게이트로 이동합니다.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mochi_app/screens/auth/auth_gate.dart';

/// 스플래시 스크린
///
/// 앱 실행 시 첫 화면으로 표시되며, 로고를 페이드 인/아웃 애니메이션과 함께 표시합니다.
/// 2초 후 자동으로 AuthGate로 이동합니다.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// 페이드 인/아웃 애니메이션 컨트롤러
  late AnimationController _animationController;

  /// 페이드 애니메이션
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화 (2초 동안)
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // 페이드 애니메이션 설정 (0.0 -> 1.0 -> 0.0)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 애니메이션 시작
    _animationController.forward();

    // 2초 후 AuthGate로 이동
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AuthGate(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
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
        ),
      ),
    );
  }
}


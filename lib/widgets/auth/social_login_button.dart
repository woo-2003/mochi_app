// 재사용 가능한 소셜 로그인 버튼 위젯입니다.
import 'package:flutter/material.dart';

/// 소셜 로그인 버튼 위젯
/// 
/// 다양한 소셜 로그인 제공자(Google, Kakao 등)의 로그인 버튼을
/// 일관된 스타일로 표시하기 위한 재사용 가능한 위젯입니다.
class SocialLoginButton extends StatelessWidget {
  /// 버튼에 표시될 텍스트
  final String text;
  
  /// 버튼에 표시될 아이콘
  final IconData icon;
  
  /// 버튼의 배경색
  final Color backgroundColor;
  
  /// 버튼 텍스트의 색상
  final Color textColor;
  
  /// 버튼이 눌렸을 때 실행될 콜백 함수
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}


// 빈 화면(Empty State) 위젯
//
// 데이터가 없을 때 사용자에게 안내 메시지를 표시하는 재사용 가능한 위젯입니다.
import 'package:flutter/material.dart';

/// 빈 화면 위젯
///
/// 데이터가 없을 때 사용자에게 안내 메시지를 표시합니다.
/// 이미지 또는 아이콘, 제목, 설명을 표시할 수 있습니다.
class EmptyStateWidget extends StatelessWidget {
  /// 이미지 경로 (선택 사항)
  final String? imagePath;

  /// 아이콘 (이미지가 없을 때 사용)
  final IconData? icon;

  /// 제목 (필수)
  final String title;

  /// 설명 (선택 사항)
  final String? subtitle;

  /// 아이콘 크기
  final double iconSize;

  /// 아이콘 색상
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    this.imagePath,
    this.icon,
    required this.title,
    this.subtitle,
    this.iconSize = 80,
    this.iconColor,
  }) : assert(
          imagePath != null || icon != null,
          'imagePath 또는 icon 중 하나는 반드시 제공되어야 합니다.',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 또는 아이콘 표시
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // 이미지 로드 실패 시 아이콘 표시
                  return Icon(
                    icon ?? Icons.inbox_outlined,
                    size: iconSize,
                    color: iconColor ?? primaryColor.withValues(alpha: 0.5),
                  );
                },
              )
            else if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? primaryColor.withValues(alpha: 0.5),
              ),
            const SizedBox(height: 24),
            // 제목
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            // 설명 (있는 경우)
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


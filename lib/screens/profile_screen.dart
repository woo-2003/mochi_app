// 마이페이지/설정 화면
//
// 사용자의 프로필 정보를 표시하고 설정 메뉴를 제공하는 화면입니다.
import 'package:flutter/material.dart';
import 'package:mochi_app/services/auth_service.dart';

/// 마이페이지/설정 화면
///
/// 사용자의 프로필 정보를 표시하고, 공지사항, 친구 관리, 앱 정보 등의 설정 메뉴를 제공합니다.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// 로그아웃 다이얼로그를 표시하는 메서드
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // 로그아웃 실행
                await AuthService.instance.signOut();
                // AuthGate가 스트림을 감지하고 자동으로 로그인 화면으로 보낼 것임
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자 정보 가져오기
    final currentUser = AuthService.currentUser;
    final displayName = currentUser?.displayName ?? '팀장님';
    final email = currentUser?.email ?? 'teamjang@mochi.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 상단: 프로필 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
              ),
              child: Column(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: const AssetImage(
                      'lib/assets/images/profile_placeholder.png',
                    ),
                    onBackgroundImageError: (exception, stackTrace) {
                      // 이미지 로드 실패 시 기본 아이콘 사용
                    },
                    child: const Icon(Icons.person, size: 60),
                  ),
                  const SizedBox(height: 16),
                  // 이름
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 이메일
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 중단: 설정 메뉴
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('공지사항'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: 공지사항 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공지사항 기능은 준비 중입니다.')),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('친구 관리'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: 친구 관리 화면으로 이동 (또는 친구 목록 탭으로 이동)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('친구 관리 화면으로 이동합니다.')),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('앱 정보'),
              trailing: const Text(
                'v1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                // TODO: 앱 정보 다이얼로그 표시
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('앱 정보'),
                    content: const Text('Mochi v1.0.0\n\n친구들과 실시간 위치를 공유하는 앱입니다.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // 하단: 로그아웃 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


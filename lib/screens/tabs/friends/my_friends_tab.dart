// 내 모찌 탭 화면
//
// 사용자가 추가한 친구(모찌) 목록을 실시간으로 표시하는 화면입니다.
import 'package:flutter/material.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/screens/chat/chat_screen.dart';
import 'package:mochi_app/widgets/empty_state_widget.dart';

/// 내 모찌 탭 화면
///
/// 사용자가 추가한 친구(모찌) 목록을 표시하는 화면입니다.
class MyFriendsTab extends StatefulWidget {
  const MyFriendsTab({super.key});

  @override
  State<MyFriendsTab> createState() => _MyFriendsTabState();
}

class _MyFriendsTabState extends State<MyFriendsTab> {

  /// 시연용 데모 친구 3명의 데이터를 반환합니다.
  List<Map<String, String>> _getDemoFriends() {
    return [
      {
        'name': '미소',
        'status': '과제 폭파 중 💣',
        'phoneNumber': '010-1234-5678',
      },
      {
        'name': '성결',
        'status': '농구 한 판? 🏀',
        'phoneNumber': '010-2345-6789',
      },
      {
        'name': '공대',
        'status': '아아 수혈 시급 ☕',
        'phoneNumber': '010-3456-7890',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 시연용: Firebase 연동 일시 중지, 데모 데이터만 표시
    final demoFriends = _getDemoFriends();

    return Scaffold(
      body: demoFriends.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.people_outline,
              title: '친구가 없습니다',
              subtitle: '친구를 추가하여 위치를 공유해보세요!',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: demoFriends.length,
              itemBuilder: (context, index) {
                final demoFriend = demoFriends[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: const AssetImage(
                          'lib/assets/images/marker_friend.png',
                        ),
                        onBackgroundImageError: (exception, stackTrace) {
                          // 이미지 로드 실패 시 기본 아이콘 사용
                        },
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      demoFriend['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(demoFriend['status']!),
                    trailing: Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                    ),
                    onTap: () {
                      // 데모 친구와의 채팅 화면으로 이동 (가짜 UserModel 생성)
                      final demoUser = UserModel(
                        uid: 'demo_${demoFriend['name']}',
                        email: '${demoFriend['name']}@demo.com',
                        displayName: demoFriend['name']!,
                        phoneNumber: demoFriend['phoneNumber'],
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            targetUser: demoUser,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

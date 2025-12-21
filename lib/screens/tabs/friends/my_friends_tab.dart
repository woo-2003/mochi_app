// 내 모찌 탭 화면
//
// 사용자가 추가한 친구(모찌) 목록을 실시간으로 표시하는 화면입니다.
import 'package:flutter/material.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/screens/chat/chat_screen.dart';

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
      body: ListView.builder(
        itemCount: demoFriends.length,
        itemBuilder: (context, index) {
          final demoFriend = demoFriends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: const AssetImage('lib/assets/images/marker_friend.png'),
              onBackgroundImageError: (exception, stackTrace) {
                // 이미지 로드 실패 시 기본 아이콘 사용
              },
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(demoFriend['name']!),
            subtitle: Text(demoFriend['status']!),
            trailing: const Icon(Icons.location_on, color: Colors.red),
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
          );
        },
      ),
    );
  }
}

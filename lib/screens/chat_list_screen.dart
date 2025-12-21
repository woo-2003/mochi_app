// 채팅 목록 화면
//
// 사용자가 참여 중인 모든 채팅방 목록을 실시간으로 표시하는 화면입니다.
import 'package:flutter/material.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/screens/chat/chat_screen.dart';

/// 채팅 목록 화면
///
/// 사용자가 참여 중인 모든 채팅방 목록을 실시간으로 표시하는 화면입니다.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  /// 시연용 데모 채팅방 3개의 데이터를 반환합니다.
  List<Map<String, String>> _getDemoChatRooms() {
    return [
      {
        'name': '미소',
        'lastMessage': '야 과제 다 했냐?',
        'time': '방금',
      },
      {
        'name': '성결',
        'lastMessage': '오늘 날씨 좋은데 농구 콜?',
        'time': '10분 전',
      },
      {
        'name': '공대',
        'lastMessage': '살려줘... 카페인 부족해',
        'time': '30분 전',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 시연용: Firebase 연동 일시 중지, 데모 데이터만 표시
    final demoChatRooms = _getDemoChatRooms();

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      body: ListView.builder(
        itemCount: demoChatRooms.length,
        itemBuilder: (context, index) {
          final demoRoom = demoChatRooms[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade200,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(demoRoom['name']!),
            subtitle: Text(demoRoom['lastMessage']!),
            trailing: Text(
              demoRoom['time']!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            onTap: () {
              // 데모 친구와의 채팅 화면으로 이동 (가짜 UserModel 생성)
              final demoUser = UserModel(
                uid: 'demo_${demoRoom['name']}',
                email: '${demoRoom['name']}@demo.com',
                displayName: demoRoom['name']!,
                phoneNumber: null,
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


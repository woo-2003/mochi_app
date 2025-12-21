// 채팅 목록 화면
//
// 사용자가 참여 중인 모든 채팅방 목록을 실시간으로 표시하는 화면입니다.
import 'package:flutter/material.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/screens/chat/chat_screen.dart';
import 'package:mochi_app/widgets/empty_state_widget.dart';

/// 채팅 목록 화면
///
/// 사용자가 참여 중인 모든 채팅방 목록을 실시간으로 표시하는 화면입니다.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  /// 시연용 데모 채팅방 데이터 (상태로 관리하여 업데이트 가능)
  late Map<String, Map<String, String>> _demoChatRooms;

  @override
  void initState() {
    super.initState();
    // 초기 데모 채팅방 데이터 설정
    _demoChatRooms = {
      '미소': {
        'name': '미소',
        'lastMessage': '이미 자리 잡음. 빨리 와라', // 실제 마지막 메시지와 동기화
        'time': '1시간 전',
      },
      '성결': {
        'name': '성결',
        'lastMessage': '3시에 운동장으로 와. 애들 다 모임', // 실제 마지막 메시지와 동기화
        'time': '2시간 전',
      },
      '공대': {
        'name': '공대',
        'lastMessage': '너는 진짜 천사다 😇 사이즈 업 부탁', // 실제 마지막 메시지와 동기화
        'time': '40분 전',
      },
    };
  }

  /// 데모 채팅방 리스트를 반환합니다.
  List<Map<String, String>> _getDemoChatRoomsList() {
    return _demoChatRooms.values.toList();
  }

  /// 채팅방의 마지막 메시지를 업데이트합니다.
  void _updateLastMessage(String userName, String lastMessage) {
    setState(() {
      if (_demoChatRooms.containsKey(userName)) {
        _demoChatRooms[userName]!['lastMessage'] = lastMessage;
        _demoChatRooms[userName]!['time'] = '방금';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 시연용: Firebase 연동 일시 중지, 데모 데이터만 표시
    final demoChatRooms = _getDemoChatRoomsList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      body: demoChatRooms.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              title: '채팅방이 없습니다',
              subtitle: '친구와 대화를 시작해보세요!',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: demoChatRooms.length,
              itemBuilder: (context, index) {
                final demoRoom = demoChatRooms[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(
                      demoRoom['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      demoRoom['lastMessage']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          demoRoom['time']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        // 읽지 않은 메시지 배지 (예시: 첫 번째 채팅방에만 표시)
                        if (index == 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () async {
                      // 데모 친구와의 채팅 화면으로 이동 (가짜 UserModel 생성)
                      final demoUser = UserModel(
                        uid: 'demo_${demoRoom['name']}',
                        email: '${demoRoom['name']}@demo.com',
                        displayName: demoRoom['name']!,
                        phoneNumber: null,
                      );
                      // 채팅 화면에서 돌아올 때 결과를 받아서 마지막 메시지 업데이트
                      final result = await Navigator.push<Map<String, String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            targetUser: demoUser,
                          ),
                        ),
                      );
                      // 채팅 화면에서 메시지를 보냈다면 결과를 받아서 업데이트
                      if (result != null && mounted) {
                        _updateLastMessage(
                          result['userName']!,
                          result['lastMessage']!,
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}


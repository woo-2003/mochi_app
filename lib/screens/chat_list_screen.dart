// 채팅 목록 화면
//
// 사용자가 참여 중인 모든 채팅방 목록을 실시간으로 표시하는 화면입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/screens/chat/chat_screen.dart';
import 'package:mochi_app/services/auth_service.dart';
import 'package:mochi_app/services/chat_service.dart';
import 'package:mochi_app/services/database_service.dart';

/// 채팅 목록 화면
///
/// 사용자가 참여 중인 모든 채팅방 목록을 실시간으로 표시하는 화면입니다.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자의 UID
    final currentUserUid = AuthService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // StreamBuilder의 stream: ChatService.getChatRoomsStream()을 호출
        stream: ChatService.instance.getChatRoomsStream(),
        builder: (context, snapshot) {
          // 연결 중일 때는 로딩 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 에러가 발생한 경우
          if (snapshot.hasError) {
            return Center(
              child: Text('오류가 발생했습니다: ${snapshot.error}'),
            );
          }

          // 데이터가 없을 때
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('채팅방이 없습니다. 친구와 채팅을 시작해보세요!'),
            );
          }

          // 채팅방 목록 표시
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final roomDoc = snapshot.data!.docs[index];
              final roomData = roomDoc.data() as Map<String, dynamic>;
              final participants = (roomData['participants'] as List<dynamic>?)
                      ?.map((e) => e as String)
                      .toList() ??
                  [];
              final lastMessage = roomData['lastMessage'] as String? ?? '';

              // 상대방 UID 찾기 (내 UID가 아닌 참가자)
              final otherUserUid = participants.firstWhere(
                (uid) => uid != currentUserUid,
                orElse: () => '',
              );

              // 상대방 프로필 정보를 가져와서 표시
              return FutureBuilder<UserModel?>(
                future: DatabaseService.instance.getUserProfile(otherUserUid),
                builder: (context, userSnapshot) {
                  // 사용자 정보를 가져오는 중
                  if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircularProgressIndicator(),
                      title: Text('로딩 중...'),
                    );
                  }

                  // 사용자 정보를 가져오지 못한 경우
                  final userProfile = userSnapshot.data;
                  if (userProfile == null) {
                    return const ListTile(
                      title: Text('알 수 없는 사용자'),
                      subtitle: Text('정보 없음'),
                    );
                  }

                  // 채팅방 목록 아이템
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(userProfile.displayName),
                    subtitle: Text(lastMessage),
                    onTap: () {
                      // ChatScreen으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            targetUser: userProfile,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


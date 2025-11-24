// 채팅 화면
//
// 특정 친구와의 1:1 실시간 채팅을 할 수 있는 화면입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mochi_app/models/chat_model.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/services/auth_service.dart';
import 'package:mochi_app/services/chat_service.dart';
import 'package:mochi_app/widgets/chat/message_bubble.dart';

/// 채팅 화면
///
/// 특정 친구와의 1:1 실시간 채팅을 할 수 있는 화면입니다.
/// Firestore의 실시간 스트림을 사용하여 메시지를 주고받습니다.
class ChatScreen extends StatefulWidget {
  /// 채팅할 대상 사용자
  final UserModel targetUser;

  const ChatScreen({
    super.key,
    required this.targetUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  /// 메시지 입력 필드 컨트롤러
  final TextEditingController _messageController = TextEditingController();

  /// 메시지 전송 중인지 여부
  bool _isSending = false;

  @override
  void dispose() {
    // 메모리 누수를 방지하기 위해 컨트롤러를 정리합니다.
    _messageController.dispose();
    super.dispose();
  }

  /// 메시지를 전송하는 메서드입니다.
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    // 빈 메시지는 전송하지 않습니다.
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // ChatService를 통해 메시지 전송
      await ChatService.instance.sendMessage(
        widget.targetUser.uid,
        message,
      );

      // 전송 성공 시 입력 필드 초기화
      _messageController.clear();
    } catch (e) {
      // 전송 실패 시 사용자에게 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 전송 실패: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자의 UID
    final currentUserUid = AuthService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.targetUser.displayName),
      ),
      body: Column(
        children: [
          // 메시지 목록 영역
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ChatService.instance.getMessagesStream(
                widget.targetUser.uid,
              ),
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
                    child: Text('메시지가 없습니다. 메시지를 보내보세요!'),
                  );
                }

                // 메시지 목록을 역순으로 표시 (최신 메시지가 아래에)
                final messages = snapshot.data!.docs.reversed.toList();

                return ListView.builder(
                  // 넉넉한 패딩으로 보기 편하게 설정
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final message = ChatMessage.fromMap(data);
                    final isMyMessage = message.senderId == currentUserUid;

                    // 카카오톡 스타일의 MessageBubble 위젯 사용
                    return MessageBubble(
                      message: message.text,
                      isMe: isMyMessage,
                      userImage: null, // TODO: 상대방 프로필 이미지 URL 추가
                      timestamp: message.timestamp,
                    );
                  },
                );
              },
            ),
          ),

          // 메시지 입력 영역
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // 메시지 입력 필드
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // 전송 버튼
                IconButton(
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


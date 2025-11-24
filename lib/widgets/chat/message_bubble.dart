// 메시지 버블 위젯
//
// 카카오톡 스타일의 세련된 메시지 말풍선을 표시하는 위젯입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 메시지 버블 위젯
///
/// 채팅 메시지를 카카오톡 스타일의 말풍선으로 표시합니다.
/// 내 메시지는 오른쪽에 보라색, 상대 메시지는 왼쪽에 회색으로 표시됩니다.
class MessageBubble extends StatelessWidget {
  /// 메시지 내용
  final String message;

  /// 내가 보낸 메시지인지 여부
  final bool isMe;

  /// 상대방 프로필 이미지 URL (선택사항)
  final String? userImage;

  /// 메시지 전송 시간
  final Timestamp timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.userImage,
    required this.timestamp,
  });

  /// 시간을 '오후 2:30' 형식으로 포맷팅합니다.
  String _formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('a h:mm', 'ko_KR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        // 내 메시지는 오른쪽 정렬, 상대 메시지는 왼쪽 정렬
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 상대 메시지일 경우 프로필 사진 표시 (왼쪽)
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage: userImage != null
                  ? NetworkImage(userImage!)
                  : null,
              child: userImage == null
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          // 말풍선과 시간을 세로로 배치
          Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // 말풍선
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isMe ? Colors.deepPurple : Colors.grey[300],
                  // 카카오톡 스타일: 내 메시지는 오른쪽 위만 직각, 상대 메시지는 왼쪽 위만 직각
                  borderRadius: isMe
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(4),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(12),
                        ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
              // 시간 표시 (말풍선 바깥쪽 하단)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                child: Text(
                  _formatTime(timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          // 내 메시지일 경우 오른쪽 여백 (프로필 사진 대신)
          if (isMe) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

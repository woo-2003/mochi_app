// 채팅 메시지 데이터 모델
//
// Firestore의 'chat_rooms/{roomId}/messages' 컬렉션 문서를 Dart 객체로 변환하기 위한 모델 클래스입니다.
import 'package:cloud_firestore/cloud_firestore.dart';

/// 채팅 메시지 모델 클래스
///
/// Firestore의 'messages' 컬렉션 문서를 Dart 객체로 표현합니다.
class ChatMessage {
  /// 메시지를 보낸 사용자의 UID
  final String senderId;

  /// 메시지 내용
  final String text;

  /// 메시지가 전송된 시간 (Timestamp)
  final Timestamp timestamp;

  /// 생성자
  const ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  /// Firestore 문서로부터 ChatMessage 객체를 생성하는 팩토리 생성자
  ///
  /// [map] Firestore 문서의 데이터 (Map<String, dynamic>)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'] as String,
      text: map['text'] as String,
      // 서버 타임스탬프가 아직 생성되지 않았을 때(null)를 대비한 방어 코드
      // timestamp가 null이면 현재 시간으로 대체 (로컬 낙관적 업데이트 방어)
      timestamp: (map['timestamp'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  /// ChatMessage 객체를 Firestore에 저장할 수 있는 Map 형태로 변환합니다.
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}


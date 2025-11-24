// 채팅 서비스 로직
//
// Firestore를 이용한 1:1 채팅 기능을 담당하는 서비스입니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mochi_app/models/chat_model.dart';
import 'package:mochi_app/services/auth_service.dart';

/// 채팅 서비스 클래스
///
/// Firestore를 이용한 1:1 채팅 기능을 제공합니다.
/// 싱글톤 패턴을 사용해 앱 전역에서 동일한 인스턴스를 손쉽게 사용할 수 있도록 합니다.
class ChatService {
  /// 싱글톤 인스턴스
  static final ChatService instance = ChatService._internal();

  /// FirebaseFirestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatService._internal();

  /// 두 사용자 간의 고유한 채팅방 ID를 생성합니다.
  ///
  /// [userA] 첫 번째 사용자의 UID
  /// [userB] 두 번째 사용자의 UID
  /// 반환값: 항상 같은 순서로 정렬된 'userA_userB' 형태의 방 ID
  ///
  /// 예: userA='uid1', userB='uid2' -> 'uid1_uid2'
  ///     userA='uid2', userB='uid1' -> 'uid1_uid2' (같은 결과)
  String getChatRoomId(String userA, String userB) {
    // 두 UID를 정렬하여 항상 같은 방 ID가 생성되도록 합니다.
    final sortedUids = [userA, userB]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }

  /// 메시지를 전송하고 채팅방 정보를 업데이트합니다.
  ///
  /// [friendUid] 메시지를 받을 친구의 UID
  /// [message] 전송할 메시지 내용
  Future<void> sendMessage(String friendUid, String message) async {
    try {
      // 1. 현재 로그인한 유저의 `uid`를 가져옴.
      final String? currentUserUid = AuthService.currentUser?.uid;
      if (currentUserUid == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 2. 채팅방 ID 생성
      final roomId = getChatRoomId(currentUserUid, friendUid);

      // 3. `chat_rooms/{roomId}/messages` 컬렉션에 메시지를 추가
      final messagesCollection = _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages');

      await messagesCollection.add({
        'senderId': currentUserUid,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 4. `chat_rooms/{roomId}` 문서에 채팅방 정보 업데이트 (merge: true)
      final roomDoc = _firestore.collection('chat_rooms').doc(roomId);
      await roomDoc.set({
        'lastMessage': message,
        'lastTime': FieldValue.serverTimestamp(),
        'participants': [currentUserUid, friendUid], // 두 사용자 모두 포함
      }, SetOptions(merge: true));
    } catch (e) {
      // 메시지 전송 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// 특정 친구와의 채팅 메시지를 실시간으로 구독하는 스트림을 반환합니다.
  ///
  /// [friendUid] 채팅할 친구의 UID
  /// 반환값: 메시지 문서들의 스냅샷 스트림 (최신 메시지 순으로 정렬)
  Stream<QuerySnapshot> getMessagesStream(String friendUid) {
    try {
      // 1. 현재 로그인한 유저의 `uid`를 가져옴.
      final String? currentUserUid = AuthService.currentUser?.uid;
      if (currentUserUid == null) {
        // 로그인하지 않은 경우 빈 스트림을 반환합니다.
        return const Stream.empty();
      }

      // 2. 채팅방 ID 생성
      final roomId = getChatRoomId(currentUserUid, friendUid);

      // 3. `chat_rooms/{roomId}/messages` 컬렉션을 참조
      final messagesCollection = _firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages');

      // 4. `orderBy('timestamp', descending: true)` (최신 메시지 순)
      // 5. `.snapshots()`를 반환하여 '실시간' 메시지 스트림을 만듦
      return messagesCollection
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      // 메시지 스트림 생성 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting messages stream: $e');
      return const Stream.empty();
    }
  }

  /// 현재 사용자가 참여 중인 모든 채팅방 목록을 실시간으로 구독하는 스트림을 반환합니다.
  ///
  /// 반환값: 채팅방 문서들의 스냅샷 스트림
  Stream<QuerySnapshot> getChatRoomsStream() {
    try {
      // 1. 현재 로그인한 유저의 `uid`를 가져옴.
      final String? currentUserUid = AuthService.currentUser?.uid;
      if (currentUserUid == null) {
        // 로그인하지 않은 경우 빈 스트림을 반환합니다.
        return const Stream.empty();
      }

      // 2. `chat_rooms` 컬렉션을 참조
      final chatRoomsCollection = _firestore.collection('chat_rooms');

      // 3. `where('participants', arrayContains: currentUserUid)` 쿼리를 사용해,
      //    '내 uid'가 'participants' 배열에 포함된 채팅방만 필터링
      // 4. `orderBy('lastTime', descending: true)` (최근 메시지 순)
      // 5. `.snapshots()`를 반환하여 '실시간' 채팅방 목록 스트림을 만듦
      return chatRoomsCollection
          .where('participants', arrayContains: currentUserUid)
          .orderBy('lastTime', descending: true)
          .snapshots();
    } catch (e) {
      // 채팅방 목록 스트림 생성 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting chat rooms stream: $e');
      return const Stream.empty();
    }
  }
}

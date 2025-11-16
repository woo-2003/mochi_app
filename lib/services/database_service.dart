// Firestore 데이터베이스와의 상호작용을 담당하는 서비스 로직을 정의합니다.
// 사용자 정보 저장 및 조회 등의 데이터베이스 작업을 처리합니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore 데이터베이스와의 상호작용을 담당하는 서비스입니다.
///
/// 싱글톤 패턴을 사용해 앱 전역에서 동일한 인스턴스를 손쉽게 사용할 수 있도록 합니다.
class DatabaseService {
  /// 싱글톤 인스턴스
  static final DatabaseService instance = DatabaseService._internal();

  /// FirebaseFirestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseService._internal();

  /// 사용자 정보를 Firestore에 저장합니다.
  ///
  /// 신규 사용자인 경우에만 저장하며, 이미 존재하는 사용자는 업데이트하지 않습니다.
  /// [user] Firebase Auth의 User 객체
  Future<void> saveUser(User user) async {
    try {
      // 1. Firestore의 'users' 컬렉션을 참조
      final usersCollection = _firestore.collection('users');

      // 2. `user.uid`를 '문서 ID(doc)'로 사용
      final userDoc = usersCollection.doc(user.uid);

      // 3. `doc(user.uid).get()`을 호출해 '이미 저장된 유저'인지 확인
      final docSnapshot = await userDoc.get();

      // 4. `doc.exists`가 `false`일 경우 (즉, '신규' 유저일 경우)에만,
      if (!docSnapshot.exists) {
        // 5. `doc(user.uid).set()`을 호출하여 '새 사용자 문서'를 생성
        // 6. 저장할 데이터: `uid`, `email`, `displayName`, `createdAt` (Timestamp.now())
        await userDoc.set({
          'uid': user.uid,
          'email': user.email ?? '',
          'displayName': user.displayName ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // 이미 존재하는 사용자인 경우 아무 작업도 하지 않습니다.
    } catch (e) {
      // 데이터베이스 저장 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error saving user to Firestore: $e');
      // 실제 프로덕션 환경에서는 에러 핸들링을 더 세밀하게 처리해야 합니다.
      rethrow;
    }
  }
}


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
          'phoneNumber': null, // 필드 존재 여부를 쉽게 파악하기 위해 null로 초기화
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

  /// 사용자가 전화번호를 가지고 있는지 확인합니다.
  ///
  /// [uid] 확인할 사용자의 UID
  /// 반환값: 전화번호가 있으면 `true`, 없으면 `false`
  Future<bool> checkIfUserHasPhoneNumber(String uid) async {
    try {
      // 1. 'users' 컬렉션에서 `doc(uid).get()`으로 사용자 문서를 가져옴.
      final userDoc = _firestore.collection('users').doc(uid);
      final docSnapshot = await userDoc.get();

      // 2. 문서가 존재하고, `doc.data()` 안에 'phoneNumber' 필드가 '존재하는지' 확인.
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        // 3. 존재하면 `true`, 존재하지 않으면 `false`를 반환.
        return data != null &&
            data.containsKey('phoneNumber') &&
            data['phoneNumber'] != null;
      }

      return false;
    } catch (e) {
      // 오류 발생 시 false를 반환합니다.
      // ignore: avoid_print
      print('Error checking phone number: $e');
      return false;
    }
  }

  /// 사용자의 전화번호를 저장합니다.
  ///
  /// [uid] 저장할 사용자의 UID
  /// [phoneNumber] 저장할 전화번호
  Future<void> savePhoneNumber(String uid, String phoneNumber) async {
    try {
      // 1. 'users' 컬렉션에서 `doc(uid).update()`를 호출.
      final userDoc = _firestore.collection('users').doc(uid);

      // 2. `{'phoneNumber': phoneNumber}` 데이터를 '업데이트'(추가)함.
      await userDoc.update({
        'phoneNumber': phoneNumber,
      });
    } catch (e) {
      // 전화번호 저장 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error saving phone number: $e');
      rethrow;
    }
  }

  /// 연락처 목록에서 모찌에 가입한 친구를 찾습니다.
  ///
  /// [phoneNumbers] 검색할 전화번호 목록
  /// 반환값: 모찌에 가입한 친구들의 데이터 리스트 (TODO: User 모델로 변환)
  Future<List<Map<String, dynamic>>> findFriendsFromContacts(
      List<String> phoneNumbers) async {
    try {
      // 1. 'users' 컬렉션을 참조.
      final usersCollection = _firestore.collection('users');

      // 2. `where('phoneNumber', whereIn: phoneNumbers)` 쿼리를 사용해,
      //    내 연락처 목록(phoneNumbers)에 포함된 번호를 가진 사용자를 '한 번에' 검색.
      //    참고: Firestore의 whereIn은 최대 10개의 값을 지원하므로,
      //    phoneNumbers가 10개를 초과하면 배치로 나누어 처리해야 합니다.
      if (phoneNumbers.isEmpty) {
        return [];
      }

      // whereIn은 최대 10개까지만 지원하므로, 10개씩 나누어 처리합니다.
      List<Map<String, dynamic>> allResults = [];

      for (int i = 0; i < phoneNumbers.length; i += 10) {
        final batch = phoneNumbers.skip(i).take(10).toList();

        // 3. 쿼리 스냅샷(snapshot)을 가져옴.
        final querySnapshot = await usersCollection
            .where('phoneNumber', whereIn: batch)
            .get();

        // 4. 스냅샷의 'docs'를 순회하며 `Map<String, dynamic>` 데이터 리스트를 반환.
        //    (TODO: User 모델로 변환)
        for (var doc in querySnapshot.docs) {
          final data = doc.data();
          data['uid'] = doc.id; // 문서 ID도 포함
          allResults.add(data);
        }
      }

      return allResults;
    } catch (e) {
      // 친구 검색 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error finding friends from contacts: $e');
      return [];
    }
  }
}


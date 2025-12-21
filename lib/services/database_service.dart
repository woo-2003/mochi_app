// Firestore 데이터베이스와의 상호작용을 담당하는 서비스 로직을 정의합니다.
// 사용자 정보 저장 및 조회 등의 데이터베이스 작업을 처리합니다.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mochi_app/models/user_model.dart';
import 'package:mochi_app/services/auth_service.dart';

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
          'displayName': user.displayName ?? 'Mochi User', // 기본값 설정 (가입한 친구 이름이 null로 뜨지 않게)
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
  /// [currentUserUid] 현재 로그인한 사용자의 UID (자기 자신을 제외하기 위함)
  /// [phoneNumbers] 검색할 전화번호 목록
  /// 반환값: 모찌에 가입한 친구들의 UserModel 리스트 (자기 자신 제외)
  Future<List<UserModel>> findFriendsFromContacts(
      String currentUserUid, List<String> phoneNumbers) async {
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
      List<UserModel> allResults = [];

      for (int i = 0; i < phoneNumbers.length; i += 10) {
        final batch = phoneNumbers.skip(i).take(10).toList();

        // 3. 쿼리 스냅샷(snapshot)을 가져옴.
        final querySnapshot = await usersCollection
            .where('phoneNumber', whereIn: batch)
            .get();

        // 4. 스냅샷의 'docs'를 순회하며 UserModel 객체 리스트로 변환.
        for (var doc in querySnapshot.docs) {
          final userModel = UserModel.fromMap(doc.data(), doc.id);
          allResults.add(userModel);
        }
      }

      // 5. '자기 자신'을 결과 리스트에서 '제외'합니다.
      //    (Firestore는 'whereIn'과 'isNotEqualTo' 동시 사용이 제한적이므로,
      //     결과를 가져온 후 필터링하는 방식으로 처리)
      allResults.removeWhere((user) => user.uid == currentUserUid);

      return allResults;
    } catch (e) {
      // 친구 검색 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error finding friends from contacts: $e');
      return [];
    }
  }

  /// 친구 요청을 전송합니다.
  ///
  /// [toUid] 친구 요청을 받을 사용자의 UID
  Future<void> sendFriendRequest(String toUid) async {
    try {
      // 1. 현재 로그인한 유저의 uid를 `AuthService`에서 가져옴. (이중 방어)
      final String? fromUid = AuthService.currentUser?.uid;
      if (fromUid == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 2. '자기 자신'에게 요청하는 것을 '방어'합니다. (이중 방어)
      if (fromUid == toUid) {
        throw Exception('자기 자신에게 친구 요청을 보낼 수 없습니다.');
      }

      // 3. Firestore의 'friend_requests' 컬렉션을 참조.
      final friendRequestsCollection = _firestore.collection('friend_requests');

      // 4. `add()` 메서드로 새 문서를 생성.
      // 5. 저장할 데이터: `{ 'fromUid': fromUid, 'toUid': toUid, 'status': 'pending', 'createdAt': Timestamp.now() }`
      await friendRequestsCollection.add({
        'fromUid': fromUid,
        'toUid': toUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // 친구 요청 전송 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  /// 나에게 온 보류 중인 친구 요청을 실시간으로 감지하는 스트림을 반환합니다.
  ///
  /// 반환값: 친구 요청 문서들의 스냅샷 스트림
  Stream<QuerySnapshot> getFriendRequests() {
    try {
      // 1. 현재 로그인한 유저의 `uid`를 가져옴.
      final String? currentUserUid = AuthService.currentUser?.uid;
      if (currentUserUid == null) {
        // 로그인하지 않은 경우 빈 스트림을 반환합니다.
        return const Stream.empty();
      }

      // 2. `friend_requests` 컬렉션을 참조.
      final friendRequestsCollection = _firestore.collection('friend_requests');

      // 3. `where('toUid', isEqualTo: currentUserUid)` (나에게 온 요청)
      // 4. `where('status', isEqualTo: 'pending')` (보류 중인 요청)
      // 5. `.snapshots()`를 반환하여 '실시간' 스트림을 만듦.
      return friendRequestsCollection
          .where('toUid', isEqualTo: currentUserUid)
          .where('status', isEqualTo: 'pending')
          .snapshots();
    } catch (e) {
      // 친구 요청 스트림 생성 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting friend requests stream: $e');
      return const Stream.empty();
    }
  }

  /// 특정 사용자의 프로필 정보를 가져옵니다.
  ///
  /// [uid] 조회할 사용자의 UID
  /// 반환값: 사용자의 UserModel 객체 (존재하지 않으면 null)
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      // 'users' 컬렉션에서 `doc(uid).get()`으로 특정 사용자의 'UserModel' 정보를 가져옴.
      final userDoc = _firestore.collection('users').doc(uid);
      final docSnapshot = await userDoc.get();

      // `doc.exists`가 `true`이면 `UserModel`을 반환하고, `false`이면 `null`을 반환합니다.
      // (존재하지 않는 사용자나 탈퇴한 사용자의 경우 null을 반환하여 안정성을 보장)
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      }

      // 문서가 존재하지 않는 경우 null을 반환합니다.
      return null;
    } catch (e) {
      // 사용자 프로필 조회 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// 친구 요청을 수락하고 양쪽 친구 목록에 상호 추가합니다.
  ///
  /// [requestId] 수락할 친구 요청 문서의 ID
  /// [fromUid] 친구 요청을 보낸 사용자의 UID
  /// 트랜잭션을 사용하여 모든 작업이 성공하거나 모두 실패하도록 보장합니다.
  Future<void> acceptFriendRequest(String requestId, String fromUid) async {
    try {
      // 1. 현재 로그인한 유저의 `uid` (toUid)를 가져옴.
      final String? toUid = AuthService.currentUser?.uid;
      if (toUid == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 2. `FirebaseFirestore.instance.runTransaction()`을 사용하여 '트랜잭션'을 시작.
      //    (모두 성공하거나, 모두 실패해야 함)
      await _firestore.runTransaction((transaction) async {
        // 3. (트랜잭션 내부)

        // 4. (A) `friend_requests` 컬렉션의 'requestId' 문서를 찾아 `status`를 'accepted'로 '업데이트(update)'.
        final requestDocRef = _firestore.collection('friend_requests').doc(requestId);
        transaction.update(requestDocRef, {'status': 'accepted'});

        // 5. (B) '내' 친구 목록 (`users/{내 uid}/friends/{fromUid}`)에 '문서(set)'를 '추가'.
        //    (저장 내용은 {'addedAt': Timestamp.now()})
        final myFriendsDocRef = _firestore
            .collection('users')
            .doc(toUid)
            .collection('friends')
            .doc(fromUid);
        transaction.set(myFriendsDocRef, {
          'addedAt': FieldValue.serverTimestamp(),
        });

        // 6. (C) '상대' 친구 목록 (`users/{fromUid}/friends/{내 uid}`)에 '문서(set)'를 '추가'.
        final theirFriendsDocRef = _firestore
            .collection('users')
            .doc(fromUid)
            .collection('friends')
            .doc(toUid);
        transaction.set(theirFriendsDocRef, {
          'addedAt': FieldValue.serverTimestamp(),
        });
      });

      // 트랜잭션이 성공적으로 완료되었습니다.
    } catch (e) {
      // 7. `try-catch`로 트랜잭션 실패를 감지.
      // 친구 요청 수락 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  /// 내 친구 목록을 실시간으로 감지하는 스트림을 반환합니다.
  ///
  /// 반환값: 친구 문서들의 스냅샷 스트림 (최근 추가된 친구 순으로 정렬)
  Stream<QuerySnapshot> getMyFriendsStream() {
    try {
      // 1. 현재 로그인한 유저의 `uid`를 가져옴.
      final String? currentUserUid = AuthService.currentUser?.uid;
      if (currentUserUid == null) {
        // 로그인하지 않은 경우 빈 스트림을 반환합니다.
        return const Stream.empty();
      }

      // 2. `users/{currentUserUid}/friends` 컬렉션을 참조.
      final friendsCollection = _firestore
          .collection('users')
          .doc(currentUserUid)
          .collection('friends');

      // 3. `.orderBy('addedAt', descending: true)` (최근 추가된 친구 순)
      // 4. `.snapshots()`를 반환하여 '실시간' 친구 목록 스트림을 만듦.
      return friendsCollection
          .orderBy('addedAt', descending: true)
          .snapshots();
    } catch (e) {
      // 친구 목록 스트림 생성 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting my friends stream: $e');
      return const Stream.empty();
    }
  }

  /// 사용자의 현재 위치를 Firestore에 업데이트합니다.
  ///
  /// [position] 업데이트할 위치 데이터
  /// [status] 사용자의 현재 상태 (예: '🔥 굽기', '☁️ 말랑', '🧊 단단', '🍡 꼬치')
  /// `locations` 컬렉션에 `uid`를 문서 ID로 하여 위치 정보를 저장합니다.
  Future<void> updateUserLocation(Position position, {String? status}) async {
    try {
      // 1. 현재 로그인한 유저의 `uid`를 가져옴.
      final String? currentUserUid = AuthService.currentUser?.uid;
      if (currentUserUid == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 2. `locations` 컬렉션을 참조.
      final locationsCollection = _firestore.collection('locations');

      // 3. `doc(currentUserUid).set()`을 사용하여 문서를 '덮어쓰기' (업데이트).
      // 4. 저장할 데이터:
      //    - 'position': `GeoPoint(position.latitude, position.longitude)`
      //    - 'updatedAt': `Timestamp.now()`
      //    - 'status': 사용자의 현재 상태 (선택 사항)
      final updateData = <String, dynamic>{
        'position': GeoPoint(
          position.latitude,
          position.longitude,
        ),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 상태가 제공된 경우 추가하고, 없으면 기본값 '☁️ 말랑 (수신 대기)'를 설정합니다.
      if (status != null) {
        updateData['status'] = status;
      } else {
        // 상태가 없으면 기본값 설정 (기존 상태 유지 또는 기본값)
        updateData['status'] = '☁️ 말랑 (수신 대기)';
      }

      await locationsCollection.doc(currentUserUid).set(
        updateData,
        SetOptions(merge: true), // merge: true를 사용하여 기존 필드를 유지하면서 업데이트
      );
    } catch (e) {
      // 위치 업데이트 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error updating user location: $e');
      rethrow;
    }
  }

  /// 친구들의 실시간 위치를 감지하는 스트림을 반환합니다.
  ///
  /// [friendUids] 조회할 친구들의 UID 목록
  /// 반환값: 친구 위치 문서들의 스냅샷 스트림
  Stream<QuerySnapshot> getFriendsLocationsStream(List<String> friendUids) {
    try {
      // 1. `friendUids` 리스트가 '비어있으면' 빈 스트림(Stream.empty())을 반환
      //    (Firestore 'whereIn'은 빈 리스트를 허용 안 함)
      if (friendUids.isEmpty) {
        return const Stream.empty();
      }

      // 2. `locations` 컬렉션을 참조.
      final locationsCollection = _firestore.collection('locations');

      // 3. `where(FieldPath.documentId, whereIn: friendUids)` 쿼리를 사용해,
      //    '내 친구'들의 'uid'에 해당하는 위치 문서만 '필터링'.
      // 4. `.snapshots()`를 반환하여 '실시간' 위치 스트림을 만듦.
      return locationsCollection
          .where(FieldPath.documentId, whereIn: friendUids)
          .snapshots();
    } catch (e) {
      // 친구 위치 스트림 생성 중 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error getting friends locations stream: $e');
      return const Stream.empty();
    }
  }
}


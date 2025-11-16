// Firestore의 'users' 문서를 Dart 객체로 변환하기 위한 모델 클래스입니다.
// 데이터베이스와 앱 로직 간의 타입 안전성을 보장합니다.

/// 사용자 모델 클래스
///
/// Firestore의 'users' 컬렉션 문서를 Dart 객체로 표현합니다.
class UserModel {
  /// 사용자의 고유 ID (Firestore 문서 ID)
  final String uid;

  /// 사용자의 이메일 주소
  final String email;

  /// 사용자의 표시 이름
  final String displayName;

  /// 사용자의 전화번호 (선택적)
  final String? phoneNumber;

  /// 생성자
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
  });

  /// Firestore 문서로부터 UserModel 객체를 생성하는 팩토리 생성자
  ///
  /// [map] Firestore 문서의 데이터 (Map<String, dynamic>)
  /// [documentId] Firestore 문서 ID
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String?,
    );
  }
}


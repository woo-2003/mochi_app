// Firebase 인증 및 Google 로그인을 담당하는 서비스 로직을 정의합니다.
// 비즈니스 로직은 UI와 분리하여 유지보수성을 높이기 위해 서비스 계층으로 구성합니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase 인증과 Google 로그인을 담당하는 서비스입니다.
///
/// 싱글톤 패턴을 사용해 앱 전역에서 동일한 인스턴스를 손쉽게 사용할 수 있도록 합니다.
class AuthService {
  /// 싱글톤 인스턴스
  static final AuthService instance = AuthService._internal();

  /// FirebaseAuth 인스턴스
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// GoogleSignIn 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService._internal();

  /// Google 로그인 흐름을 처리한 뒤 Firebase 사용자 정보를 반환합니다.
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Google 로그인 팝업을 띄우고 유저 정보를 받음 (google_sign_in)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우 null을 반환합니다.
        return null;
      }

      // 2. Google 유저 정보에서 인증 토큰(idToken, accessToken)을 추출
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 토큰이 정상적으로 발급되지 않은 경우 안전하게 종료합니다.
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        return null;
      }

      // 3. 이 토큰으로 Firebase 인증 자격 증명(Credential)을 생성
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. 이 자격 증명으로 FirebaseAuth.instance.signInWithCredential()을 호출
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // 5. 로그인 성공 시 Firebase User 객체를 반환하고, 실패 시 null 반환
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 과정에서 발생한 예외를 로깅하거나 추후 처리할 수 있습니다.
      // 현재는 간단히 콘솔 로그로 확인합니다.
      // ignore: avoid_print
      print('FirebaseAuthException: ${e.message}');
      return null;
    } catch (e) {
      // 예상치 못한 에러를 대비해 일반 예외도 처리합니다.
      // ignore: avoid_print
      print('Unknown error during Google sign-in: $e');
      return null;
    }
  }
}

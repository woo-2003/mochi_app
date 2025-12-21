// Firebase 인증 및 Google 로그인을 담당하는 서비스 로직을 정의합니다.
// 비즈니스 로직은 UI와 분리하여 유지보수성을 높이기 위해 서비스 계층으로 구성합니다.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:mochi_app/services/database_service.dart';

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

  /// 현재 로그인한 사용자를 반환하는 getter입니다.
  ///
  /// 로그인하지 않은 경우 null을 반환합니다.
  static User? get currentUser => FirebaseAuth.instance.currentUser;

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

      // (신규) 로그인 성공 시, 유저 정보를 DB에 저장
      if (userCredential.user != null) {
        await DatabaseService.instance.saveUser(userCredential.user!);
      }

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

  /// 카카오 로그인 흐름을 처리한 뒤 Firebase 사용자 정보를 반환합니다.
  ///
  /// 카카오 계정 정보를 이용해 Firebase에 '투명 로그인(Proxy Login)'하는 로직을 구현합니다.
  Future<User?> signInWithKakao() async {
    try {
      // 1. 카카오톡이 설치되어 있는지 확인 (전역 함수 사용)
      bool isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();

      if (isKakaoTalkInstalled) {
        // 2-1. 카카오톡이 설치되어 있으면 카카오톡으로 로그인
        await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        // 2-2. 카카오톡이 설치되어 있지 않으면 카카오 계정으로 로그인
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 3. 로그인 성공 시 사용자 정보 가져오기
      kakao.User kakaoUser = await kakao.UserApi.instance.me();
      final String kakaoId = kakaoUser.id.toString();
      final String? nickname = kakaoUser.kakaoAccount?.profile?.nickname;

      // 4. (Firebase 연동 트릭) 카카오 ID를 이용해 가짜 이메일과 비밀번호 생성
      // 이메일: kakao_{id}@mochi.app
      // 비밀번호: 카카오 ID를 해시화한 값 (실제로는 사용하지 않지만 Firebase 요구사항)
      final String proxyEmail = 'kakao_$kakaoId@mochi.app';
      final String proxyPassword =
          'kakao_${kakaoId}_password'; // 간단한 비밀번호 (실제로는 사용 안 함)

      // 5. Firebase Auth로 로그인 시도
      UserCredential? userCredential;
      bool isNewUser = false;
      try {
        // 기존 계정이 있으면 로그인
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: proxyEmail,
          password: proxyPassword,
        );
      } catch (e) {
        // 로그인 실패 시 에러 코드 확인 없이 무조건 회원가입 시도
        try {
          // 6. 계정이 없으면 새로 생성
          userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: proxyEmail,
            password: proxyPassword,
          );
          isNewUser = true; // 회원가입 성공 플래그
        } catch (createError) {
          // 회원가입도 실패하면 에러 출력
          // ignore: avoid_print
          print('회원가입 실패: $createError');
          rethrow;
        }
      }

      // 7. 사용자 정보 처리
      if (userCredential.user != null) {
        // Firebase User의 displayName을 카카오 닉네임으로 업데이트
        await userCredential.user!.updateDisplayName(nickname ?? '카카오 사용자');
        // 회원가입 성공 시에만 DB에 저장
        if (isNewUser) {
          await DatabaseService.instance.saveUser(userCredential.user!);
        }
      }

      return userCredential.user;
    } on kakao.KakaoException catch (e) {
      // 카카오 로그인 과정에서 발생한 예외를 로깅합니다.
      // ignore: avoid_print
      print('KakaoException: ${e.toString()}');
      return null;
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 과정에서 발생한 예외를 로깅합니다.
      // ignore: avoid_print
      print('FirebaseAuthException: ${e.message}');
      return null;
    } catch (e) {
      // 예상치 못한 에러를 대비해 일반 예외도 처리합니다.
      // ignore: avoid_print
      print('Unknown error during Kakao sign-in: $e');
      return null;
    }
  }

  /// 사용자를 로그아웃 처리합니다.
  ///
  /// Google 계정과 Firebase Auth 양쪽에서 모두 로그아웃하여,
  /// 다음 로그인 시 다시 로그인 팝업이 나타나도록 합니다.
  Future<void> signOut() async {
    try {
      // 1. Google 계정에서 로그아웃 (다시 로그인 팝업을 띄우기 위함)
      await _googleSignIn.signOut();

      // 2. 카카오 계정에서 로그아웃
      try {
        await kakao.UserApi.instance.logout();
      } catch (e) {
        // 카카오 로그아웃 실패는 무시 (이미 로그아웃된 경우)
        // ignore: avoid_print
        print('Kakao logout error (ignored): $e');
      }

      // 3. Firebase Auth에서 로그아웃
      await _firebaseAuth.signOut();
    } catch (e) {
      // 로그아웃 과정에서 오류가 발생한 경우 로깅합니다.
      // ignore: avoid_print
      print('Error during sign out: $e');
      rethrow;
    }
  }
}

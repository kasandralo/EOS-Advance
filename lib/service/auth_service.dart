import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as KakaoUser;

class AuthService extends ChangeNotifier {
  User? currentUser() {
    // 현재 유저(로그인 되지 않은 경우 null 반환)
    return FirebaseAuth.instance.currentUser;
  }

  void signUp({
    required String email, // 이메일
    required String password, // 비밀번호
    required Function() onSuccess, // 가입 성공시 호출되는 함수
    required Function(String err) onError, // 에러 발생시 호출되는 함수
  }) async {
    // 회원가입
    if (email.isEmpty || password.isEmpty) {
      onError('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      onSuccess();
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            onError('이미 사용 중인 이메일입니다. 다른 이메일을 사용하거나 로그인을 시도해보세요.');
            break;
          case 'weak-password':
            onError('비밀번호가 너무 약합니다. 6자리 이상으로 문자, 숫자, 특수문자를 조합해 보세요.');
            break;
          case 'invalid-email':
            onError('유효하지 않은 이메일 형식입니다. 정확한 이메일 주소를 입력해주세요.');
            break;
          case 'operation-not-allowed':
            onError('이메일/비밀번호 계정이 비활성화되어 있습니다. 관리자에게 문의하세요.');
            break;
          case 'network-request-failed':
            onError('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
            break;
          default:
            onError('회원가입 중 오류가 발생했습니다. (오류 코드: ${e.code})');
            break;
        }
      } else {
        onError('회원가입 중 예상치 못한 오류가 발생했습니다: ${e.toString()}');
      }
    }
  }

  void signIn({
    required String email, // 이메일
    required String password, // 비밀번호
    required Function() onSuccess, // 로그인 성공시 호출되는 함수
    required Function(String err) onError, // 에러 발생시 호출되는 함수
  }) async {
    // 로그인
    if (email.isEmpty || password.isEmpty) {
      onError('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      onSuccess();
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            onError('유효하지 않은 이메일 형식입니다.');
            break;
          case 'wrong-password':
            onError('비밀번호가 일치하지 않습니다.');
            break;
          case 'user-not-found':
            onError('존재하지 않는 이메일입니다.');
            break;
          default:
            onError('로그인 중 오류가 발생했습니다.');
            break;
        }
      } else {
        onError('로그인 중 오류가 발생했습니다.');
      }
    }
  }

  void signOut() async {
    // 로그아웃
  }

  // TODO: [과제 1-2] Google 로그인 및 Firebase 연동 메서드 구현
  /*
   * Google 로그인 및 Firebase 연동 메서드
   *
   * 구현 단계:
   * 1. GoogleSignIn 인스턴스 생성 및 로그인 요청
   *    - GoogleSignIn().signIn() 호출
   *    - 사용자 계정 선택 및 권한 동의 과정 처리
   *
   * 2. 인증 정보 획득
   *    - googleUser.authentication 호출하여 accessToken과 idToken 획득
   *
   * 3. Firebase 인증 정보 생성
   *    - GoogleAuthProvider.credential()로 OAuthCredential 생성
   *    - accessToken과 idToken 전달
   *
   * 4. Firebase 인증 완료
   *    - FirebaseAuth.instance.signInWithCredential() 호출
   *
   * 5. 성공/실패 처리
   *    - 성공 시 onSuccess 콜백 호출
   *    - 실패 시 오류 내용에 따라 구분하여 onError 콜백 호출
   */
  Future<void> signInWithGoogle({
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    // 여기에 구글 로그인 로직을 구현하세요
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await googleSignIn.signIn();
      
      if (account == null) {
        onError("사용자가 로그인을 취소했습니다.");
        return;
      }

      final GoogleSignInAuthentication authentication =
        await account.authentication;
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
      );
      final UserCredential credential = 
        await FirebaseAuth.instance.signInWithCredential(googleCredential);

      final user = credential.user;

      if (user != null) {
        onSuccess();
      } else {
        onError("사용자 정보를 가져오지 못했습니다.");
        return;
      }
    } catch (e) {
      onError("구글 로그인 중 오류가 발생했습니다: ${e.toString()}");
      return;
    }
  }

  // TODO: [과제 2-2] 카카오 로그인 및 Firebase 연동 메서드 구현
  /*
   * 카카오 로그인 및 Firebase 연동 메서드
   *
   * 구현 단계:
   * 1. 카카오 SDK 초기화
   *    - KakaoSdk.init() 호출 (main.dart에서 초기화 또는 여기서)
   *
   * 2. 카카오 로그인 요청 및 토큰 획득
   *    - UserApi.instance.loginWithKakaoAccount() 사용
   *    - 토큰 발급 확인
   *
   * 3. Firebase Functions 호출하여 커스텀 토큰 획득
   *    - 카카오 액세스 토큰을 Firebase 커스텀 토큰으로 교환하는 HTTP 요청
   *    - 서버는 토큰 검증 후 Firebase 커스텀 토큰 발행
   *
   * 4. Firebase 인증
   *    - FirebaseAuth.instance.signInWithCustomToken() 호출
   *
   * 5. 성공/실패 처리
   *    - 성공 시 onSuccess 콜백 호출
   *    - 실패 시 오류 내용에 따라 구분하여 onError 콜백 호출
   */
  Future<void> signInWithKakao({
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    try {
      KakaoUser.OAuthToken token = await KakaoUser.UserApi.instance.loginWithKakaoAccount();
      print("뭔가 이상함");

      if (token.accessToken == null) {
        onError("카카오 로그인 중 오류가 발생했습니다.");
        return;
      }

      final credential = OAuthProvider("oidc.kakao").credential(idToken: null, accessToken: token.accessToken);
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        onSuccess();
      } else {
        onError('Firebase 사용자 없음');
      }
    } catch (e) {
      onError("카카오 OIDC 로그인 실패: $e");
    }
  }
}

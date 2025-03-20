import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eos_advance_login/screens/home_screen.dart';
import 'package:eos_advance_login/theme/res/palette.dart';
import 'package:eos_advance_login/theme/light_theme.dart';
import 'package:eos_advance_login/theme/foundation/app_theme.dart';

/// 로그인 화면 - 이메일 로그인과 소셜 로그인 기능을 제공합니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 이메일과 비밀번호를 관리할 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late final AppTheme theme = LightTheme();

  @override
  void dispose() {
    // 메모리 누수 방지를 위한 컨트롤러 해제
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 화면의 빈 공간 터치 시 키보드 닫기
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.color.surface,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              // 1. 메인 콘텐츠 영역 (스크롤 가능)
              Expanded(
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // EOS 로고 표시
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 40, bottom: 24),
                        child: Image.asset(
                          'assets/images/eos_logo.png',
                          width: 360,
                          height: 144,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 이메일 입력 필드
                            _buildTextField(
                              controller: _emailController,
                              labelText: '이메일',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // 비밀번호 입력 필드
                            _buildTextField(
                              controller: _passwordController,
                              labelText: '비밀번호',
                              prefixIcon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: theme.color.subtext,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 로그인 버튼
                            _buildButton(
                              text: '로그인',
                              onPressed: () => _handleEmailLogin(context),
                              backgroundColor: theme.color.primary,
                              textColor: theme.color.onPrimary,
                            ),

                            const SizedBox(height: 16),

                            // 비밀번호 찾기 & 회원가입 링크
                            _buildAccountActions(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. 소셜 로그인 영역 - 고정 위치에 배치
              Material(
                elevation: 0,
                color: theme.color.surface,
                child: _buildSocialLoginSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 재사용 가능한 텍스트 필드 위젯
  /// - 일관된 디자인의 입력 필드를 생성합니다.
  /// - border, 색상, 아이콘 등의 스타일이 통일되어 있습니다.
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: theme.typo.body1,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: theme.typo.subtitle2.copyWith(color: theme.color.subtext),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.color.hint, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.color.inactive, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.color.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.color.background.withOpacity(0.3),
        prefixIcon: Icon(prefixIcon, color: theme.color.primary),
        suffixIcon: suffixIcon,
      ),
    );
  }

  /// 재사용 가능한 버튼 위젯
  /// - 모든 버튼에 동일한 높이와 스타일을 적용합니다.
  /// - 아이콘 유무에 따라 레이아웃이 조정됩니다.
  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    Widget? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: backgroundColor == theme.color.surface
                ? BorderSide(color: theme.color.inactiveContainer, width: 1)
                : BorderSide.none,
          ),
          elevation: 0, // 그림자 효과 제거
        ),
        onPressed: onPressed,
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: theme.typo.subtitle1.copyWith(
                      color: textColor,
                      fontWeight: theme.typo.medium,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: theme.typo.subtitle1.copyWith(
                  color: textColor,
                ),
              ),
      ),
    );
  }

  /// 비밀번호 찾기 & 회원가입 링크 섹션
  /// - 두 액션 버튼을 구분선으로 나누어 표시합니다.
  Widget _buildAccountActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _handlePasswordReset(context),
            // TODO: [과제 2-2] 비밀번호 재설정 기능 구현
            /*
             * 비밀번호 재설정 과제
             * 
             * 구현 단계:
             * 1. 이메일 입력 다이얼로그 구현
             *    - AlertDialog 또는 SimpleDialog 사용
             *    - TextEditingController를 사용하여 이메일 입력값 관리
             *    - 취소/확인 버튼 제공
             * 
             * 2. 비밀번호 재설정 요청 처리
             *    - FirebaseAuth.instance.sendPasswordResetEmail() 메서드 사용
             *    - 이메일 형식 유효성 검증
             *    - 요청 성공/실패에 따른 피드백 제공
             *    - 오류 처리 (사용자가 존재하지 않을 경우 등)
             */
          
          child: Text(
            '비밀번호 재설정',
            style: theme.typo.body1.copyWith(
              color: theme.color.subtext,
            ),
          ),
        ),
        // 세로 구분선
        Container(
          height: 16,
          width: 1,
          color: theme.color.hint,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        TextButton(
          onPressed: () => _handleSignUp(context),
            // TODO: [과제 2-3] 회원가입 기능 구현
            /*
             * 회원가입 과제
             * 
             * 구현 단계:
             * 1. 회원가입 입력 폼 구현
             *    - 이메일 입력 필드
             *    - 비밀번호 입력 필드 (obscureText: true)
             *    - 비밀번호 확인 필드 (두 비밀번호 일치 여부 확인)
             *    - 다이얼로그 또는 별도 화면으로 구현 가능
             * 
             * 2. 입력값 유효성 검사
             *    - 이메일 형식 검증
             *    - 비밀번호 길이 및 강도 검증 (6자 이상)
             *    - 비밀번호-확인 일치 여부 확인
             * 
             * 3. Firebase 회원가입 요청 처리
             *    - FirebaseAuth.instance.createUserWithEmailAndPassword() 메서드 사용
             *    - 주요 오류 코드 처리:
             *      > email-already-in-use: 이미 사용 중인 이메일
             *      > weak-password: 취약한 비밀번호
             *      > invalid-email: 유효하지 않은 이메일 형식
             *    - 성공 시 자동 로그인 처리
             */
          
          child: Text(
            '회원가입',
            style: theme.typo.body1.copyWith(
              color: theme.color.primary,
              fontWeight: theme.typo.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  /// 소셜 로그인 섹션
  /// - 간편 로그인 옵션들을 포함하는 하단 고정 영역입니다.
  Widget _buildSocialLoginSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: theme.color.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 구분선과 "간편 로그인" 텍스트
          Row(
            children: [
              Expanded(child: Divider(color: theme.color.hint)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '간편 로그인',
                  style: theme.typo.body1.copyWith(color: theme.color.hint),
                ),
              ),
              Expanded(child: Divider(color: theme.color.hint)),
            ],
          ),

          const SizedBox(height: 20),

          // 소셜 로그인 버튼들
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 카카오 로그인 버튼
              _buildSocialButton(
                text: '카카오로 로그인',
                onPressed: () => _handleKakaoLogin(context),
                backgroundColor: const Color(0xFFFEE500),
                textColor: Colors.black,
                iconPath: 'assets/icons/kakao_logo.svg',
              ),

              const SizedBox(height: 12),

              // 구글 로그인 버튼
              _buildSocialButton(
                text: '구글로 로그인',
                onPressed: () => _handleGoogleLogin(context),
                backgroundColor: theme.color.surface,
                textColor: theme.color.text,
                iconPath: 'assets/icons/google_logo.svg',
              ),

              const SizedBox(height: 12),

              // 애플 로그인 버튼
              _buildSocialButton(
                text: '애플로 로그인',
                onPressed: () => _handleAppleLogin(context),
                backgroundColor: Colors.black,
                textColor: Colors.white,
                iconPath: 'assets/icons/apple_logo.svg',
                iconColor: Colors.white,
              ),
            ],
          ),

          // 이용약관 동의 안내 텍스트
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'ⓘ 로그인하면 이용약관 및 개인정보활용에 동의하게 됩니다.',
              textAlign: TextAlign.center,
              style: theme.typo.body2.copyWith(
                color: theme.color.onHintContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 소셜 로그인 버튼 생성 헬퍼 메서드
  /// - SVG 아이콘을 포함한 소셜 로그인 버튼을 생성합니다.
  Widget _buildSocialButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    Color? iconColor,
  }) {
    return _buildButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
      ),
    );
  }

  /// 이메일 로그인 처리 메서드
  Future<void> _handleEmailLogin(BuildContext context) async {
    // TODO: [과제 2-1] Firebase Auth를 사용한 이메일 로그인 구현
    /*
     * 이메일/비밀번호 로그인 구현 과제
     * 
     * 구현 단계:
     * 1. 입력값 유효성 검사
     *    - 이메일 형식: RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)
     *    - 비밀번호 검증: password.length >= 6
     * 
     * 2. Firebase 로그인 요청 전송
     *    - FirebaseAuth.instance.signInWithEmailAndPassword() 메서드 사용
     *    - 로그인 성공 시 HomeScreen으로 자동 이동 (authStateChanges 사용)
     *    - 주요 오류 코드 처리:
     *      > user-not-found: 등록되지 않은 이메일
     *      > wrong-password: 잘못된 비밀번호
     *      > invalid-email: 유효하지 않은 이메일 형식
     *      > user-disabled: 비활성화된 계정
     *    - 오류 메시지를 SnackBar로 사용자에게 표시
     */

    // 입력값 검증 (현재 코드는 유지)
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효하지 않은 이메일 형식'))
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('잘못된 비밀번호')),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = '등록되지 않은 이메일';
      } else if (e.code == 'wrong-password') {
        errorMessage = '잘못된 비밀번호';
      } else if (e.code == 'invalid-email') {
        errorMessage = '유효하지 않은 이메일 형식';
      } else if (e.code == 'user-disabled') {
        errorMessage = '비활성화된 계정';
      } else{
        errorMessage = '로그인에 실패했습니다. 다시 시도해주세요.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    // 테스트용 로그인 메시지 (실제 구현 시 제거)
    _showLoginMessage(context, '이메일');
  }

  Future<void> _handlePasswordReset(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('비밀번호 재설정'),
          content: TextField(
            controller: emailController, 
            decoration: const InputDecoration(labelText: '이메일'), 
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text;

                // 이메일 형식 유효성 검사
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('유효한 이메일 주소를 입력해주세요.')),
                  );
                  return;
                }

                try {
                  // Firebase 비밀번호 재설정 이메일 전송
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호 재설정 이메일을 보냈습니다.')),
                  );
                  Navigator.of(context).pop();  // 다이얼로그 닫기
                } on FirebaseAuthException catch (e) {
                  String errorMessage = '';
                  if (e.code == 'invalid-email') {
                    errorMessage == '유효하지 않은 이메일 형식';
                  } else if (e.code == 'user-not-found') {
                    errorMessage == '등록되지 않은 이메일';
                  } else {
                    errorMessage = '오류가 발생했습니다. 다시 시도해주세요.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      }
    );
  }

  Future<void> _handleSignUp(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // 이메일 및 비밀번호 유효성 검사
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 이메일 주소를 입력해주세요.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 6자 이상이어야 합니다.')),
      );
      return;
    }

    try {
      // Firebase 회원가입 시도
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 회원가입 성공 시 자동 로그인
      Navigator.pushReplacementNamed(context, '/home');  // HomeScreen으로 이동

    } on FirebaseAuthException catch (e) {
      String errorMessage = '';

      // 오류 처리
      if (e.code == 'email-already-in-use') {
        errorMessage = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'weak-password') {
        errorMessage = '비밀번호가 너무 약합니다.';
      } else if (e.code == 'invalid-email') {
        errorMessage = '유효하지 않은 이메일 주소입니다.';
      } else {
        errorMessage = '회원가입에 실패했습니다. 다시 시도해주세요.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  /// 카카오 로그인 처리 메서드
  void _handleKakaoLogin(BuildContext context) {
    // 카카오 로그인 로직 구현 위치
    _showLoginMessage(context, '카카오');
  }

  /// 구글 로그인 처리 메서드
  void _handleGoogleLogin(BuildContext context) {
    // 구글 로그인 로직 구현 위치
    _showLoginMessage(context, '구글');
  }

  /// 애플 로그인 처리 메서드
  void _handleAppleLogin(BuildContext context) {
    // 애플 로그인 로직 구현 위치
    _showLoginMessage(context, '애플');
  }

  /// 테스트용 로그인 메시지 표시
  void _showLoginMessage(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider 로그인 시도 중...')),
    );
  }
}

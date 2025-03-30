import 'package:eos_advance_login/screens/home_screen.dart';
import 'package:eos_advance_login/service/auth_service.dart';
import 'package:eos_advance_login/theme/res/palette.dart';
import 'package:eos_advance_login/theme/light_theme.dart';
import 'package:eos_advance_login/theme/foundation/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
    return Consumer<AuthService>(builder: (context, authService, child) {
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
    });
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
          onPressed: () {
            final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('비밀번호 재설정'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: '이메일 주소',
            hintText: 'example@email.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();

              // 이메일 형식 유효성 검사 (간단히 @ 포함 여부로)
              if (!email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('올바른 이메일을 입력하세요.')),
                );
                return;
              }

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('비밀번호 재설정 이메일이 전송되었습니다.')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('오류 발생: ${e.toString()}')),
                );
              }
            },
            child: Text('확인'),
          ),
        ],
      );
    },
  );
            // TODO: [과제 1-1] 비밀번호 재설정 기능 구현
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
          },
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
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).signUp(
              email: _emailController.text,
              password: _passwordController.text,
              onSuccess: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              onError: (err) {
                _showLoginMessage(context, '이메일');
              },
            );
          },
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
  void _handleEmailLogin(BuildContext context) {
    // 입력값이 비어있는지 검사
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }
    
    // 이메일 형식 검사
    final bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text);
    if (!isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 이메일 형식이 아닙니다.')),
      );
      return;
    }

    // 비밀번호 길이 검사
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 6자 이상이어야 합니다.')),
      );
      return;
    }

    // Firebase 로그인 요청
    Provider.of<AuthService>(context, listen: false).signIn(
      email: _emailController.text,
      password: _passwordController.text,
      onSuccess: () {
        // 로그인 성공 시 처리
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 성공!')),
        );
      },
      onError: (err) {
        // 로그인 실패 시 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $err')),
        );
      },
    );
  }

  /// 카카오 로그인 처리 메서드
  void _handleKakaoLogin(BuildContext context) {
    // TODO: [과제 2-3] 카카오 로그인 구현
    /*
     * 카카오 로그인 및 Firebase 연동 과제
     * 
     * 구현 단계:
     * 1. pubspec.yaml에 kakao_flutter_sdk 패키지 추가
     *    - kakao_flutter_sdk: ^1.4.1 또는 최신 버전
     * 
     * 2. 카카오 개발자 콘솔에서 앱 등록 및 설정
     *    - 네이티브 앱 키 발급
     *    - 카카오 로그인 활성화
     *    - iOS/Android 플랫폼 정보 등록
     * 
     * 3. 각 플랫폼 설정 업데이트
     *    - Android: AndroidManifest.xml에 카카오 앱키 추가
     *    - iOS: Info.plist에 URL 스킴 등록
     * 
     * 4. AuthService 클래스에 카카오 로그인 메서드 구현
     *    - signInWithKakao() 메서드 생성
     *    - 카카오 로그인 후 Firebase 커스텀 토큰 인증 연결
     * 
     * 5. 필요한 Firebase Functions 구현
     *    - 카카오 토큰을 Firebase 토큰으로 교환하는 함수
     * 
     * 6. 로그인 성공/실패 처리
     *    - 로그인 성공 시 홈 화면으로 이동
     *    - 오류 발생 시 적절한 피드백 제공
     */
    final auth = AuthService();
    auth.signInWithKakao(
      onSuccess: () {
        // 로그인 성공 시 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오 로그인 성공!')),
        );
      },
      onError: (err) {
        // 로그인 실패 시 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $err')),
        );
        print('$err');
      },
    );
    _showLoginMessage(context, '카카오');
  }

  /// 구글 로그인 처리 메서드
  void _handleGoogleLogin(BuildContext context) {
    final auth = AuthService();
    auth.signInWithGoogle(
      onSuccess: () {
        // 로그인 성공 시 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구글 로그인 성공!')),
        );
      },
      onError: (err) {
        // 로그인 실패 시 오류 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 실패: $err')),
        );
        print('$err');
      },
    );
    // TODO: [과제 1-3] 구글 로그인 구현
    /*
     * 구글 로그인 및 Firebase 연동 과제
     * 
     * 구현 단계:
     * 1. 로딩 상태 표시
     *    - 로그인 진행 중임을 사용자에게 알리는 UI 표시
     * 
     * 2. AuthService의 signInWithGoogle 메서드 호출
     *    - Provider를 통해 AuthService 인스턴스 접근
     * 
     * 3. 로그인 성공 처리
     *    - 로딩 표시 제거
     *    - 홈 화면으로 이동 (Navigator.pushReplacement 사용)
     *    - 성공 메시지 표시 (SnackBar 등 사용)
     * 
     * 4. 로그인 실패 처리
     *    - 로딩 표시 제거
     *    - 오류 메시지 표시 (오류 내용에 따라 적절한 메시지)
     *    - 재시도 옵션 제공 (선택사항)
     */
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

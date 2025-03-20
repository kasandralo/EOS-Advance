import 'package:eos_advance_login/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eos_advance_login/theme/light_theme.dart';
import 'package:eos_advance_login/theme/foundation/app_theme.dart';

/// 홈 화면 - 로그인 성공 후 표시되는 화면입니다.
/// Firebase Auth를 사용한 로그아웃 기능을 구현해야 합니다.
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = LightTheme();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.color.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 환영 메시지 - 크게 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.color.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.color.primary, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'EOS Advance 2주차 과제를',
                    style: theme.typo.body1.copyWith(
                      color: theme.color.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '완료하신 여러분들 환영합니다!',
                    style: theme.typo.body1.copyWith(
                      color: theme.color.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.celebration,
                    size: 48,
                    color: theme.color.primary,
                  ),
                ],
              ),
            ),

            // TODO: [과제 3-1] 현재 로그인한 사용자 정보 표시
            /*
             * 1. 사용자 정보 가져오기:
              *    final user = FirebaseAuth.instance.currentUser;
              *    
              * 2. 사용자 이메일 표시:
              *    Text(user?.email ?? '로그인 필요')
             * - FirebaseAuth.instance.currentUser?.email을 사용하여 사용자 이메일 가져오기
             * - 사용자 정보가 없는 경우 대체 텍스트 표시
             */
            // 사용자 이메일을 화면에 표시하는 코드 추가

            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '로그인한 이메일: ${user?.email ?? '로그인 필요'}',
                style: theme.typo.body1.copyWith(
                  color: theme.color.subtext,
                ),
              ),
            ),

            // 추가 정보 메시지
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '로그인에 성공하셨습니다!',
                style: theme.typo.body1.copyWith(
                  color: theme.color.subtext,
                ),
              ),
            ),

            // 로그아웃 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                width: 240,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.color.primary,
                    foregroundColor: theme.color.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0, // 그림자 효과 제거
                  ),
                  onPressed: () => _handleLogout(context),
                  child: Text(
                    '로그아웃',
                    style: theme.typo.body1.copyWith(
                      color: theme.color.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 로그아웃 처리 메서드
  void _handleLogout(BuildContext context) async {
    // TODO: [과제 3-2] Firebase Auth를 사용한 로그아웃 구현
    /*
     * 로그아웃 기능 구현 과제
     * 
     * 구현 단계:
     * 1. Firebase 로그아웃 처리
     *    try {
     *      await FirebaseAuth.instance.signOut();
     *      // authStateChanges()를 사용 중이라면 자동으로 로그인 화면으로 이동
     *    } catch (e) {
     *      // 오류 처리
     *      ScaffoldMessenger.of(context).showSnackBar(
     *        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
     *      );
     *    }
     * 
     * 2. 수동 화면 이동 (필요한 경우)
     *    - Navigator.of(context).pushAndRemoveUntil()을 사용하여
     *      화면 스택을 비우고 로그인 화면으로 이동
     */
    try {
      // Firebase 로그아웃 처리
      await FirebaseAuth.instance.signOut();

      // 로그아웃 후, 로그인 화면으로 이동
      // Navigator.of(context).pushAndRemoveUntil(
      //   MaterialPageRoute(builder: (context) => const LoginScreen()), // 로그인 화면으로 이동
      //   (Route<dynamic> route) => false, // 모든 기존 화면 제거
      // );
    } catch (e) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }
}

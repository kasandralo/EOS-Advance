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

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.color.background.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.color.primary, width: 1),
              ),
              child: Column(
                children: [
                  Text(
                    '환영합니다!',
                    style: theme.typo.body1.copyWith(
                      color: theme.color.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person,
                        size: 20,
                        color: theme.color.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? '로그인 필요',
                        style: theme.typo.body1.copyWith(
                          color: theme.color.text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
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
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }
}

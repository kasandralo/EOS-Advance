import 'package:eos_advance_login/firebase_options.dart';
import 'package:eos_advance_login/screens/home_screen.dart';
import 'package:eos_advance_login/service/auth_service.dart';
import 'package:eos_advance_login/screens/login_screen.dart';
import 'package:eos_advance_login/theme/light_theme.dart';
import 'package:eos_advance_login/theme/foundation/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as KakaoUser;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: [과제 2-1] 카카오 SDK 초기화
  /*
   * 카카오 SDK 초기화 코드
   * - 카카오 개발자 콘솔에서 발급받은 네이티브 앱 키를 사용하여 초기화
   * - KakaoSdk.init(nativeAppKey: '네이티브_앱_키') 호출
   */
  try {
    // final keyHash = await KakaoUser.KakaoSdk.origin;
    // print("키해시: $keyHash");
    KakaoUser.KakaoSdk.init(nativeAppKey: '3db28dbc12c047e27ebaf2a5fff15498', javaScriptAppKey: '47cdf0902e067b773c09ff24ddeb37f9',);
    print('Kakao SDK 초기화 성공');
  } catch (e) {
    print('Kakao SDK 초기화 오류: $e');
  }

  // Firebase 초기화 수정
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // 필요시 주석 해제
    );
    print('Firebase 초기화 성공');
  } catch (e) {
    print('Firebase 초기화 오류: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 애플리케이션의 루트 위젯
/// - 앱의 전체 테마 및 초기 화면을 설정합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = LightTheme();

    return MaterialApp(
      title: 'EOS Advance Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: theme.color.primary),
        useMaterial3: true,
        fontFamily: 'Pretendard', // 프리텐다드 폰트 기본 적용
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 인증 상태 확인 중일 때 로딩 표시
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // 로그인된 유저가 있으면 HomeScreen, 없으면 LoginScreen
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

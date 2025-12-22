import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import 'services/token_storage.dart';
import 'services/onboarding_api.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';

import 'screens/onboarding/onboarding_page_01.dart';
import 'screens/onboarding/onboarding_page_02.dart';
import 'screens/onboarding/onboarding_page_03.dart';
import 'screens/onboarding/onboarding_page_04.dart';
import 'screens/onboarding/onboarding_page_05.dart';
import 'screens/onboarding/onboarding_page_06.dart';
import 'screens/onboarding/onboarding_page_07.dart';
import 'screens/onboarding/onboarding_page_08.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MuudApp());
}

class MuudApp extends StatefulWidget {
  const MuudApp({super.key});

  @override
  State<MuudApp> createState() => _MuudAppState();
}

class _MuudAppState extends State<MuudApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _initLinks();
  }

  Future<void> _initLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleUri(initialUri);
    } catch (e) {
      debugPrint("❌ getInitialLink error: $e");
    }

    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) => _handleUri(uri),
      onError: (err) => debugPrint("❌ link stream error: $err"),
    );
  }

  void _handleUri(Uri uri) {
    debugPrint("🔗 Deep link received: $uri");
    if (uri.host == 'auth' && uri.path == '/callback') {
      final code = uri.queryParameters['code'];
      debugPrint("✅ OAuth code: $code");
      // (Your Cognito OAuth exchange can stay in your service)
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MUUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),

      home: const Boot(),

      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/otp': (_) => const OtpScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/reset': (_) => const ResetPasswordScreen(),
        '/home': (_) => const HomeScreen(),

        // Onboarding
        '/onboarding/01': (_) => const OnboardingPage01(),
        '/onboarding/02': (_) => const OnboardingPage02(),
        '/onboarding/03': (_) => const OnboardingPage03(),
        '/onboarding/04': (_) => const OnboardingPage04(),
        '/onboarding/05': (_) => const OnboardingPage05(),
        '/onboarding/06': (_) => const OnboardingPage06(),
        '/onboarding/07': (_) => const OnboardingPage07(),
        '/onboarding/08': (_) => const OnboardingPage08(),
      },

      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const Boot()),
    );
  }
}

class Boot extends StatefulWidget {
  const Boot({super.key});

  @override
  State<Boot> createState() => _BootState();
}

class _BootState extends State<Boot> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (!mounted) return;

    // 1) No token → login
    if (accessToken == null || accessToken.isEmpty) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // 2) Token exists → check onboarding status
    try {
      final completed = await OnboardingApi.isCompleted();
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacementNamed(completed ? '/home' : '/onboarding/01');
    } catch (_) {
      // token bad/expired → logout
      await TokenStorage.clearTokens();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

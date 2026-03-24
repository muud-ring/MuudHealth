import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';

import 'services/error_reporting.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/verify_reset_code_screen.dart';
import 'screens/edit_profile_screen.dart';

import 'screens/onboarding/onboarding_page_01.dart';
import 'screens/onboarding/onboarding_page_02.dart';
import 'screens/onboarding/onboarding_page_03.dart';
import 'screens/onboarding/onboarding_page_04.dart';
import 'screens/onboarding/onboarding_page_05.dart';
import 'screens/onboarding/onboarding_page_06.dart';
import 'screens/onboarding/onboarding_page_07.dart';
import 'screens/onboarding/onboarding_page_08.dart';

import 'screens/people/pages/inner_circle_page.dart';
import 'screens/people/pages/connections_page.dart';
import 'screens/people/pages/suggestions_page.dart';

import 'screens/chat/pages/conversations_page.dart';

import 'screens/top_nav/vault_screen.dart';

// ✅ App shell (bottom nav)
import 'shell/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MuudApp()));
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
      ErrorReporting.captureException(e);
    }

    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) => _handleUri(uri),
      onError: (err) => ErrorReporting.captureException(err),
    );
  }

  void _handleUri(Uri uri) {
    if (uri.host == 'auth' && uri.path == '/callback') {
      // OAuth exchange stays in your service layer
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
      theme: AppTheme.lightTheme,

      // ✅ Splash → Redirect happens here
      home: const Boot(),

      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/otp': (_) => const OtpScreen(),

        // ✅ Forgot password flow (FIXED)
        '/forgot': (_) => const ForgotPasswordScreen(),

        // ✅ Keep this route name so nothing breaks
        // /reset now shows "We sent you a code" screen (6 boxes)
        '/reset': (_) => const VerifyResetCodeScreen(),

        // ✅ Final screen: Update Password
        '/reset-password': (_) => const ResetPasswordScreen(),

        '/home': (_) => const AppShell(),
        '/edit-profile': (_) => const EditProfileScreen(),

        // Onboarding
        '/onboarding/01': (_) => const OnboardingPage01(),
        '/onboarding/02': (_) => const OnboardingPage02(),
        '/onboarding/03': (_) => const OnboardingPage03(),
        '/onboarding/04': (_) => const OnboardingPage04(),
        '/onboarding/05': (_) => const OnboardingPage05(),
        '/onboarding/06': (_) => const OnboardingPage06(),
        '/onboarding/07': (_) => const OnboardingPage07(),
        '/onboarding/08': (_) => const OnboardingPage08(),

        // People
        '/people/inner-circle': (_) => const InnerCirclePage(),
        '/people/connections': (_) => const ConnectionsPage(),
        '/people/suggestions': (_) => const SuggestionsPage(),

        // Chat
        '/chat/conversations': (_) => const ConversationsPage(),

        // Vault
        '/vault': (_) => const VaultScreen(),
      },

      // ✅ Keep this as-is (your splash redirect)
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const Boot()),
    );
  }
}

class Boot extends ConsumerStatefulWidget {
  const Boot({super.key});

  @override
  ConsumerState<Boot> createState() => _BootState();
}

class _BootState extends ConsumerState<Boot> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final auth = ref.read(authProvider.notifier);
    await auth.checkAuth();
    if (!mounted) return;

    final status = ref.read(authProvider).status;
    switch (status) {
      case AuthStatus.authenticated:
        Navigator.of(context).pushReplacementNamed('/home');
      case AuthStatus.onboarding:
        Navigator.of(context).pushReplacementNamed('/onboarding/01');
      case AuthStatus.unauthenticated:
      case AuthStatus.unknown:
        Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/splash_screen.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

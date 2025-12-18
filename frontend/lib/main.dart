import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import 'services/token_storage.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';

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

  String _lastLink = '';

  @override
  void initState() {
    super.initState();
    _initLinks();
  }

  Future<void> _initLinks() async {
    // Initial link (cold start)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint("❌ getInitialLink error: $e");
    }

    // Stream (while app running)
    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleUri(uri);
      },
      onError: (err) {
        debugPrint("❌ link stream error: $err");
      },
    );
  }

  void _handleUri(Uri uri) {
    debugPrint("🔗 Deep link received: $uri");
    setState(() {
      _lastLink = uri.toString();
    });

    if (uri.host == 'auth' && uri.path == '/callback') {
      final code = uri.queryParameters['code'];
      debugPrint("✅ OAuth code: $code");
      // NEXT STEP: exchange code -> tokens
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

      home: Stack(
        children: [
          const Boot(),
          // (your banner widget here)
        ],
      ),

      routes: {
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/otp': (_) => const OtpScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/reset': (_) => const ResetPasswordScreen(),
        '/home': (_) => const HomeScreen(),
      },

      // ✅ ADD THIS (prevents: Failed to handle route information...)
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
    final token = await TokenStorage.getIdToken();
    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacementNamed(token == null ? '/login' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

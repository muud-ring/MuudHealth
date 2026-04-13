// MUUD Health — App Entry Point
// Central operating system for the Muud ecosystem
// Signal → Insight → Action → Learn → Grow
// © Muud Health — Armin Hoes, MD

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/error_reporting.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init — wrapped in try-catch because GoogleService-Info.plist
  // may not be present yet. Push notifications will be unavailable until
  // the Firebase config file is added.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase config not found — app continues without push notifications.
  }

  await ErrorReporting.init();
  runApp(const ProviderScope(child: MuudApp()));
}

class MuudApp extends ConsumerStatefulWidget {
  const MuudApp({super.key});

  @override
  ConsumerState<MuudApp> createState() => _MuudAppState();
}

class _MuudAppState extends ConsumerState<MuudApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    // Kick off auth check immediately so GoRouter redirect has a real status
    ref.read(authProvider.notifier).checkAuth();
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
      // OAuth callback exchange handled in CognitoOAuth service layer.
      // On success, auth_provider state transitions to authenticated,
      // which triggers GoRouter redirect to /home.
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MUUD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

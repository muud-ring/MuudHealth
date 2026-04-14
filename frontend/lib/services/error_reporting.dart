// Muud Health — Error Reporting & Crash Analytics Service
// © Muud Health — Armin Hoes, MD

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Centralized error reporting backed by Firebase Crashlytics.
/// Captures Flutter framework errors, async errors, and manual reports.
class ErrorReporting {
  static bool _initialized = false;

  /// Initialize crash reporting. Call once at app startup after Firebase.initializeApp().
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final crashlytics = FirebaseCrashlytics.instance;

    // Disable Crashlytics collection in debug mode
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Capture Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      crashlytics.recordFlutterFatalError(details);
    };

    // Capture async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    debugPrint('[ErrorReporting] Initialized (Crashlytics ${kDebugMode ? "disabled" : "enabled"})');
  }

  /// Set the user identifier for crash reports.
  static Future<void> setUserId(String userId) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Record a non-fatal error with optional stack trace.
  static Future<void> recordError(
    dynamic exception, {
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[ErrorReporting] ${fatal ? "FATAL" : "Error"}: $exception');
      if (stackTrace != null) debugPrint('$stackTrace');
    }

    await FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Record a Flutter-specific error.
  static Future<void> recordFlutterError(FlutterErrorDetails details) async {
    await FirebaseCrashlytics.instance.recordFlutterError(details);
  }

  /// Add a log message for debugging context in crash reports.
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[Crashlytics] $message');
    }
    FirebaseCrashlytics.instance.log(message);
  }

  /// Set a custom key-value pair for crash reports.
  static Future<void> setCustomKey(String key, Object value) async {
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Legacy alias for backward compatibility.
  static Future<void> init() => initialize();

  /// Legacy alias for backward compatibility.
  static void captureException(dynamic exception, {StackTrace? stackTrace}) {
    recordError(exception, stackTrace: stackTrace);
  }

  /// Legacy alias for backward compatibility.
  static void addBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) {
    log('${category ?? 'app'}: $message');
  }
}

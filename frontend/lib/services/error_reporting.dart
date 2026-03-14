import 'dart:async';
import 'package:flutter/foundation.dart';

/// Error reporting service.
///
/// Currently logs errors locally. When Sentry DSN is configured,
/// swap implementation to use sentry_flutter package.
class ErrorReporting {
  static bool _initialized = false;

  /// Initialize error reporting. Call once at app startup.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Capture Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _reportError(details.exception, details.stack);
    };

    // Capture async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack);
      return true;
    };
  }

  /// Report a caught exception with optional stack trace.
  static void captureException(dynamic exception, {StackTrace? stackTrace}) {
    _reportError(exception, stackTrace);
  }

  /// Add breadcrumb for debugging context.
  static void addBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) {
    if (kDebugMode) {
      debugPrint('[Breadcrumb] ${category ?? 'app'}: $message');
    }
    // TODO: Forward to Sentry when configured
    // Sentry.addBreadcrumb(Breadcrumb(message: message, category: category, data: data));
  }

  static void _reportError(dynamic error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('[ErrorReporting] $error');
      if (stack != null) debugPrint('$stack');
    }
    // TODO: Send to Sentry when configured
    // Sentry.captureException(error, stackTrace: stack);
  }
}

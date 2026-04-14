// Muud Health — Feature Flags Service (Firebase Remote Config)
// © Muud Health — Armin Hoes, MD

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Centralized feature flag management backed by Firebase Remote Config.
/// Falls back to compile-time defaults when Remote Config is unavailable.
class FeatureFlags {
  FeatureFlags._();

  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  static bool _initialized = false;

  /// Default feature flag values (used when Remote Config is unreachable).
  static const Map<String, bool> _defaults = {
    'ring_integration': false,
    'ai_insights': false,
    'video_journal': false,
    'clinic_tab': true,
    'academy_tab': true,
    'vault_sharing': false,
    'biometric_dashboard': true,
    'push_notifications': true,
    'dark_mode': false,
    'hipaa_audit_log': true,
  };

  /// Initialize Remote Config with defaults and fetch latest values.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 5)
            : const Duration(hours: 1),
      ));

      // Set defaults so flags work even before first fetch
      await _remoteConfig.setDefaults(
        _defaults.map((k, v) => MapEntry(k, v)),
      );

      // Fetch and activate latest values
      await _remoteConfig.fetchAndActivate();

      _initialized = true;
      debugPrint('[FeatureFlags] Initialized — ${_defaults.length} flags configured');
    } catch (e) {
      debugPrint('[FeatureFlags] Init failed (using defaults): $e');
      _initialized = true; // Mark initialized so defaults work
    }
  }

  /// Check if a feature flag is enabled.
  static bool isEnabled(String flagName) {
    if (!_initialized) {
      return _defaults[flagName] ?? false;
    }

    try {
      return _remoteConfig.getBool(flagName);
    } catch (_) {
      return _defaults[flagName] ?? false;
    }
  }

  /// Get all feature flags with their current values.
  static Map<String, bool> getAll() {
    final result = <String, bool>{};
    for (final key in _defaults.keys) {
      result[key] = isEnabled(key);
    }
    return result;
  }

  /// Force refresh flags from Remote Config.
  static Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('[FeatureFlags] Refresh failed: $e');
    }
  }
}

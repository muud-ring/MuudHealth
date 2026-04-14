// Muud Health — Over-the-Air Update Service (Shorebird)
// © Muud Health — Armin Hoes, MD

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// OTA update service for delivering patches without full App Store resubmission.
/// Uses Shorebird for code-push style updates on Flutter.
///
/// Shorebird SDK must be integrated at the build level.
/// This service provides the application-level update check and apply logic.
class OtaService {
  OtaService._();

  static PackageInfo? _packageInfo;

  /// Initialize the OTA service.
  static Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      debugPrint('[OTA] Initialized — v${_packageInfo!.version}+${_packageInfo!.buildNumber}');
    } catch (e) {
      debugPrint('[OTA] Init failed: $e');
    }
  }

  /// Get the current app version.
  static Future<String> getCurrentVersion() async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    return '${_packageInfo!.version}+${_packageInfo!.buildNumber}';
  }

  /// Check if an OTA update is available.
  ///
  /// When Shorebird is integrated, this calls `ShorebirdCodePush.isNewPatchAvailableForDownload()`.
  /// Falls back to a no-op when Shorebird SDK is not available.
  static Future<bool> checkForUpdate() async {
    try {
      // Shorebird integration point:
      // final shorebirdCodePush = ShorebirdCodePush();
      // final isAvailable = await shorebirdCodePush.isNewPatchAvailableForDownload();
      // return isAvailable;

      // Stub: returns false until Shorebird SDK is integrated at build level
      debugPrint('[OTA] Update check — Shorebird SDK not yet integrated');
      return false;
    } catch (e) {
      debugPrint('[OTA] Update check failed: $e');
      return false;
    }
  }

  /// Download and apply the available OTA patch.
  ///
  /// The update takes effect on next app restart.
  static Future<bool> downloadAndApply() async {
    try {
      // Shorebird integration point:
      // final shorebirdCodePush = ShorebirdCodePush();
      // await shorebirdCodePush.downloadUpdateIfAvailable();
      // return true;

      debugPrint('[OTA] Download — Shorebird SDK not yet integrated');
      return false;
    } catch (e) {
      debugPrint('[OTA] Download failed: $e');
      return false;
    }
  }

  /// Get the current patch number (if Shorebird is active).
  static Future<int?> getCurrentPatchNumber() async {
    try {
      // Shorebird integration point:
      // final shorebirdCodePush = ShorebirdCodePush();
      // return await shorebirdCodePush.currentPatchNumber();

      return null;
    } catch (_) {
      return null;
    }
  }
}

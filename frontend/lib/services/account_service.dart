// Muud Health — Account Service
// © Muud Health — Armin Hoes, MD
//
// Manages the unified Account lifecycle: fetch, tier, entitlements, data export.

import 'dart:convert';
import 'api_client.dart';
import '../models/account.dart';

class AccountService {
  static const _base = '/api/v1/account';

  /// Fetch the current user's account with entitlements.
  static Future<Account?> getAccount() async {
    try {
      final res = await ApiClient.get(_base);
      if (res.statusCode == 200) {
        return Account.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch tier details for the current user.
  static Future<Map<String, dynamic>?> getTierDetails() async {
    try {
      final res = await ApiClient.get('$_base/tier');
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Force a tier recalculation based on current service plans.
  static Future<Map<String, dynamic>?> recalculateTier() async {
    try {
      final res = await ApiClient.post('$_base/recalculate-tier', body: {});
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Generate GDPR/CCPA data export manifest.
  static Future<Map<String, dynamic>?> getDataExportManifest() async {
    try {
      final res = await ApiClient.get('$_base/data-export');
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Check if the user is entitled to a specific feature.
  static Future<bool> hasEntitlement(String feature) async {
    final account = await getAccount();
    return account?.hasEntitlement(feature) ?? false;
  }
}

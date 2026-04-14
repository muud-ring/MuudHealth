// Muud Health — Shared Vault Service
// © Muud Health — Armin Hoes, MD
//
// Cross-platform vault: items saved in app appear in portal and vice versa.

import 'dart:convert';
import 'api_client.dart';

class SharedVaultService {
  static const _base = '/api/v1/shared-vault';

  /// Sync a vault item across platforms.
  static Future<bool> syncVaultItem(String vaultItemId) async {
    try {
      final res = await ApiClient.post('$_base/sync', body: {'vaultItemId': vaultItemId});
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Share a vault item with another user.
  static Future<bool> shareItem(String vaultItemId, String targetSub, {String accessLevel = 'view'}) async {
    try {
      final res = await ApiClient.post('$_base/share', body: {
        'vaultItemId': vaultItemId,
        'targetSub': targetSub,
        'accessLevel': accessLevel,
      });
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Get items shared with the current user.
  static Future<List<Map<String, dynamic>>> getSharedWithMe({int page = 1, int limit = 20}) async {
    try {
      final res = await ApiClient.get('$_base/shared-with-me?page=$page&limit=$limit');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get items the current user has shared.
  static Future<List<Map<String, dynamic>>> getMyShared({int page = 1, int limit = 20}) async {
    try {
      final res = await ApiClient.get('$_base/my-shared?page=$page&limit=$limit');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Revoke a share.
  static Future<bool> revokeShare(String entryId, String targetSub) async {
    try {
      final res = await ApiClient.delete('$_base/share/$entryId/$targetSub');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Get sync status across platforms.
  static Future<Map<String, dynamic>?> getSyncStatus() async {
    try {
      final res = await ApiClient.get('$_base/sync-status');
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

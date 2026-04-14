// Muud Health — Organization Service
// © Muud Health — Armin Hoes, MD

import 'dart:convert';
import 'api_client.dart';
import '../models/organization.dart';

class OrganizationService {
  static const _base = '/api/v1/organizations';

  /// List organizations the user belongs to (or manages).
  static Future<List<Organization>> listOrganizations() async {
    try {
      final res = await ApiClient.get(_base);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['organizations'] as List<dynamic>? ?? [];
        return list.map((o) => Organization.fromJson(o as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get organization details.
  static Future<Organization?> getOrganization(String orgId) async {
    try {
      final res = await ApiClient.get('$_base/$orgId');
      if (res.statusCode == 200) {
        return Organization.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get organization analytics (admin only).
  static Future<Map<String, dynamic>?> getAnalytics(String orgId) async {
    try {
      final res = await ApiClient.get('$_base/$orgId/analytics');
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Add a member to an organization.
  static Future<bool> addMember(String orgId, String memberSub, {String role = 'member'}) async {
    try {
      final res = await ApiClient.post('$_base/$orgId/members', body: {
        'memberSub': memberSub,
        'role': role,
      });
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Remove a member from an organization.
  static Future<bool> removeMember(String orgId, String memberSub) async {
    try {
      final res = await ApiClient.delete('$_base/$orgId/members/$memberSub');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

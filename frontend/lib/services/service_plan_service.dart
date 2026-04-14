// Muud Health — Service Plan Service (Frontend)
// © Muud Health — Armin Hoes, MD

import 'dart:convert';
import 'api_client.dart';
import '../models/service_plan.dart';

class ServicePlanService {
  static const _base = '/api/v1/service-plans';

  /// Get all service plans for the current user.
  static Future<List<ServicePlan>> getPlans({String? status, String? category}) async {
    try {
      final params = <String>[];
      if (status != null) params.add('status=$status');
      if (category != null) params.add('category=$category');
      final query = params.isNotEmpty ? '?${params.join('&')}' : '';

      final res = await ApiClient.get('$_base$query');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['plans'] as List<dynamic>? ?? [];
        return list.map((p) => ServicePlan.fromJson(p as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get the user's highest-priority active plan.
  static Future<ServicePlan?> getActivePlan() async {
    try {
      final res = await ApiClient.get('$_base/active');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['plan'] != null) return ServicePlan.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get the plan catalog (public, no auth required).
  static Future<Map<String, dynamic>?> getCatalog() async {
    try {
      final res = await ApiClient.get('$_base/catalog');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['catalog'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

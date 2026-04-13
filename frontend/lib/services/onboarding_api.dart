// MUUD Health — Onboarding API Service
// 8-step onboarding flow state management
// © Muud Health — Armin Hoes, MD

import 'api_client.dart';

class OnboardingApi {
  OnboardingApi._();

  /// GET /api/v1/onboarding/status → { completed: true/false }
  static Future<bool> isCompleted() async {
    final res = await ApiClient.get('/api/v1/onboarding/status');
    final data = ApiClient.handleResponse(res);
    return data['completed'] == true;
  }

  /// GET /api/v1/onboarding/me → full onboarding data
  static Future<Map<String, dynamic>> getOnboarding() async {
    final res = await ApiClient.get('/api/v1/onboarding/me');
    return ApiClient.handleResponse(res);
  }

  /// POST /api/v1/onboarding → save onboarding answers
  static Future<void> saveOnboarding({
    required String favoriteColor,
    required String focusGoal,
    required List<String> activities,
    required bool notificationsEnabled,
    required bool completed,
  }) async {
    final res = await ApiClient.post('/api/v1/onboarding', body: {
      'favoriteColor': favoriteColor,
      'focusGoal': focusGoal,
      'activities': activities,
      'notificationsEnabled': notificationsEnabled,
      'completed': completed,
    });
    ApiClient.handleResponse(res);
  }
}

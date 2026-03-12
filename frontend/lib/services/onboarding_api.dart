import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class OnboardingApi {
  // ✅ Use same base url as ApiService
  static const String _baseUrl = 'http://localhost:4000';

  // GET /onboarding/status  -> { "completed": true/false }
  static Future<bool> isCompleted() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing access token');
    }

    final res = await http.get(
      Uri.parse('$_baseUrl/onboarding/status'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (res.statusCode != 200) {
      throw Exception('Status check failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['completed'] == true;
  }

  // POST /onboarding  -> saves onboarding
  static Future<void> saveOnboarding({
    required String favoriteColor,
    required String focusGoal,
    required List<String> activities,
    required bool notificationsEnabled,
    required bool completed,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing access token');
    }

    final res = await http.post(
      Uri.parse('$_baseUrl/onboarding'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'favoriteColor': favoriteColor,
        'focusGoal': focusGoal,
        'activities': activities,
        'notificationsEnabled': notificationsEnabled,
        'completed': completed,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Save onboarding failed: ${res.statusCode} ${res.body}');
    }
  }
}

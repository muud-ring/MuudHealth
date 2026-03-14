import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import 'cognito_oauth.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  static Future<Map<String, String>> _authHeaders() async {
    await _refreshIfNeeded();
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<void> _refreshIfNeeded() async {
    final expired = await TokenStorage.isTokenExpired();
    if (!expired) return;

    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Session expired. Please log in again.');
    }

    try {
      // Attempt to refresh using the refresh token via Cognito
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newIdToken = data['idToken'] as String?;
        if (newAccessToken != null && newIdToken != null) {
          await TokenStorage.saveTokens(
            idToken: newIdToken,
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );
          return;
        }
      }
      throw Exception('Token refresh failed');
    } catch (e) {
      await TokenStorage.clearTokens();
      throw Exception('Session expired. Please log in again.');
    }
  }

  static Future<http.Response> get(String path) async {
    final headers = await _authHeaders();
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  static Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final headers = await _authHeaders();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    final headers = await _authHeaders();
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }

  static Map<String, dynamic> handleResponse(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    final msg = (body is Map && body['message'] != null)
        ? body['message']
        : 'Request failed (${res.statusCode})';
    throw Exception(msg);
  }
}

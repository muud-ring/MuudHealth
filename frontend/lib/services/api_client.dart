import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  static const int _maxRetries = 3;
  static const Duration _requestTimeout = Duration(seconds: 30);

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

  /// Executes [request] with retry and exponential backoff.
  ///
  /// Retries up to [_maxRetries] times on network errors ([SocketException],
  /// [TimeoutException], [http.ClientException]) and 5xx server errors.
  /// Does NOT retry on 4xx client errors.
  static Future<http.Response> _retry(
    Future<http.Response> Function() request,
  ) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await request().timeout(_requestTimeout);

        // Do not retry client errors (4xx).
        if (response.statusCode >= 400 && response.statusCode < 500) {
          return response;
        }

        // Retry on server errors (5xx).
        if (response.statusCode >= 500) {
          if (attempt < _maxRetries) {
            await _backoff(attempt);
            attempt++;
            continue;
          }
        }

        return response;
      } on SocketException {
        if (attempt >= _maxRetries) rethrow;
        await _backoff(attempt);
        attempt++;
      } on TimeoutException {
        if (attempt >= _maxRetries) rethrow;
        await _backoff(attempt);
        attempt++;
      } on http.ClientException {
        if (attempt >= _maxRetries) rethrow;
        await _backoff(attempt);
        attempt++;
      }
    }
  }

  /// Returns a [Future] that completes after an exponential backoff delay
  /// based on the current [attempt] number (1s, 2s, 4s).
  static Future<void> _backoff(int attempt) {
    final delay = Duration(seconds: 1 << attempt); // 1s, 2s, 4s
    return Future.delayed(delay);
  }

  static Future<http.Response> get(String path) async {
    final headers = await _authHeaders();
    return _retry(
      () => http.get(Uri.parse('$baseUrl$path'), headers: headers),
    );
  }

  static Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final headers = await _authHeaders();
    return _retry(
      () => http.post(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  static Future<http.Response> put(String path, {Map<String, dynamic>? body}) async {
    final headers = await _authHeaders();
    return _retry(
      () => http.put(
        Uri.parse('$baseUrl$path'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  static Future<http.Response> delete(String path) async {
    final headers = await _authHeaders();
    return _retry(
      () => http.delete(Uri.parse('$baseUrl$path'), headers: headers),
    );
  }

  static Map<String, dynamic> handleResponse(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : <String, dynamic>{};
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    final msg = (body is Map && body['message'] != null)
        ? body['message']
        : 'Request failed (${res.statusCode})';
    throw Exception(msg);
  }
}

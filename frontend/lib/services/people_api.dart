import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/token_storage.dart';

class PeopleApi {
  static const String baseUrl = 'http://localhost:4000';

  static const String _connections = '/people/connections';
  static const String _innerCircle = '/people/inner-circle';
  static const String _suggestions = '/people/suggestions';
  static const String _requests = '/people/requests';

  static Uri _uri(String path, [Map<String, dynamic>? query]) {
    final u = Uri.parse('$baseUrl$path');
    if (query == null) return u;
    return u.replace(
      queryParameters: query.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  static Future<Map<String, String>> _headers() async {
    final accessToken = await TokenStorage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      print("🔐 PeopleApi access token: NULL/EMPTY");
    } else {
      final head = accessToken.length > 15
          ? accessToken.substring(0, 15)
          : accessToken;
      print("🔐 PeopleApi access token: $head...");
    }

    return {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  static Future<List<dynamic>> _getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await http.get(_uri(path, query), headers: await _headers());

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);

      if (decoded is List) return decoded;

      if (decoded is Map) {
        for (final key in [
          'data',
          'items',
          'connections',
          'innerCircle',
          'suggestions',
          'requests',
        ]) {
          final v = decoded[key];
          if (v is List) return v;
        }
      }

      throw Exception('Unexpected response shape for $path: ${res.body}');
    }

    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(),
      body: body == null ? null : jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }

    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  // --------- Public API ----------

  static Future<List<dynamic>> fetchConnections() => _getList(_connections);
  static Future<List<dynamic>> fetchInnerCircle() => _getList(_innerCircle);
  static Future<List<dynamic>> fetchRequests() => _getList(_requests);

  // ✅ Suggestions with search
  static Future<List<dynamic>> fetchSuggestions({
    String q = "",
    int limit = 20,
  }) {
    return _getList(
      _suggestions,
      query: {if (q.trim().isNotEmpty) 'q': q.trim(), 'limit': limit},
    );
  }

  // ✅ Send request (backend: POST /people/request/:sub)
  static Future<void> sendRequest({required String sub}) async {
    await _post('/people/request/$sub');
  }

  // ✅ Accept/Decline (backend routes)
  static Future<void> acceptRequest({required String requestId}) async {
    await _post('/people/request/$requestId/accept');
  }

  static Future<void> declineRequest({required String requestId}) async {
    await _post('/people/request/$requestId/decline');
  }

  // ✅ Update tier (backend: POST /people/:sub/tier)
  static Future<void> updateTier({
    required String sub,
    required String tier, // "connection" | "inner_circle"
  }) async {
    await _post('/people/$sub/tier', body: {'tier': tier});
  }

  // ✅ Remove connection (backend: DELETE /people/:sub)
  static Future<void> removeConnection({required String sub}) async {
    final res = await http.delete(
      _uri('/people/$sub'),
      headers: await _headers(),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) return;

    throw Exception(
      'DELETE /people/$sub failed: ${res.statusCode} ${res.body}',
    );
  }
}

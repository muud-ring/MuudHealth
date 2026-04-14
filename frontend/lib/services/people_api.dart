// MUUD Health — People API Service
// Social graph: connections, inner circle, friend requests
// © Muud Health — Armin Hoes, MD

import 'dart:convert';
import 'api_client.dart';

class PeopleApi {
  PeopleApi._();

  // ── Fetch endpoints ────────────────────────────────────────────────────

  /// Fetch current user's people data (center avatar info)
  static Future<Map<String, dynamic>> fetchMe() async {
    final res = await ApiClient.get('/api/v1/people/me');
    return ApiClient.handleResponse(res);
  }

  /// Fetch all connections
  static Future<List<dynamic>> fetchConnections() async {
    final res = await ApiClient.get('/api/v1/people/connections');
    return _extractList(res, 'connections');
  }

  /// Fetch inner circle
  static Future<List<dynamic>> fetchInnerCircle() async {
    final res = await ApiClient.get('/api/v1/people/inner-circle');
    return _extractList(res, 'innerCircle');
  }

  /// Fetch pending friend requests
  static Future<List<dynamic>> fetchRequests() async {
    final res = await ApiClient.get('/api/v1/people/requests');
    return _extractList(res, 'requests');
  }

  /// Fetch connection suggestions
  static Future<List<dynamic>> fetchSuggestions({
    String q = '',
    int limit = 20,
  }) async {
    final params = <String>['limit=$limit'];
    if (q.trim().isNotEmpty) params.add('q=${Uri.encodeComponent(q.trim())}');
    final res = await ApiClient.get(
      '/api/v1/people/suggestions?${params.join("&")}',
    );
    return _extractList(res, 'suggestions');
  }

  // ── Action endpoints ───────────────────────────────────────────────────

  /// Send friend request
  static Future<void> sendRequest({required String sub}) async {
    final res = await ApiClient.post('/api/v1/people/request/$sub');
    ApiClient.handleResponse(res);
  }

  /// Accept friend request
  static Future<void> acceptRequest({required String requestId}) async {
    final res = await ApiClient.put('/api/v1/people/request/$requestId/accept');
    ApiClient.handleResponse(res);
  }

  /// Decline friend request
  static Future<void> declineRequest({required String requestId}) async {
    final res = await ApiClient.put('/api/v1/people/request/$requestId/decline');
    ApiClient.handleResponse(res);
  }

  /// Update connection tier (inner_circle, close, standard)
  static Future<void> updateTier({
    required String sub,
    required String tier,
  }) async {
    final res = await ApiClient.put(
      '/api/v1/people/$sub/tier',
      body: {'tier': tier},
    );
    ApiClient.handleResponse(res);
  }

  /// Remove connection
  static Future<void> removeConnection({required String sub}) async {
    final res = await ApiClient.delete('/api/v1/people/$sub');
    ApiClient.handleResponse(res);
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  static List<dynamic> _extractList(dynamic res, String key) {
    final data = ApiClient.handleResponse(res);
    if (data is Map) {
      for (final k in [key, 'data', 'items']) {
        final v = data[k];
        if (v is List) return v;
      }
    }
    final body = jsonDecode(res.body);
    if (body is List) return body;
    return [];
  }
}

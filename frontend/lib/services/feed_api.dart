// MUUD Health — Feed API Service
// © Muud Health — Armin Hoes, MD

import 'api_client.dart';

class FeedApi {
  FeedApi._();

  /// Get home feed (connections' posts)
  static Future<List<Map<String, dynamic>>> getHomeFeed({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await ApiClient.get('/api/v1/feed/home?page=$page&limit=$limit');
    final data = ApiClient.handleResponse(res);
    final list = (data['posts'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// Get explore feed (public/discovery)
  static Future<List<Map<String, dynamic>>> getExploreFeed({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await ApiClient.get('/api/v1/feed/explore?page=$page&limit=$limit');
    final data = ApiClient.handleResponse(res);
    final list = (data['posts'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}

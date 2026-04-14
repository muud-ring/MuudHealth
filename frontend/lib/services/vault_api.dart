// MUUD Health — Vault API Service
// Private content vault with categories and tags
// © Muud Health — Armin Hoes, MD

import 'api_client.dart';

class VaultApi {
  VaultApi._();

  /// GET /api/v1/vault/landing — vault landing with categories
  static Future<List<Map<String, dynamic>>> getLanding({
    String? chip,
    String? search,
  }) async {
    final res = await ApiClient.get('/api/v1/vault/landing');
    final data = ApiClient.handleResponse(res);
    final sections = (data['sections'] as List?) ?? [];
    var list = sections.cast<Map<String, dynamic>>();

    // Client-side filtering (MVP)
    final c = (chip ?? '').toLowerCase().trim();
    final q = (search ?? '').toLowerCase().trim();

    Iterable<Map<String, dynamic>> out = list;

    if (c.isNotEmpty && c != 'all') {
      out = out.where((s) => (s['key'] ?? '').toString().toLowerCase() == c);
    }

    if (q.isNotEmpty) {
      out = out.map((s) {
        final preview = ((s['preview'] as List?) ?? []).cast<Map<String, dynamic>>();
        final filtered = preview.where((p) {
          final caption = (p['caption'] ?? '').toString().toLowerCase();
          return caption.contains(q);
        }).toList();
        return {...s, 'preview': filtered};
      }).where((s) {
        final count = (s['count'] is int) ? (s['count'] as int) : int.tryParse('${s["count"]}') ?? 0;
        final preview = ((s['preview'] as List?) ?? []);
        return count > 0 || preview.isNotEmpty;
      });
    }

    return out.toList();
  }

  /// GET /api/v1/vault/items — paginated vault items
  static Future<Map<String, dynamic>> getItems({
    required String category,
    String? tag,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String>['category=$category', 'page=$page', 'limit=$limit'];
    if (tag != null) params.add('tag=${Uri.encodeComponent(tag)}');
    final res = await ApiClient.get('/api/v1/vault/items?${params.join("&")}');
    return ApiClient.handleResponse(res);
  }

  /// POST /api/v1/vault/save — save item to vault
  static Future<String> save({
    required String sourceId,
    required String category,
    List<Map<String, String>> tags = const [],
    String experienceType = '',
  }) async {
    final res = await ApiClient.post('/api/v1/vault/save', body: {
      'sourceType': 'post',
      'sourceId': sourceId,
      'category': category.toLowerCase().trim(),
      'tags': tags,
      'experienceType': experienceType,
    });
    final data = ApiClient.handleResponse(res);
    return data['message']?.toString() ?? 'Saved to Vault';
  }

  /// DELETE /api/v1/vault/save — remove from vault
  static Future<void> unsave({required String sourceId}) async {
    final res = await ApiClient.delete('/api/v1/vault/save?sourceId=$sourceId');
    ApiClient.handleResponse(res);
  }
}

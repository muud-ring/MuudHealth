import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class VaultApi {
  static const String _baseUrl = "http://127.0.0.1:4000";

  static Future<Map<String, String>> _authHeaders() async {
    final access = await TokenStorage.getAccessToken();
    if (access == null || access.isEmpty) {
      throw Exception("Missing access token");
    }
    return <String, String>{
      "Authorization": "Bearer $access",
      "Content-Type": "application/json",
    };
  }

  /// GET /vault/landing
  static Future<List<Map<String, dynamic>>> getLanding({
    String? chip, // optional client-side filter
    String? search, // optional client-side filter
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/vault/landing");

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Vault landing failed: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final sections = (decoded["sections"] as List?) ?? [];
    final list = sections.cast<Map<String, dynamic>>();

    // Client-side filter (MVP)
    final c = (chip ?? "").toLowerCase().trim();
    final q = (search ?? "").toLowerCase().trim();

    Iterable<Map<String, dynamic>> out = list;

    if (c.isNotEmpty && c != "all") {
      out = out.where((s) => (s["key"] ?? "").toString().toLowerCase() == c);
    }

    if (q.isNotEmpty) {
      // Search within preview captions (MVP). Later: backend search.
      out = out
          .map((s) {
            final preview = ((s["preview"] as List?) ?? [])
                .cast<Map<String, dynamic>>();
            final filtered = preview.where((p) {
              final caption = (p["caption"] ?? "").toString().toLowerCase();
              return caption.contains(q);
            }).toList();

            // Keep section if:
            // - it already has count > 0
            // - or preview matches query (filtered not empty)
            return {...s, "preview": filtered};
          })
          .where((s) {
            final count = (s["count"] is int)
                ? (s["count"] as int)
                : int.tryParse("${s["count"]}") ?? 0;
            final preview = ((s["preview"] as List?) ?? []);
            return count > 0 || preview.isNotEmpty;
          });
    }

    return out.toList();
  }

  /// POST /vault/save
  static Future<void> save({
    required String sourceId, // postId
    required String category, // friends/family/...
    List<Map<String, String>> tags = const [],
    String experienceType = "",
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/vault/save");

    final body = {
      "sourceType": "post",
      "sourceId": sourceId,
      "category": category,
      "tags": tags,
      "experienceType": experienceType,
    };

    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Vault save failed: ${res.body}");
    }
  }

  /// DELETE /vault/save?sourceId=<postId>
  static Future<void> unsave({required String sourceId}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/vault/save?sourceId=$sourceId");

    final res = await http.delete(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Vault unsave failed: ${res.body}");
    }
  }

  /// GET /vault/items?category=friends&limit=20&cursor=<ISO>
  static Future<Map<String, dynamic>> getItems({
    required String category,
    int limit = 20,
    String? cursor, // savedAt ISO
  }) async {
    final headers = await _authHeaders();

    final qp = <String, String>{"category": category, "limit": "$limit"};
    if (cursor != null && cursor.isNotEmpty) qp["cursor"] = cursor;

    final uri = Uri.parse("$_baseUrl/vault/items").replace(queryParameters: qp);

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Vault items failed: ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

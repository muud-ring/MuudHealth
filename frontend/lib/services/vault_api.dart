import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class VaultApi {
  static const String _baseUrl = "http://127.0.0.1:4000";

  static Future<Map<String, String>> _authHeaders() async {
    final access = await TokenStorage.getAccessToken();
    if (access == null || access.isEmpty)
      throw Exception("Missing access token");
    return {
      "Authorization": "Bearer $access",
      "Content-Type": "application/json",
    };
  }

  static Future<List<Map<String, dynamic>>> landing() async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/vault/landing");

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Vault landing failed: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (decoded["sections"] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> items({
    String? category,
    int limit = 20,
    String? cursor,
  }) async {
    final headers = await _authHeaders();

    final qp = <String, String>{"limit": "$limit"};
    if (category != null && category.isNotEmpty) qp["category"] = category;
    if (cursor != null && cursor.isNotEmpty) qp["cursor"] = cursor;

    final uri = Uri.parse("$_baseUrl/vault/items").replace(queryParameters: qp);

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Vault items failed: ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> savePostToVault({
    required String postId,
    required String category,
    List<Map<String, String>> tags = const [],
    String experienceType = "",
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/vault/save");

    final body = {
      "sourceType": "post",
      "sourceId": postId,
      "category": category,
      "experienceType": experienceType,
      "tags": tags,
    };

    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Save to vault failed: ${res.body}");
    }
  }

  static Future<void> removePostFromVault({required String postId}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse(
      "$_baseUrl/vault/save",
    ).replace(queryParameters: {"sourceId": postId});

    final res = await http.delete(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Remove from vault failed: ${res.body}");
    }
  }
}

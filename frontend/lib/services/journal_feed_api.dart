import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class JournalFeedApi {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.muudhealth.com',
  );

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

  static Future<List<Map<String, dynamic>>> getMyPosts() async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/posts/mine");

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Fetch posts failed: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (decoded["posts"] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}

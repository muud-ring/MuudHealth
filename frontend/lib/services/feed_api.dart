import 'dart:convert';
import 'package:http/http.dart' as http;

import 'token_storage.dart';

class FeedApi {
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

  static Future<List<Map<String, dynamic>>> getHomeFeed() async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/feed/home");

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Home feed failed: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (decoded["posts"] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}

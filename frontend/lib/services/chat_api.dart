import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class ChatApi {
  static const String baseUrl = 'http://localhost:4000';

  static Future<Map<String, dynamic>> getOrCreateConversation({
    required String otherSub,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Missing access token");
    }

    final uri = Uri.parse('$baseUrl/chat/conversation/$otherSub');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(
        body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Failed to create conversation',
      );
    }

    return body as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> fetchMessages({
    required String conversationId,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Missing access token");
    }

    final uri = Uri.parse('$baseUrl/chat/messages/$conversationId');

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(
        body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Failed to load messages',
      );
    }

    final list = (body['messages'] as List? ?? []);
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception("Missing access token");
    }

    final uri = Uri.parse('$baseUrl/chat/messages/$conversationId');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 201) {
      throw Exception(
        body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Failed to send',
      );
    }

    return (body['message'] as Map).cast<String, dynamic>();
  }
}

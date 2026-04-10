import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'token_storage.dart';

class JournalApi {
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

  // ✅ POST /uploads/presign
  static Future<Map<String, dynamic>> presign({
    required String contentType,
    required String kind, // journalImage | journalAudio
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/uploads/presign");

    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({"contentType": contentType, "kind": kind}),
    );

    if (res.statusCode != 200) {
      throw Exception("Presign failed: ${res.body}");
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ✅ PUT to presigned URL
  static Future<void> uploadToS3({
    required String uploadUrl,
    required File file,
    required String contentType,
  }) async {
    final bytes = await file.readAsBytes();

    final res = await http.put(
      Uri.parse(uploadUrl),
      headers: <String, String>{"Content-Type": contentType},
      body: bytes,
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("S3 upload failed: ${res.statusCode}");
    }
  }

  // ✅ POST /posts
  static Future<Map<String, dynamic>> createPost({
    required String caption,
    required List<String> mediaKeys,
    String? audioKey,
    required String visibility, // public | connections | innerCircle
    required List<String> recipientSubs,
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/posts");

    final body = {
      "caption": caption,
      "mediaKeys": mediaKeys,
      "audioKey": audioKey ?? "",
      "visibility": visibility,
      "recipientSubs": recipientSubs,
    };

    final res = await http.post(uri, headers: headers, body: jsonEncode(body));

    if (res.statusCode != 201) {
      throw Exception("Create post failed: ${res.body}");
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    // your controller returns { post: {...} } usually
    return decoded;
  }

  // ✅ PUT /posts/:id  (Edit caption only for now)
  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String caption,
  }) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/posts/$postId");

    final res = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({"caption": caption}),
    );

    if (res.statusCode != 200) {
      throw Exception("Update post failed: ${res.body}");
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ✅ DELETE /posts/:id
  static Future<void> deletePost({required String postId}) async {
    final headers = await _authHeaders();
    final uri = Uri.parse("$_baseUrl/posts/$postId");

    final res = await http.delete(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception("Delete post failed: ${res.body}");
    }
  }
}

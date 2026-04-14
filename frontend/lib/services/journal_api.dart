// MUUD Health — Journal/Post API Service
// Creator tools: posts, journal entries, media uploads
// © Muud Health — Armin Hoes, MD

import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class JournalApi {
  JournalApi._();

  // ── Presigned Upload ───────────────────────────────────────────────────

  /// POST /api/v1/uploads/presign → { uploadUrl, key }
  static Future<Map<String, dynamic>> presign({
    required String contentType,
    required String kind, // journalImage | journalAudio
  }) async {
    final res = await ApiClient.post('/api/v1/uploads/presign', body: {
      'contentType': contentType,
      'kind': kind,
    });
    return ApiClient.handleResponse(res);
  }

  /// PUT directly to S3 using presigned URL
  static Future<void> uploadToS3({
    required String uploadUrl,
    required File file,
    required String contentType,
  }) async {
    final bytes = await file.readAsBytes();
    final res = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('S3 upload failed: ${res.statusCode}');
    }
  }

  // ── Post CRUD ──────────────────────────────────────────────────────────

  /// POST /api/v1/posts — create new post/journal entry
  static Future<Map<String, dynamic>> createPost({
    required String caption,
    required List<String> mediaKeys,
    String? audioKey,
    required String visibility,
    required List<String> recipientSubs,
    String type = 'journal',
    List<String> tags = const [],
  }) async {
    final res = await ApiClient.post('/api/v1/posts', body: {
      'caption': caption,
      'mediaKeys': mediaKeys,
      'audioKey': audioKey ?? '',
      'visibility': visibility,
      'recipientSubs': recipientSubs,
      'type': type,
      'tags': tags,
    });
    return ApiClient.handleResponse(res);
  }

  /// GET /api/v1/posts/mine — get user's own posts
  static Future<List<Map<String, dynamic>>> getMyPosts() async {
    final res = await ApiClient.get('/api/v1/posts/mine');
    final data = ApiClient.handleResponse(res);
    final list = (data['posts'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  /// PUT /api/v1/posts/:id — update post
  static Future<Map<String, dynamic>> updatePost({
    required String postId,
    required String caption,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{'caption': caption};
    if (tags != null) body['tags'] = tags;
    final res = await ApiClient.put('/api/v1/posts/$postId', body: body);
    return ApiClient.handleResponse(res);
  }

  /// DELETE /api/v1/posts/:id — delete post
  static Future<void> deletePost({required String postId}) async {
    final res = await ApiClient.delete('/api/v1/posts/$postId');
    ApiClient.handleResponse(res);
  }
}

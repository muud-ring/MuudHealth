// MUUD Health — User API Service
// Profile CRUD, avatar management, JWT claims
// © Muud Health — Armin Hoes, MD

import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class UserApi {
  UserApi._();

  // ── Profile ────────────────────────────────────────────────────────────

  /// GET /api/v1/user/me
  static Future<Map<String, dynamic>> getMe() async {
    final res = await ApiClient.get('/api/v1/user/me');
    return ApiClient.handleResponse(res);
  }

  /// PUT /api/v1/user/me
  static Future<void> updateMe({
    required String name,
    required String username,
    required String bio,
    required String location,
    required String phone,
  }) async {
    final res = await ApiClient.put('/api/v1/user/me', body: {
      'name': name,
      'username': username,
      'bio': bio,
      'location': location,
      'phone': phone,
    });
    ApiClient.handleResponse(res);
  }

  /// GET /api/v1/user/claims — JWT claims inspection
  static Future<Map<String, dynamic>> getClaims() async {
    final res = await ApiClient.get('/api/v1/user/claims');
    return ApiClient.handleResponse(res);
  }

  // ── Avatar (S3 presigned upload flow) ──────────────────────────────────

  /// POST /api/v1/user/avatar/presign → { uploadUrl, key, bucket }
  static Future<Map<String, dynamic>> presignAvatarUpload({
    required String contentType,
  }) async {
    final res = await ApiClient.post('/api/v1/user/avatar/presign', body: {
      'contentType': contentType,
    });
    return ApiClient.handleResponse(res);
  }

  /// PUT directly to S3 using the presigned URL
  static Future<void> uploadToS3Presigned({
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

  /// POST /api/v1/user/avatar/confirm — confirm uploaded avatar
  static Future<void> confirmAvatar({required String key}) async {
    final res = await ApiClient.post('/api/v1/user/avatar/confirm', body: {
      'key': key,
    });
    ApiClient.handleResponse(res);
  }

  /// GET /api/v1/user/avatar/url → { url }
  static Future<String?> getAvatarUrl() async {
    final res = await ApiClient.get('/api/v1/user/avatar/url');
    final data = ApiClient.handleResponse(res);
    return data['url']?.toString();
  }
}

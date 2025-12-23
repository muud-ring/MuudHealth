import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class UserApi {
  static const String _baseUrl = 'http://localhost:4000';

  // ---------- Profile ----------
  static Future<Map<String, dynamic>> getMe() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing access token');
    }

    final res = await http.get(
      Uri.parse('$_baseUrl/user/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (res.statusCode != 200) {
      throw Exception('Get profile failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> updateMe({
    required String name,
    required String username,
    required String bio,
    required String location,
    required String phone,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing access token');
    }

    final res = await http.put(
      Uri.parse('$_baseUrl/user/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'username': username,
        'bio': bio,
        'location': location,
        'phone': phone,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Update profile failed: ${res.statusCode} ${res.body}');
    }
  }

  // ---------- Avatar (S3 presigned upload flow) ----------
  // POST /user/avatar/presign  -> { uploadUrl, key, bucket }
  static Future<Map<String, dynamic>> presignAvatarUpload({
    required String contentType,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing access token');
    }

    final res = await http.post(
      Uri.parse('$_baseUrl/user/avatar/presign'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'contentType': contentType}),
    );

    if (res.statusCode != 200) {
      throw Exception('Presign avatar failed: ${res.statusCode} ${res.body}');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // PUT directly to S3 using the presigned URL
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

  // POST /user/avatar/confirm  body: { key }
  static Future<void> confirmAvatar({required String key}) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing access token');
    }

    final res = await http.post(
      Uri.parse('$_baseUrl/user/avatar/confirm'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'key': key}),
    );

    if (res.statusCode != 200) {
      throw Exception('Confirm avatar failed: ${res.statusCode} ${res.body}');
    }
  }

  // GET /user/avatar/url  -> { url }
  static Future<String?> getAvatarUrl() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Missing access token');
    }

    final res = await http.get(
      Uri.parse('$_baseUrl/user/avatar/url'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (res.statusCode != 200) {
      throw Exception('Avatar url failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final url = data['url'];
    if (url == null) return null;
    return url.toString();
  }
}

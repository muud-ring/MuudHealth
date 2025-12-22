import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _kId = 'idToken';
  static const _kAccess = 'accessToken';
  static const _kRefresh = 'refreshToken';

  static Future<void> saveTokens({
    required String idToken,
    required String accessToken,
    String? refreshToken, // ✅ nullable
  }) async {
    await _storage.write(key: _kId, value: idToken);
    await _storage.write(key: _kAccess, value: accessToken);

    // ✅ only save if present
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _kRefresh, value: refreshToken);
    }
  }

  static Future<String?> getIdToken() {
    return _storage.read(key: _kId);
  }

  static Future<String?> getAccessToken() {
    return _storage.read(key: _kAccess);
  }

  static Future<String?> getRefreshToken() {
    return _storage.read(key: _kRefresh);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _kId);
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _kId);
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

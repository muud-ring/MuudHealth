import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _kId = 'idToken';
  static const _kAccess = 'accessToken';
  static const _kRefresh = 'refreshToken';

  static Future<void> saveTokens({
    required String idToken,
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kId, value: idToken);
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  static Future<String?> getIdToken() => _storage.read(key: _kId);

  static Future<void> clear() async {
    await _storage.delete(key: _kId);
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}

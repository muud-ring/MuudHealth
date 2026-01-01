import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _kId = 'idToken';
  static const _kAccess = 'accessToken';
  static const _kRefresh = 'refreshToken';

  // ✅ store a user-friendly name we can show in UI
  static const _kDisplayName = 'displayName';

  static Future<void> saveTokens({
    required String idToken,
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _kId, value: idToken);
    await _storage.write(key: _kAccess, value: accessToken);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _kRefresh, value: refreshToken);
    }

    // ✅ derive display name from idToken claims
    try {
      final claims = JwtDecoder.decode(idToken);

      // These are common Cognito fields depending on your setup
      final preferred = (claims['preferred_username'] ?? '').toString().trim();
      final cognitoUsername = (claims['cognito:username'] ?? '')
          .toString()
          .trim();
      final email = (claims['email'] ?? '').toString().trim();

      final display = preferred.isNotEmpty
          ? preferred
          : (cognitoUsername.isNotEmpty ? cognitoUsername : email);

      if (display.isNotEmpty) {
        await _storage.write(key: _kDisplayName, value: display);
      }
    } catch (_) {
      // ignore decode errors
    }
  }

  static Future<String?> getIdToken() => _storage.read(key: _kId);
  static Future<String?> getAccessToken() => _storage.read(key: _kAccess);
  static Future<String?> getRefreshToken() => _storage.read(key: _kRefresh);

  static Future<String?> getDisplayName() => _storage.read(key: _kDisplayName);

  static Future<void> clear() async {
    await _storage.delete(key: _kId);
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kDisplayName);
  }

  static Future<void> clearTokens() => clear();
}

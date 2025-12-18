import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialAuthService {
  // ✅ Your Cognito Hosted UI domain + client id
  static const String domain =
      'https://us-west-2kl77r4jwp.auth.us-west-2.amazoncognito.com';
  static const String clientId = '754pdur7oaaqe0a5vtupvfp464';

  // ✅ Your deep link callback
  static const String redirectUri = 'muud://auth/callback';

  // Scopes for OIDC
  static const String scope = 'openid email profile';

  // --- PKCE helpers ---
  String _randomUrlSafeString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  String _base64UrlNoPadding(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String _codeChallengeS256(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes).bytes;
    return _base64UrlNoPadding(digest);
  }

  /// Start Google Sign-In via Cognito Hosted UI (Authorization Code + PKCE)
  /// ✅ This only opens the browser and returns a real "code" via deep link
  Future<void> startGoogle() async {
    final codeVerifier = _randomUrlSafeString(64);
    final codeChallenge = _codeChallengeS256(codeVerifier);
    final state = _randomUrlSafeString(24);

    // NOTE:
    // In next step, we will store verifier+state and exchange code for tokens.
    // For now, we just open login and confirm we receive the code back.

    final authorizeUrl = Uri.parse('$domain/oauth2/authorize').replace(
      queryParameters: {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'scope': scope,
        'state': state,

        // PKCE
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,

        // Force provider
        'identity_provider': 'Google',
      },
    );

    final ok = await launchUrl(
      authorizeUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!ok) {
      throw Exception('Could not open Hosted UI in browser.');
    }
  }
}

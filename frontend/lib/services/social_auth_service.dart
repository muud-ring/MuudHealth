import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialAuthService {
  // Cognito Hosted UI domain
  // Override via: --dart-define=SOCIAL_AUTH_COGNITO_DOMAIN=https://your-domain.auth.region.amazoncognito.com
  static const String domain = String.fromEnvironment(
    'SOCIAL_AUTH_COGNITO_DOMAIN',
    defaultValue: 'https://us-west-2kl77r4jwp.auth.us-west-2.amazoncognito.com',
  );

  // Cognito App Client ID for social auth
  // Override via: --dart-define=SOCIAL_AUTH_CLIENT_ID=your-client-id
  static const String clientId = String.fromEnvironment(
    'SOCIAL_AUTH_CLIENT_ID',
    defaultValue: '754pdur7oaaqe0a5vtupvfp464',
  );

  // Deep link callback URI
  // Override via: --dart-define=SOCIAL_AUTH_REDIRECT_URI=your-redirect-uri
  static const String redirectUri = String.fromEnvironment(
    'SOCIAL_AUTH_REDIRECT_URI',
    defaultValue: 'muud://auth/callback',
  );

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

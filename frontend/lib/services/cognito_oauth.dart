import 'package:flutter_appauth/flutter_appauth.dart';

class CognitoOAuthService {
  CognitoOAuthService._();
  static final CognitoOAuthService instance = CognitoOAuthService._();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  // ✅ Your Cognito Hosted UI domain (NO trailing slash)
  // From Cognito → User pool → Domain
  // Example: https://us-west-2xxxx.auth.us-west-2.amazoncognito.com
  static const String cognitoDomain =
      'https://us-west-2vrtcZ20k3.auth.us-west-2.amazoncognito.com';

  // ✅ Your Cognito App Client ID
  static const String clientId = '6j8cleke98rr4kq3nskumptqcm';

  // ✅ Choose ONE custom scheme for mobile redirect and use it everywhere
  // We'll use: muudhealth://callback
  // (You will add this to Cognito Allowed callback URLs in the next step)
  static const String redirectUri = 'muudhealth://callback';

  // Optional (nice to have)
  static const String postLogoutRedirectUri = 'muudhealth://signout';

  // OIDC endpoints for Hosted UI
  static const AuthorizationServiceConfiguration _serviceConfig =
      AuthorizationServiceConfiguration(
        authorizationEndpoint: '$cognitoDomain/oauth2/authorize',
        tokenEndpoint: '$cognitoDomain/oauth2/token',
        endSessionEndpoint: '$cognitoDomain/logout',
      );

  static const List<String> _scopes = <String>['openid', 'email', 'profile'];

  /// Generic sign-in that forces a specific IdP button (Google / Facebook / Apple)
  Future<TokenResponse> signInWithProvider({
    required String providerName,
  }) async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUri,
        serviceConfiguration: _serviceConfig,
        scopes: _scopes,

        // Cognito Hosted UI expects this param to jump directly to the provider
        additionalParameters: <String, String>{
          'identity_provider': providerName,
          'prompt': 'select_account',
        },

        // If you later enable PKCE settings / want explicit:
        // preferEphemeralSession: true,
      ),
    );

    if (result == null) {
      throw Exception('Login cancelled');
    }
    if (result.accessToken == null || result.idToken == null) {
      throw Exception('Missing tokens from Cognito');
    }
    return result;
  }

  Future<TokenResponse> signInWithGoogle() =>
      signInWithProvider(providerName: 'Google');

  Future<TokenResponse> signInWithFacebook() =>
      signInWithProvider(providerName: 'Facebook');

  Future<TokenResponse> signInWithApple() =>
      signInWithProvider(providerName: 'SignInWithApple');

  /// Hosted UI logout (opens browser session)
  /// Note: this is optional for now.
  Uri buildLogoutUrl() {
    // Cognito logout endpoint:
    // /logout?client_id=...&logout_uri=...
    final uri = Uri.parse('$cognitoDomain/logout').replace(
      queryParameters: <String, String>{
        'client_id': clientId,
        'logout_uri': postLogoutRedirectUri,
      },
    );
    return uri;
  }
}

import 'package:flutter_appauth/flutter_appauth.dart';

class CognitoOAuthService {
  CognitoOAuthService._();
  static final CognitoOAuthService instance = CognitoOAuthService._();

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  // Cognito Hosted UI domain (NO trailing slash)
  // Override via: --dart-define=COGNITO_DOMAIN=https://your-domain.auth.region.amazoncognito.com
  static const String cognitoDomain = String.fromEnvironment(
    'COGNITO_DOMAIN',
    defaultValue: 'https://us-west-2vrtcZ20k3.auth.us-west-2.amazoncognito.com',
  );

  // Cognito App Client ID
  // Override via: --dart-define=COGNITO_CLIENT_ID=your-client-id
  static const String clientId = String.fromEnvironment(
    'COGNITO_CLIENT_ID',
    defaultValue: '6j8cleke98rr4kq3nskumptqcm',
  );

  // Custom scheme for mobile redirect
  // Override via: --dart-define=COGNITO_REDIRECT_URI=your-redirect-uri
  static const String redirectUri = String.fromEnvironment(
    'COGNITO_REDIRECT_URI',
    defaultValue: 'muudhealth://callback',
  );

  // Post-logout redirect URI
  // Override via: --dart-define=COGNITO_LOGOUT_URI=your-logout-uri
  static const String postLogoutRedirectUri = String.fromEnvironment(
    'COGNITO_LOGOUT_URI',
    defaultValue: 'muudhealth://signout',
  );

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

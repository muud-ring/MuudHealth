import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';
import '../services/onboarding_api.dart';
import '../services/api_client.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, onboarding }

class AuthState {
  final AuthStatus status;
  final String? accessToken;
  final String? displayName;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.accessToken,
    this.displayName,
  });

  AuthState copyWith({AuthStatus? status, String? accessToken, String? displayName}) {
    return AuthState(
      status: status ?? this.status,
      accessToken: accessToken ?? this.accessToken,
      displayName: displayName ?? this.displayName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> checkAuth() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // If token is expired, attempt refresh before giving up
    final expired = await TokenStorage.isTokenExpired();
    if (expired) {
      final refreshed = await _tryRefresh();
      if (!refreshed) {
        await TokenStorage.clearTokens();
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
    }

    try {
      final currentToken = await TokenStorage.getAccessToken();
      final completed = await OnboardingApi.isCompleted();
      final name = await TokenStorage.getDisplayName();
      state = state.copyWith(
        status: completed ? AuthStatus.authenticated : AuthStatus.onboarding,
        accessToken: currentToken,
        displayName: name,
      );
    } catch (_) {
      await TokenStorage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if refresh succeeded, false otherwise.
  Future<bool> _tryRefresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newIdToken = data['idToken'] as String?;
        if (newAccessToken != null && newIdToken != null) {
          await TokenStorage.saveTokens(
            idToken: newIdToken,
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setAuthenticated(String token) async {
    final name = await TokenStorage.getDisplayName();
    state = state.copyWith(
      status: AuthStatus.authenticated,
      accessToken: token,
      displayName: name,
    );
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

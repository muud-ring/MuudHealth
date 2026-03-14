import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage.dart';
import '../services/onboarding_api.dart';

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
    try {
      final completed = await OnboardingApi.isCompleted();
      final name = await TokenStorage.getDisplayName();
      state = state.copyWith(
        status: completed ? AuthStatus.authenticated : AuthStatus.onboarding,
        accessToken: token,
        displayName: name,
      );
    } catch (_) {
      await TokenStorage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
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

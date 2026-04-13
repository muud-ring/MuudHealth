import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';
import 'onboarding_api.dart';

class PostAuthRedirect {
  static Future<void> go(BuildContext context) async {
    try {
      final completed = await OnboardingApi.isCompleted();
      if (!context.mounted) return;

      if (completed) {
        context.go(Routes.home);
      } else {
        context.go(Routes.onboarding('01'));
      }
    } catch (_) {
      if (!context.mounted) return;
      context.go(Routes.home);
    }
  }
}

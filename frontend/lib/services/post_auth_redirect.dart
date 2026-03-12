import 'package:flutter/material.dart';
import 'onboarding_api.dart';

class PostAuthRedirect {
  static Future<void> go(BuildContext context) async {
    try {
      final completed = await OnboardingApi.isCompleted();
      if (!context.mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        completed ? '/home' : '/onboarding/01',
        (_) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    }
  }
}

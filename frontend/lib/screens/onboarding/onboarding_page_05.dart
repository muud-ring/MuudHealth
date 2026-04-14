import 'package:flutter/material.dart';
import '../../services/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage05 extends StatelessWidget {
  const OnboardingPage05({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: MuudColors.purple,
                    size: 22,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),

              // Illustration - takes up available space
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Image.asset(
                      'assets/images/onboarding/onboarding05.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Title
              const Center(
                child: Text(
                  "MUUD wants to send you\nnotifications",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: MuudColors.purple,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Center(
                child: Text(
                  "MUUD's notifications will remind you to log\nyour journal/journey.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    color: MuudColors.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Allow notifications button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MuudColors.purple,
                    foregroundColor: MuudColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: MuudRadius.pillAll,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Later you can request OS permission here.
                    OnboardingState.answers.notificationsEnabled =
                        true; // ✅ store
                    context.push(Routes.onboarding('06'));
                  },
                  child: const Text(
                    "Allow notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MuudColors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // No thanks button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: MuudColors.purple, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: MuudRadius.pillAll,
                    ),
                  ),
                  onPressed: () {
                    OnboardingState.answers.notificationsEnabled =
                        false; // ✅ store
                    context.push(Routes.onboarding('06'));
                  },
                  child: const Text(
                    "No thanks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MuudColors.purple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

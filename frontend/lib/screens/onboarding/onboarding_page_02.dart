import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage02 extends StatelessWidget {
  const OnboardingPage02({super.key});
  Future<void> _skip(BuildContext context) async {
    // ✅ Save as skipped (completed:false) — per your requirement
    try {
      await OnboardingApi.saveOnboarding(
        favoriteColor: OnboardingState.answers.favoriteColor,
        focusGoal: OnboardingState.answers.focusGoal.isEmpty
            ? "Other"
            : OnboardingState.answers.focusGoal,
        activities: OnboardingState.answers.activities,
        notificationsEnabled: OnboardingState.answers.notificationsEnabled,
        completed: false,
      );
    } catch (_) {}

    if (!context.mounted) return;
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    // Respect system text scaling for WCAG Dynamic Type compliance
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

                const SizedBox(height: 32),

                // Title - "Hello!" and "Welcome to MUUD Health!"
                const Text(
                  "Hello!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: MuudColors.purple,
                    height: 1.2,
                  ),
                ),
                const Text(
                  "Welcome to MUUD Health!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: MuudColors.purple,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                // Body text
                const Text(
                  "Let's take a few minutes to get you set up. Ensure you're in a quiet space and ready for the next steps.",
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.4,
                    color: MuudColors.purple,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Illustration centered in remaining space
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Image.asset(
                        'assets/images/onboarding/onboarding02.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Continue button
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
                    onPressed: () =>
                        context.push(Routes.onboarding('03')),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: MuudColors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Skip setup button
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
                    onPressed: () => _skip(context),
                    child: const Text(
                      "Skip setup",
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

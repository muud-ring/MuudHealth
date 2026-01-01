import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';

class OnboardingPage02 extends StatelessWidget {
  const OnboardingPage02({super.key});

  static const Color kPurple = Color(0xFF5B288E);

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
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Lock text scaling so it matches Figma sizing
    final mq = MediaQuery.of(context);
    final media = mq.copyWith(textScaler: const TextScaler.linear(1.0));

    return MediaQuery(
      data: media,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back arrow (matches Figma style)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  alignment: Alignment.centerLeft,
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: kPurple,
                    size: 22,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 28),

                // Title (Figma-like)
                const Text(
                  "Hello!\nWelcome to MUUD Health!",
                  style: TextStyle(
                    fontSize:
                        40, // slightly smaller than 44; closer to your Figma pic
                    fontWeight: FontWeight.w800,
                    color: kPurple,
                    height: 1.08,
                  ),
                ),

                const SizedBox(height: 18),

                // Body text (in Figma it's purple + larger than your earlier gray)
                const Text(
                  "Let’s take a few minutes to get you set up.\n"
                  "Ensure you’re in a quiet space and ready for\n"
                  "the next steps.",
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.28,
                    color: kPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Push illustration down like Figma, but keep it flexible to avoid overflow
                const Spacer(),

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 360,
                      maxHeight: 320,
                    ),
                    child: Image.asset(
                      'assets/images/onboarding/onboarding02.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const Spacer(),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPurple,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/onboarding/03'),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Skip setup button
                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPurple, width: 2),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => _skip(context),
                    child: const Text(
                      "Skip setup",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

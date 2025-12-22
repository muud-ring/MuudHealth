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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back, color: kPurple),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              const Text(
                "Hello!\nWelcome to MUUD Health!",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Let’s take a few minutes to get you set up.\n"
                "Ensure you’re in a quiet space and ready for\n"
                "the next steps.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Text("Illustration placeholder"),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPurple),
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
    );
  }
}

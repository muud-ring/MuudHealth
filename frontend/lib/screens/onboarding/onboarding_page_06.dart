import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';

class OnboardingPage06 extends StatelessWidget {
  const OnboardingPage06({super.key});

  static const Color kPurple = Color(0xFF5B288E);

  Future<void> _skip(BuildContext context) async {
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
              const SizedBox(height: 10),

              const Text(
                "Great! Here’s how MUUD\nHealth can support you:",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: ListView(
                  children: const [
                    _SupportCard(
                      text:
                          "Discover strategies to help you navigate and work with your emotions.",
                    ),
                    SizedBox(height: 14),
                    _SupportCard(
                      text:
                          "Uncover patterns by reflecting through your daily journal or journey.",
                    ),
                    SizedBox(height: 14),
                    _SupportCard(
                      text:
                          "Find the right wellness session tailored to your needs.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
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
                      Navigator.pushNamed(context, '/onboarding/07'),
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

class _SupportCard extends StatelessWidget {
  final String text;
  const _SupportCard({required this.text});

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text("Illustration placeholder"),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';

class OnboardingPage03 extends StatefulWidget {
  const OnboardingPage03({super.key});

  @override
  State<OnboardingPage03> createState() => _OnboardingPage03State();
}

class _OnboardingPage03State extends State<OnboardingPage03> {
  static const Color kPurple = Color(0xFF5B288E);

  String? selectedGoal;

  final List<String> goalOptions = const [
    "Improve mood",
    "Increase focus and productivity",
    "Self-improvement",
    "Reduce stress or anxiety",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    final saved = OnboardingState.answers.focusGoal;
    if (saved.isNotEmpty) selectedGoal = saved;
  }

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
    final canContinue = selectedGoal != null;

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
              const SizedBox(height: 12),
              const Text(
                "Is there anything specific\nyou’d like to focus on?",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your answers won’t prevent you from\n"
                "accessing any wellness tips, and you can\n"
                "adjust your settings later.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: goalOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final option = goalOptions[i];
                    final selected = selectedGoal == option;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() => selectedGoal = option);
                        OnboardingState.answers.focusGoal = option; // ✅ store
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE8E8E8),
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kPurple, width: 2),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: kPurple,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple.withOpacity(
                      canContinue ? 1 : 0.45,
                    ),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: canContinue
                      ? () => Navigator.pushNamed(context, '/onboarding/04')
                      : null,
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

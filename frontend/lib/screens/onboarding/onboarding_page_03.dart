import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage03 extends StatefulWidget {
  const OnboardingPage03({super.key});

  @override
  State<OnboardingPage03> createState() => _OnboardingPage03State();
}

class _OnboardingPage03State extends State<OnboardingPage03> {
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
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = selectedGoal != null;

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

              // Title
              const Text(
                "Is there anything specific\nyou'd like to focus on?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: MuudColors.purple,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              const Text(
                "Your answers won't prevent you from accessing any wellness tips, and you can adjust your settings later.",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: MuudColors.purple,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Options list
              Expanded(
                child: ListView.separated(
                  itemCount: goalOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final option = goalOptions[i];
                    final selected = selectedGoal == option;

                    return InkWell(
                      borderRadius: MuudRadius.lgAll,
                      onTap: () {
                        setState(() => selectedGoal = option);
                        OnboardingState.answers.focusGoal = option; // ✅ store
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: MuudRadius.lgAll,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: MuudColors.purple, width: 2),
                                color: selected
                                    ? MuudColors.white
                                    : Colors.transparent,
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: MuudColors.purple,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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

              const SizedBox(height: 16),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MuudColors.purple.withValues(alpha:canContinue ? 1 : 0.5),
                    foregroundColor: MuudColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: MuudRadius.pillAll,
                    ),
                    elevation: 0,
                  ),
                  onPressed: canContinue
                      ? () => context.push(Routes.onboarding('04'))
                      : null,
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

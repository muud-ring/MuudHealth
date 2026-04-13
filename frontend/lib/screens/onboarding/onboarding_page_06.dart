import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage06 extends StatefulWidget {
  const OnboardingPage06({super.key});

  @override
  State<OnboardingPage06> createState() => _OnboardingPage06State();
}

class _OnboardingPage06State extends State<OnboardingPage06> {
  final List<_SupportOption> options = const [
    _SupportOption(
      id: 'emotions',
      text:
          "Discover strategies to help you navigate and work with your emotions.",
      imagePath: 'assets/images/onboarding/onboarding06_map.png',
    ),
    _SupportOption(
      id: 'journal',
      text:
          "Uncover patterns by reflecting through your daily journal or journey.",
      imagePath: 'assets/images/onboarding/onboarding06_journal.png',
    ),
    _SupportOption(
      id: 'wellness',
      text: "Find the right wellness session tailored to your needs.",
      imagePath: 'assets/images/onboarding/onboarding06_wellness.png',
    ),
  ];

  final Set<String> selectedOptions = {};

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

              const SizedBox(height: 24),

              // Title
              const Text(
                "Great! Here's how MUUD\nHealth can support you:",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: MuudColors.purple,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 20),

              // Cards list
              Expanded(
                child: ListView.separated(
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedOptions.contains(option.id);

                    return _SupportCard(
                      text: option.text,
                      imagePath: option.imagePath,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedOptions.remove(option.id);
                          } else {
                            selectedOptions.add(option.id);
                          }
                        });
                      },
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
                    backgroundColor: MuudColors.purple,
                    foregroundColor: MuudColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: MuudRadius.pillAll,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () =>
                      context.push(Routes.onboarding('07')),
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

class _SupportOption {
  final String id;
  final String text;
  final String imagePath;

  const _SupportOption({
    required this.id,
    required this.text,
    required this.imagePath,
  });
}

class _SupportCard extends StatelessWidget {
  final String text;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _SupportCard({
    required this.text,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: MuudRadius.lgAll,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: MuudRadius.lgAll,
          border: isSelected ? Border.all(color: MuudColors.purple, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                height: 120,
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

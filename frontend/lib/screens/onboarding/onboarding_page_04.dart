import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage04 extends StatefulWidget {
  const OnboardingPage04({super.key});

  @override
  State<OnboardingPage04> createState() => _OnboardingPage04State();
}

class _OnboardingPage04State extends State<OnboardingPage04> {
  final List<_ActivityItem> items = const [
    _ActivityItem("Meditation", "🧘"),
    _ActivityItem("Exercise", "🏃‍♀️"),
    _ActivityItem("Reading", "📚"),
    _ActivityItem("Cooking", "👩‍🍳"),
    _ActivityItem("Social", "🕺"),
    _ActivityItem("Pet care", "🐩"),
  ];

  final Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    selected.addAll(OnboardingState.answers.activities); // ✅ prefill
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
    final canContinue = selected.isNotEmpty;

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
                "Do you have any preferred\ntypes of activities?",
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

              const SizedBox(height: 20),

              // Activity grid
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final isSelected = selected.contains(item.title);

                    return InkWell(
                      borderRadius: MuudRadius.lgAll,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selected.remove(item.title);
                          } else {
                            selected.add(item.title);
                          }
                        });

                        // ✅ store
                        OnboardingState.answers.activities = selected.toList();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: MuudRadius.lgAll,
                          border: isSelected
                              ? Border.all(color: MuudColors.purple, width: 2)
                              : null,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 56),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
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
                  onPressed: () =>
                      context.push(Routes.onboarding('05')),
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

class _ActivityItem {
  final String title;
  final String emoji;
  const _ActivityItem(this.title, this.emoji);
}

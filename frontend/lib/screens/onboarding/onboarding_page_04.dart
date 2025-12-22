import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';

class OnboardingPage04 extends StatefulWidget {
  const OnboardingPage04({super.key});

  @override
  State<OnboardingPage04> createState() => _OnboardingPage04State();
}

class _OnboardingPage04State extends State<OnboardingPage04> {
  static const Color kPurple = Color(0xFF5B288E);

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
              const SizedBox(height: 12),
              const Text(
                "Do you have any preferred\ntypes of activities?",
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
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final isSelected = selected.contains(item.title);

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? kPurple
                                : const Color(0xFFE8E8E8),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 44),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
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
                    backgroundColor: kPurple,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/onboarding/05'),
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

class _ActivityItem {
  final String title;
  final String emoji;
  const _ActivityItem(this.title, this.emoji);
}

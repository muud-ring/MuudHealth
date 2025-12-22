import 'package:flutter/material.dart';
import '../../services/onboarding_state.dart';

class OnboardingPage07 extends StatefulWidget {
  const OnboardingPage07({super.key});

  @override
  State<OnboardingPage07> createState() => _OnboardingPage07State();
}

class _OnboardingPage07State extends State<OnboardingPage07> {
  static const Color kPurple = Color(0xFF5B288E);

  String? mood;

  final List<_MoodItem> moods = const [
    _MoodItem("Happy", "😀"),
    _MoodItem("Fear", "😱"),
    _MoodItem("Dislike", "🤢"),
    _MoodItem("Sadness", "😭"),
    _MoodItem("Angry", "😡"),
    _MoodItem("Surprised", "🤯"),
  ];

  @override
  void initState() {
    super.initState();
    final saved = OnboardingState.answers.firstMood;
    if (saved.isNotEmpty) mood = saved;
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
                "Let’s get started with your\nfirst MUUD check-in",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Tap the MUUD that best describes how you\nfeel right now",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: kPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),

              Expanded(
                child: GridView.builder(
                  itemCount: moods.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (_, i) {
                    final item = moods[i];
                    final selected = mood == item.label;

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() => mood = item.label);
                        OnboardingState.answers.firstMood =
                            item.label; // ✅ store
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected ? kPurple : const Color(0xFFE8E8E8),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 54),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: kPurple,
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
                      mood == null ? 0.45 : 1,
                    ),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: mood == null
                      ? null
                      : () => Navigator.pushNamed(context, '/onboarding/08'),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodItem {
  final String label;
  final String emoji;
  const _MoodItem(this.label, this.emoji);
}

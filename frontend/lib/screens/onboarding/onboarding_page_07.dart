import 'package:flutter/material.dart';
import '../../services/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage07 extends StatefulWidget {
  const OnboardingPage07({super.key});

  @override
  State<OnboardingPage07> createState() => _OnboardingPage07State();
}

class _OnboardingPage07State extends State<OnboardingPage07> {
  static const Color kPink = Color(0xFFD946EF);

  String? mood;

  @override
  void initState() {
    super.initState();
    final saved = OnboardingState.answers.firstMood;
    if (saved.isNotEmpty) mood = saved;
  }

  void _selectMood(String label) {
    setState(() => mood = label);
    OnboardingState.answers.firstMood = label; // ✅ store
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back arrow
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: const Text(
                "Let's get started with your\nfirst MUUD check-in",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: MuudColors.purple,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle (pink/magenta color)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: const Text(
                "Tap the MUUD that best describes how you\nfeel right now",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: kPink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Mood selection area - flexible to take remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Row 1: Happy and Fear (centered)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MoodButton(
                            label: "Happy",
                            emoji: "😁",
                            circleColor: const Color(0xFFAB5DD8),
                            isSelected: mood == "Happy",
                            onTap: () => _selectMood("Happy"),
                          ),
                          const SizedBox(width: 48),
                          _MoodButton(
                            label: "Fear",
                            emoji: "😱",
                            circleColor: const Color(0xFFFACC15),
                            isSelected: mood == "Fear",
                            onTap: () => _selectMood("Fear"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Row 2: Dislike (left) and Sadness (right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _MoodButton(
                            label: "Dislike",
                            emoji: "🤢",
                            circleColor: const Color(0xFF22C55E),
                            isSelected: mood == "Dislike",
                            onTap: () => _selectMood("Dislike"),
                          ),
                          _MoodButton(
                            label: "Sadness",
                            emoji: "😭",
                            circleColor: const Color(0xFF3B82F6),
                            isSelected: mood == "Sadness",
                            onTap: () => _selectMood("Sadness"),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Row 3: Angry and Surprised (centered)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MoodButton(
                            label: "Angry",
                            emoji: "😠",
                            circleColor: const Color(0xFFEF4444),
                            isSelected: mood == "Angry",
                            onTap: () => _selectMood("Angry"),
                          ),
                          const SizedBox(width: 48),
                          _MoodButton(
                            label: "Surprised",
                            emoji: "🤯",
                            circleColor: const Color(0xFFF97316),
                            isSelected: mood == "Surprised",
                            onTap: () => _selectMood("Surprised"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MuudColors.purple.withValues(alpha:
                      mood == null ? 0.5 : 1,
                    ),
                    foregroundColor: MuudColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: MuudRadius.pillAll,
                    ),
                    elevation: 0,
                  ),
                  onPressed: mood == null
                      ? null
                      : () => context.push(Routes.onboarding('08')),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color circleColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodButton({
    required this.label,
    required this.emoji,
    required this.circleColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              border: isSelected
                  ? Border.all(color: MuudColors.purple, width: 3)
                  : null,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 42)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// MUUD Health — Daily Greeting Card (Home Dashboard)
// Context-aware greeting with time-of-day awareness
// Signal → Insight layer: personalized daily message
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class DailyGreetingCard extends StatelessWidget {
  final String displayName;
  final int? streakDays;
  final String? todayMood;

  const DailyGreetingCard({
    super.key,
    required this.displayName,
    this.streakDays,
    this.todayMood,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = _timeBasedGreeting();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MuudSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MuudColors.purple,
            MuudColors.darkPurple,
          ],
        ),
        borderRadius: MuudRadius.lgAll,
        boxShadow: MuudShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting,',
            style: MuudTypography.bodyMedium.copyWith(
              color: MuudColors.lightPurple,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayName,
            style: MuudTypography.headingLarge.copyWith(
              color: MuudColors.white,
              fontSize: 26,
            ),
          ),
          if (streakDays != null && streakDays! > 0) ...[
            const SizedBox(height: MuudSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MuudSpacing.md,
                vertical: MuudSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: MuudColors.white.withValues(alpha: 0.15),
                borderRadius: MuudRadius.pillAll,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('\u{1F525}', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '$streakDays day streak',
                    style: MuudTypography.label.copyWith(
                      color: MuudColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

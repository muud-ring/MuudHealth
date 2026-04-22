// MUUD Health — Signal Pathway Progress Card
// Visualizes the user's journey through Signal → Insight → Action → Learn → Grow
// Maps to SCA-IPA-BGA-SCA product loop milestones
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SignalPathwayCard extends StatelessWidget {
  /// Progress for each stage (0.0 to 1.0)
  final double signalProgress;
  final double insightProgress;
  final double actionProgress;
  final double learnProgress;
  final double growProgress;

  const SignalPathwayCard({
    super.key,
    this.signalProgress = 0.0,
    this.insightProgress = 0.0,
    this.actionProgress = 0.0,
    this.learnProgress = 0.0,
    this.growProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MuudSpacing.base),
      decoration: BoxDecoration(
        color: MuudColors.white,
        borderRadius: MuudRadius.lgAll,
        boxShadow: MuudShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: MuudColors.purple, size: 20),
              const SizedBox(width: MuudSpacing.sm),
              Text('Your Pathway', style: MuudTypography.titleMedium),
            ],
          ),
          const SizedBox(height: MuudSpacing.md),
          _PathwayStep(
            label: 'Signal',
            subtitle: 'Capture & generate data',
            icon: Icons.sensors_rounded,
            color: MuudColors.signal,
            progress: signalProgress,
          ),
          _PathwayStep(
            label: 'Insight',
            subtitle: 'Dashboards & metrics',
            icon: Icons.insights_rounded,
            color: MuudColors.insight,
            progress: insightProgress,
          ),
          _PathwayStep(
            label: 'Action',
            subtitle: 'Notifications & reminders',
            icon: Icons.flash_on_rounded,
            color: MuudColors.action,
            progress: actionProgress,
          ),
          _PathwayStep(
            label: 'Learn',
            subtitle: 'Shared experiences',
            icon: Icons.school_rounded,
            color: MuudColors.plan,
            progress: learnProgress,
          ),
          _PathwayStep(
            label: 'Grow',
            subtitle: 'Positive behavior change',
            icon: Icons.trending_up_rounded,
            color: MuudColors.success,
            progress: growProgress,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _PathwayStep extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isLast;

  const _PathwayStep({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : MuudSpacing.sm),
      child: Row(
        children: [
          // Step indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: progress > 0
                  ? color.withValues(alpha: 0.15)
                  : MuudColors.divider.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: progress > 0 ? color : MuudColors.greyText,
            ),
          ),
          const SizedBox(width: MuudSpacing.md),
          // Label + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: MuudTypography.label.copyWith(
                    color: progress > 0 ? MuudColors.darkText : MuudColors.greyText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: MuudColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: MuudSpacing.sm),
          Text(
            '${(progress * 100).round()}%',
            style: MuudTypography.caption.copyWith(
              color: MuudColors.greyText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

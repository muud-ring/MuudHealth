// MUUD Health — Quick Stats Row (Home Dashboard)
// Compact metric pills for at-a-glance biometric summary
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class QuickStatsRow extends StatelessWidget {
  final int? heartRate;
  final int? steps;
  final int? sleepMinutes;
  final int? stressLevel;

  const QuickStatsRow({
    super.key,
    this.heartRate,
    this.steps,
    this.sleepMinutes,
    this.stressLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (heartRate != null)
          Expanded(child: _StatPill(
            icon: Icons.favorite_rounded,
            color: MuudColors.error,
            value: '$heartRate',
            unit: 'bpm',
          )),
        if (steps != null) ...[
          const SizedBox(width: MuudSpacing.sm),
          Expanded(child: _StatPill(
            icon: Icons.directions_walk_rounded,
            color: MuudColors.success,
            value: _formatSteps(steps!),
            unit: 'steps',
          )),
        ],
        if (sleepMinutes != null) ...[
          const SizedBox(width: MuudSpacing.sm),
          Expanded(child: _StatPill(
            icon: Icons.bedtime_rounded,
            color: MuudColors.accentBlue,
            value: _formatSleep(sleepMinutes!),
            unit: 'sleep',
          )),
        ],
        if (stressLevel != null) ...[
          const SizedBox(width: MuudSpacing.sm),
          Expanded(child: _StatPill(
            icon: Icons.psychology_rounded,
            color: MuudColors.warning,
            value: '$stressLevel',
            unit: 'stress',
          )),
        ],
      ],
    );
  }

  String _formatSteps(int s) => s >= 1000 ? '${(s / 1000).toStringAsFixed(1)}k' : '$s';

  String _formatSleep(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h${m}m' : '${h}h';
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String unit;

  const _StatPill({
    required this.icon,
    required this.color,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MuudSpacing.sm,
        vertical: MuudSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: MuudRadius.mdAll,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: MuudTypography.titleMedium.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
          Text(
            unit,
            style: MuudTypography.caption.copyWith(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

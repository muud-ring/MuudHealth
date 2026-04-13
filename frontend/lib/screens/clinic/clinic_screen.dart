// MUUD Health — Clinic Screen (MUUD Clinic Pillar)
// Healthcare services: psychiatry, therapy, coaching
// Phase 4 feature — stub for navigation and route wiring
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ClinicScreen extends StatelessWidget {
  const ClinicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        title: Text(
          'MUUD Clinic',
          style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
        backgroundColor: MuudColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: MuudColors.purple),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MuudSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: MuudColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 48,
                  color: MuudColors.success,
                ),
              ),
              const SizedBox(height: MuudSpacing.lg),
              Text(
                'Coming Soon',
                style: MuudTypography.heading.copyWith(
                  color: MuudColors.purple,
                ),
              ),
              const SizedBox(height: MuudSpacing.md),
              Text(
                'MUUD Clinic connects you with licensed psychiatrists, '
                'therapists, and wellness coaches for personalized care.',
                textAlign: TextAlign.center,
                style: MuudTypography.bodyMedium.copyWith(
                  color: MuudColors.bodyText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: MuudSpacing.xl),

              // Service previews
              _ServicePreview(
                icon: Icons.psychology_rounded,
                title: 'Psychiatry',
                subtitle: 'Medication management & evaluation',
                color: MuudColors.accentBlue,
              ),
              const SizedBox(height: MuudSpacing.md),
              _ServicePreview(
                icon: Icons.self_improvement_rounded,
                title: 'Therapy',
                subtitle: 'Talk therapy & cognitive behavioral',
                color: MuudColors.purple,
              ),
              const SizedBox(height: MuudSpacing.md),
              _ServicePreview(
                icon: Icons.directions_run_rounded,
                title: 'Coaching',
                subtitle: 'Wellness & behavioral coaching',
                color: MuudColors.success,
              ),

              const SizedBox(height: MuudSpacing.xl),
              // Notify me button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You\'ll be notified when MUUD Clinic launches.'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MuudColors.purple,
                    side: const BorderSide(color: MuudColors.purple, width: 1.5),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    'Notify Me',
                    style: MuudTypography.button.copyWith(
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

class _ServicePreview extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ServicePreview({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MuudSpacing.base),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: MuudRadius.mdAll,
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: MuudSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MuudTypography.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MuudColors.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: MuudTypography.caption.copyWith(
                    color: MuudColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

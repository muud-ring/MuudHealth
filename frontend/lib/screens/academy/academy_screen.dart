// MUUD Health — Academy Screen (MUUD Academy Pillar)
// Education services: training modules, certifications, supervised hours
// Phase 4 feature — stub for navigation and route wiring
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      appBar: AppBar(
        title: Text(
          'MUUD Academy',
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
                  color: MuudColors.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: MuudColors.accentBlue,
                ),
              ),
              const SizedBox(height: MuudSpacing.lg),
              Text(
                'Coming Soon',
                style: MuudTypography.headingLarge.copyWith(
                  color: MuudColors.purple,
                ),
              ),
              const SizedBox(height: MuudSpacing.md),
              Text(
                'MUUD Academy provides training and certification programs '
                'for health and wellness professionals.',
                textAlign: TextAlign.center,
                style: MuudTypography.bodyMedium.copyWith(
                  color: MuudColors.bodyText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: MuudSpacing.xl),

              // Track previews
              _TrackPreview(
                icon: Icons.menu_book_rounded,
                title: 'Wellness Fundamentals',
                modules: 12,
                color: MuudColors.accentBlue,
              ),
              const SizedBox(height: MuudSpacing.md),
              _TrackPreview(
                icon: Icons.psychology_rounded,
                title: 'Behavioral Health',
                modules: 8,
                color: MuudColors.purple,
              ),
              const SizedBox(height: MuudSpacing.md),
              _TrackPreview(
                icon: Icons.biotech_rounded,
                title: 'Biometric Analysis',
                modules: 10,
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
                        content: Text('You\'ll be notified when MUUD Academy launches.'),
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

class _TrackPreview extends StatelessWidget {
  final IconData icon;
  final String title;
  final int modules;
  final Color color;

  const _TrackPreview({
    required this.icon,
    required this.title,
    required this.modules,
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
                  '$modules modules',
                  style: MuudTypography.caption.copyWith(
                    color: MuudColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MuudSpacing.sm,
              vertical: MuudSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: MuudRadius.pillAll,
            ),
            child: Text(
              'Preview',
              style: MuudTypography.label.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

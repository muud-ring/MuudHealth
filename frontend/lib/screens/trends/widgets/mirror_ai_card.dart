// MUUD Health — Mirror AI Insight Card
// Displays AI-generated insights from Infinity AI (Trends layer)
// Signal → Insight customer output point of the SCA-IPA-BGA-SCA loop
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MirrorAiCard extends StatelessWidget {
  final String? summary;
  final List<String> recommendations;
  final bool isLoading;

  const MirrorAiCard({
    super.key,
    this.summary,
    this.recommendations = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MuudColors.purple.withValues(alpha: 0.08),
            MuudColors.accentBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: MuudRadius.lgAll,
        border: Border.all(
          color: MuudColors.purple.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(MuudSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MuudColors.purple.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 20,
                    color: MuudColors.purple,
                  ),
                ),
                const SizedBox(width: MuudSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MUUD Mirror',
                        style: MuudTypography.titleMedium.copyWith(
                          color: MuudColors.purple,
                        ),
                      ),
                      Text(
                        'Infinity AI \u00B7 Trends Analysis',
                        style: MuudTypography.caption.copyWith(
                          color: MuudColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Beta badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MuudSpacing.sm,
                    vertical: MuudSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: MuudColors.accentBlue.withValues(alpha: 0.1),
                    borderRadius: MuudRadius.pillAll,
                  ),
                  child: Text(
                    'BETA',
                    style: MuudTypography.label.copyWith(
                      color: MuudColors.accentBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: MuudSpacing.md),

            // Content
            if (isLoading) ...[
              _ShimmerLine(width: double.infinity),
              const SizedBox(height: 8),
              _ShimmerLine(width: 200),
            ] else if (summary != null) ...[
              Text(
                summary!,
                style: MuudTypography.bodyMedium.copyWith(
                  color: MuudColors.darkText,
                  height: 1.6,
                ),
              ),
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: MuudSpacing.md),
                ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: MuudSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.tips_and_updates_outlined,
                          size: 16,
                          color: MuudColors.success,
                        ),
                      ),
                      const SizedBox(width: MuudSpacing.sm),
                      Expanded(
                        child: Text(
                          rec,
                          style: MuudTypography.bodySmall.copyWith(
                            color: MuudColors.bodyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ] else ...[
              Text(
                'Your personalized insights will appear here as MUUD Mirror analyzes your trends over time.',
                style: MuudTypography.bodyMedium.copyWith(
                  color: MuudColors.greyText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double width;
  const _ShimmerLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: MuudColors.purple.withValues(alpha: 0.06),
        borderRadius: MuudRadius.smAll,
      ),
    );
  }
}

// MUUD Health — Mood Ring Card (MUUD Notes 12-Emotion Dial)
// Maps to the Ring fidget dial interaction (patented)
// © Muud Health — Armin Hoes, MD

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/muud_note_reaction.dart';
import '../../../theme/app_theme.dart';

class MoodRingCard extends StatelessWidget {
  /// Today's selected mood (nullable if not yet selected)
  final MuudEmotion? selectedMood;

  /// Callback when user selects a mood
  final ValueChanged<MuudEmotion>? onMoodSelected;

  /// Mood distribution over period (emotion name → count)
  final Map<String, int> moodDistribution;

  const MoodRingCard({
    super.key,
    this.selectedMood,
    this.onMoodSelected,
    this.moodDistribution = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MuudColors.white,
        borderRadius: MuudRadius.lgAll,
        boxShadow: MuudShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(MuudSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.mood_rounded, color: MuudColors.purple, size: 22),
                const SizedBox(width: MuudSpacing.sm),
                Text('MUUD Notes', style: MuudTypography.titleMedium),
                const Spacer(),
                if (selectedMood != null) ...[
                  Text(
                    MuudNoteReaction.emojis[selectedMood!]!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    MuudNoteReaction.labels[selectedMood!]!,
                    style: MuudTypography.caption.copyWith(
                      color: MuudNoteReaction.colors[selectedMood!],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: MuudSpacing.base),

            // Emotion dial (12-position ring)
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: CustomPaint(
                  painter: _EmotionDialPainter(
                    selected: selectedMood,
                    distribution: moodDistribution,
                  ),
                  child: _EmotionDialButtons(
                    selected: selectedMood,
                    onSelect: onMoodSelected,
                  ),
                ),
              ),
            ),

            const SizedBox(height: MuudSpacing.md),

            // Distribution summary (if available)
            if (moodDistribution.isNotEmpty) ...[
              Text(
                'This Week',
                style: MuudTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: MuudSpacing.sm),
              Wrap(
                spacing: MuudSpacing.sm,
                runSpacing: MuudSpacing.xs,
                children: _buildDistributionChips(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDistributionChips() {
    final sorted = moodDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(6).map((entry) {
      final emoji = MuudNoteReaction.emojiForName(entry.key);
      final color = MuudNoteReaction.colorForName(entry.key);
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: MuudSpacing.sm,
          vertical: MuudSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: MuudRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '${entry.value}',
              style: MuudTypography.label.copyWith(color: color),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// ── Emotion Dial Painter ──────────────────────────────────────────────────

class _EmotionDialPainter extends CustomPainter {
  final MuudEmotion? selected;
  final Map<String, int> distribution;

  _EmotionDialPainter({this.selected, this.distribution = const {}});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    // Draw ring track
    final trackPaint = Paint()
      ..color = MuudColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw colored segments for each emotion
    for (int i = 0; i < MuudEmotion.values.length; i++) {
      final emotion = MuudEmotion.values[i];
      final angle = (i * 2 * math.pi / 12) - math.pi / 2;
      final isSelected = emotion == selected;

      final segPaint = Paint()
        ..color = MuudNoteReaction.colors[emotion]!.withValues(
          alpha: isSelected ? 0.3 : 0.08,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 6 : 3;

      final startAngle = angle - (math.pi / 12);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        math.pi / 6,
        false,
        segPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EmotionDialPainter old) =>
      old.selected != selected || old.distribution != distribution;
}

// ── Emotion Dial Buttons ──────────────────────────────────────────────────

class _EmotionDialButtons extends StatelessWidget {
  final MuudEmotion? selected;
  final ValueChanged<MuudEmotion>? onSelect;

  const _EmotionDialButtons({this.selected, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2 - 30;

        return Stack(
          children: [
            // Center indicator
            Positioned(
              left: center.dx - 24,
              top: center.dy - 24,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected != null
                      ? MuudNoteReaction.colors[selected!]!.withValues(alpha: 0.12)
                      : MuudColors.palePurple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    selected != null
                        ? MuudNoteReaction.emojis[selected!]!
                        : '\u{1F914}', // 🤔
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ),
            // Emotion buttons around the ring
            for (int i = 0; i < MuudEmotion.values.length; i++)
              _positionedEmoji(
                i,
                MuudEmotion.values[i],
                center,
                radius,
              ),
          ],
        );
      },
    );
  }

  Widget _positionedEmoji(
    int index,
    MuudEmotion emotion,
    Offset center,
    double radius,
  ) {
    final angle = (index * 2 * math.pi / 12) - math.pi / 2;
    final x = center.dx + radius * math.cos(angle) - 16;
    final y = center.dy + radius * math.sin(angle) - 16;
    final isSelected = emotion == selected;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => onSelect?.call(emotion),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected
                ? MuudNoteReaction.colors[emotion]!.withValues(alpha: 0.2)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(
                    color: MuudNoteReaction.colors[emotion]!,
                    width: 2,
                  )
                : null,
          ),
          child: Center(
            child: Text(
              MuudNoteReaction.emojis[emotion]!,
              style: TextStyle(fontSize: isSelected ? 18 : 16),
            ),
          ),
        ),
      ),
    );
  }
}

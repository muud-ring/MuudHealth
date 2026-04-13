import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../models/biometric_reading.dart';

class StepsCard extends StatelessWidget {
  const StepsCard({super.key, required this.steps});

  final StepsSummary steps;

  static const Color _stepsColor = Color(0xFFFF7043);
  static const int _defaultGoal = 10000;

  @override
  Widget build(BuildContext context) {
    final total = steps.total ?? 0;
    final goal = steps.goal ?? _defaultGoal;
    final progress = goal > 0 ? (total / goal).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();
    final goalReached = total >= goal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _stepsColor.withValues(alpha:0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: _stepsColor.withValues(alpha:0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _stepsColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_walk_rounded,
                    color: _stepsColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Steps',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MuudColors.darkText,
                ),
              ),
              const Spacer(),
              if (goalReached)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: Color(0xFF2ECC71)),
                      SizedBox(width: 4),
                      Text(
                        'Goal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2ECC71),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatNumber(total),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _stepsColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of ${_formatNumber(goal)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MuudColors.greyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: _stepsColor.withValues(alpha:0.1),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _stepsColor.withValues(alpha:0.7),
                            _stepsColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% of daily goal',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: MuudColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = (n % 1000) ~/ 100;
      if (remainder > 0) return '$thousands,${(n % 1000).toString().padLeft(3, '0')}';
      return '$thousands,000';
    }
    return n.toString();
  }
}

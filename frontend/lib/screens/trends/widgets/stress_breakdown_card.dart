import 'package:flutter/material.dart';
import '../../../models/biometric_reading.dart';
import '../../../theme/app_theme.dart';

/// Detailed stress breakdown card showing average and peak stress levels
/// with a visual gauge, inspired by Build #8's dedicated trends sections.
class StressBreakdownCard extends StatelessWidget {
  const StressBreakdownCard({super.key, required this.stress});

  final StressSummary stress;

  @override
  Widget build(BuildContext context) {
    final avg = stress.avg ?? 0;
    final peak = stress.max ?? 0;
    final level = _stressLevel(avg);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, size: 20, color: Color(0xFF6D4C41)),
              SizedBox(width: 8),
              Text(
                'Stress Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stress gauge
          _StressGauge(value: avg),
          const SizedBox(height: 14),
          // Level label
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: level.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                level.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: level.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatColumn(label: 'Average', value: '$avg', color: level.color),
              ),
              Container(width: 1, height: 36, color: Colors.grey.withOpacity(0.15)),
              Expanded(
                child: _StatColumn(
                  label: 'Peak',
                  value: '$peak',
                  color: _stressLevel(peak).color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static _StressLevelInfo _stressLevel(int value) {
    if (value <= 25) {
      return _StressLevelInfo('Low', const Color(0xFF43A047));
    } else if (value <= 50) {
      return _StressLevelInfo('Moderate', const Color(0xFFFF8F00));
    } else if (value <= 75) {
      return _StressLevelInfo('High', const Color(0xFFE53935));
    }
    return _StressLevelInfo('Very High', const Color(0xFFB71C1C));
  }
}

class _StressLevelInfo {
  final String label;
  final Color color;
  _StressLevelInfo(this.label, this.color);
}

class _StressGauge extends StatelessWidget {
  const _StressGauge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final fraction = (value / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 14,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF43A047).withOpacity(0.15),
                        const Color(0xFFFF8F00).withOpacity(0.15),
                        const Color(0xFFE53935).withOpacity(0.15),
                      ],
                    ),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF43A047),
                          if (fraction > 0.4) const Color(0xFFFF8F00),
                          if (fraction > 0.7) const Color(0xFFE53935),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            Text('50', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            Text('100', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
          ],
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }
}

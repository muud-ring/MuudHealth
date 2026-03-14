import 'package:flutter/material.dart';
import '../../../models/biometric_reading.dart';

class SleepCard extends StatelessWidget {
  const SleepCard({super.key, required this.sleep});

  final SleepSummary sleep;

  static const Color _deepColor = Color(0xFF1A237E);
  static const Color _lightColor = Color(0xFF5C6BC0);
  static const Color _remColor = Color(0xFF7E57C2);
  static const Color _awakeColor = Color(0xFFFFB74D);
  static const Color _cardColor = Color(0xFF3F51B5);

  @override
  Widget build(BuildContext context) {
    final totalMin = sleep.totalMinutes ?? 0;
    final hours = totalMin ~/ 60;
    final minutes = totalMin % 60;
    final timeStr = minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _cardColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: _cardColor.withOpacity(0.15)),
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
                  color: _cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bedtime_rounded,
                    color: _cardColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sleep',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const Spacer(),
              if (sleep.score != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _scoreColor(sleep.score!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score ${sleep.score}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _scoreColor(sleep.score!),
                    ),
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
                timeStr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _cardColor,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'total sleep',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF898384),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sleep stages bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 14,
              child: _buildStagesBar(totalMin),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (sleep.deepMinutes != null && sleep.deepMinutes! > 0)
                _LegendItem(
                  color: _deepColor,
                  label: 'Deep',
                  minutes: sleep.deepMinutes!,
                ),
              if (sleep.lightMinutes != null && sleep.lightMinutes! > 0)
                _LegendItem(
                  color: _lightColor,
                  label: 'Light',
                  minutes: sleep.lightMinutes!,
                ),
              if (sleep.remMinutes != null && sleep.remMinutes! > 0)
                _LegendItem(
                  color: _remColor,
                  label: 'REM',
                  minutes: sleep.remMinutes!,
                ),
              if (sleep.awakeMinutes != null && sleep.awakeMinutes! > 0)
                _LegendItem(
                  color: _awakeColor,
                  label: 'Awake',
                  minutes: sleep.awakeMinutes!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStagesBar(int totalMin) {
    if (totalMin <= 0) {
      return Container(color: Colors.grey.withOpacity(0.15));
    }

    final deep = sleep.deepMinutes ?? 0;
    final light = sleep.lightMinutes ?? 0;
    final rem = sleep.remMinutes ?? 0;
    final awake = sleep.awakeMinutes ?? 0;

    return Row(
      children: [
        if (deep > 0)
          Expanded(flex: deep, child: Container(color: _deepColor)),
        if (light > 0)
          Expanded(flex: light, child: Container(color: _lightColor)),
        if (rem > 0)
          Expanded(flex: rem, child: Container(color: _remColor)),
        if (awake > 0)
          Expanded(flex: awake, child: Container(color: _awakeColor)),
      ],
    );
  }

  static Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF2ECC71);
    if (score >= 60) return const Color(0xFF8BC34A);
    if (score >= 40) return const Color(0xFFF39C12);
    return const Color(0xFFE74C3C);
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.minutes,
  });

  final Color color;
  final String label;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label $timeStr',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF898384),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

enum MetricTrend { up, down, stable }

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.trend = MetricTrend.stable,
    this.subtitle,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final MetricTrend trend;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15)),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              _TrendIndicator(trend: trend, color: color),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF898384),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.lightGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  const _TrendIndicator({required this.trend, required this.color});

  final MetricTrend trend;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final IconData trendIcon;
    final Color trendColor;

    switch (trend) {
      case MetricTrend.up:
        trendIcon = Icons.trending_up_rounded;
        trendColor = const Color(0xFF2ECC71);
      case MetricTrend.down:
        trendIcon = Icons.trending_down_rounded;
        trendColor = const Color(0xFFE74C3C);
      case MetricTrend.stable:
        trendIcon = Icons.trending_flat_rounded;
        trendColor = const AppTheme.lightGrey;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(trendIcon, size: 18, color: trendColor),
    );
  }
}

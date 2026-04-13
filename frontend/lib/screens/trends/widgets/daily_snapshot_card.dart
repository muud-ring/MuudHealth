import 'package:flutter/material.dart';
import '../../../models/biometric_reading.dart';
import '../../../theme/app_theme.dart';

/// A compact at-a-glance summary of all daily biometric readings,
/// inspired by Build #8's "daily snapshot" widget section.
class DailySnapshotCard extends StatelessWidget {
  const DailySnapshotCard({super.key, required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: MuudColors.purple.withValues(alpha: 0.07),
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
              Icon(Icons.dashboard_rounded, size: 20, color: MuudColors.purple),
              SizedBox(width: 8),
              Text(
                'Daily Snapshot',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: MuudColors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    final items = <Widget>[];

    if (summary.heartRate?.avg != null) {
      items.add(_SnapshotChip(
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE53935),
        label: '${summary.heartRate!.avg} bpm',
      ));
    }

    if (summary.hrv?.avg != null) {
      items.add(_SnapshotChip(
        icon: Icons.monitor_heart_rounded,
        color: const Color(0xFF8E24AA),
        label: '${summary.hrv!.avg} ms HRV',
      ));
    }

    if (summary.spo2?.avg != null) {
      items.add(_SnapshotChip(
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF1E88E5),
        label: '${summary.spo2!.avg!.toStringAsFixed(1)}% SpO2',
      ));
    }

    if (summary.temperature?.avg != null) {
      items.add(_SnapshotChip(
        icon: Icons.thermostat_rounded,
        color: const Color(0xFFFF8F00),
        label: '${summary.temperature!.avg!.toStringAsFixed(1)}\u00B0F',
      ));
    }

    if (summary.stress?.avg != null) {
      items.add(_SnapshotChip(
        icon: Icons.psychology_rounded,
        color: const Color(0xFF6D4C41),
        label: 'Stress ${summary.stress!.avg}',
      ));
    }

    if (summary.steps?.total != null) {
      items.add(_SnapshotChip(
        icon: Icons.directions_walk_rounded,
        color: const Color(0xFF43A047),
        label: '${_formatNumber(summary.steps!.total!)} steps',
      ));
    }

    if (summary.sleep?.totalMinutes != null) {
      final h = summary.sleep!.totalMinutes! ~/ 60;
      final m = summary.sleep!.totalMinutes! % 60;
      items.add(_SnapshotChip(
        icon: Icons.bedtime_rounded,
        color: const Color(0xFF3949AB),
        label: '${h}h ${m}m sleep',
      ));
    }

    return items;
  }

  static String _formatNumber(int n) {
    if (n < 1000) return '$n';
    return '${(n / 1000).toStringAsFixed(1)}k';
  }
}

class _SnapshotChip extends StatelessWidget {
  const _SnapshotChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha:0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

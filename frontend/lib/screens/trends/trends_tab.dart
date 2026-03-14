import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/biometric_reading.dart';
import '../../providers/biometrics_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/wellness_score_card.dart';
import 'widgets/metric_card.dart';
import 'widgets/sleep_card.dart';
import 'widgets/steps_card.dart';

class TrendsTab extends ConsumerWidget {
  const TrendsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(biometricsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.purple),
              )
            : state.hasData
                ? _BiometricsDashboard(state: state)
                : const _EmptyState(),
      ),
    );
  }
}

/* ----------------------- DATE SELECTOR ----------------------- */

class _DateSelector extends ConsumerWidget {
  const _DateSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(biometricsProvider);
    final notifier = ref.read(biometricsProvider.notifier);
    final selected = state.selectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(selected.year, selected.month, selected.day);

    String label;
    if (selectedDay == today) {
      label = 'Today';
    } else if (selectedDay == yesterday) {
      label = 'Yesterday';
    } else {
      label =
          '${_monthName(selected.month)} ${selected.day}, ${selected.year}';
    }

    return Row(
      children: [
        // Previous day
        _DateArrowButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => notifier.selectDate(
            selected.subtract(const Duration(days: 1)),
          ),
        ),
        const SizedBox(width: 8),
        // Date label / picker
        Expanded(
          child: GestureDetector(
            onTap: () => _pickDate(context, notifier, selected),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.purple.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppTheme.purple.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.purple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Next day (disabled if today)
        _DateArrowButton(
          icon: Icons.chevron_right_rounded,
          onTap: selectedDay.isBefore(today)
              ? () => notifier.selectDate(
                    selected.add(const Duration(days: 1)),
                  )
              : null,
        ),
      ],
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    BiometricsNotifier notifier,
    DateTime current,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.purple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D2D2D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      notifier.selectDate(picked);
    }
  }

  static String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}

class _DateArrowButton extends StatelessWidget {
  const _DateArrowButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.purple.withOpacity(0.06)
              : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: enabled
              ? AppTheme.purple
              : Colors.grey.withOpacity(0.3),
          size: 24,
        ),
      ),
    );
  }
}

/* ---------------------- DASHBOARD BODY ---------------------- */

class _BiometricsDashboard extends StatelessWidget {
  const _BiometricsDashboard({required this.state});

  final BiometricsState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary!;

    return RefreshIndicator(
      color: AppTheme.purple,
      onRefresh: () async {
        // Trigger a reload via the provider from the nearest consumer ancestor.
        // The RefreshIndicator needs a Future, so we access the container
        // through ProviderScope.
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const _DateSelector(),
                  const SizedBox(height: 20),
                  // Wellness score
                  if (summary.wellnessScore != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: WellnessScoreCard(score: summary.wellnessScore!),
                    ),
                ],
              ),
            ),
          ),
          // Metric cards grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildListDelegate(
                _buildMetricCards(summary),
              ),
            ),
          ),
          // Full-width cards (sleep, steps)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildFullWidthCards(summary),
              ),
            ),
          ),
          // Bottom spacer for tab bar
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  List<Widget> _buildMetricCards(DailySummary summary) {
    final cards = <Widget>[];

    if (summary.heartRate != null) {
      final hr = summary.heartRate!;
      cards.add(MetricCard(
        title: 'Heart Rate',
        value: '${hr.avg ?? '--'}',
        unit: 'bpm',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE53935),
        trend: MetricTrend.stable,
        subtitle: hr.resting != null ? 'Resting ${hr.resting} bpm' : null,
      ));
    }

    if (summary.hrv != null) {
      final hrv = summary.hrv!;
      cards.add(MetricCard(
        title: 'HRV',
        value: '${hrv.avg ?? '--'}',
        unit: 'ms',
        icon: Icons.monitor_heart_rounded,
        color: const Color(0xFF8E24AA),
        trend: MetricTrend.stable,
        subtitle: hrv.min != null && hrv.max != null
            ? '${hrv.min}–${hrv.max} ms range'
            : null,
      ));
    }

    if (summary.spo2 != null) {
      final spo2 = summary.spo2!;
      final displayVal = spo2.avg != null
          ? spo2.avg!.toStringAsFixed(1)
          : '--';
      cards.add(MetricCard(
        title: 'SpO2',
        value: displayVal,
        unit: '%',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF1E88E5),
        trend: MetricTrend.stable,
        subtitle: spo2.min != null ? 'Min ${spo2.min!.toStringAsFixed(1)}%' : null,
      ));
    }

    if (summary.temperature != null) {
      final temp = summary.temperature!;
      final displayVal = temp.avg != null
          ? temp.avg!.toStringAsFixed(1)
          : '--';
      cards.add(MetricCard(
        title: 'Temperature',
        value: displayVal,
        unit: '\u00B0F',
        icon: Icons.thermostat_rounded,
        color: const Color(0xFFFF8F00),
        trend: MetricTrend.stable,
      ));
    }

    if (summary.stress != null) {
      final stress = summary.stress!;
      cards.add(MetricCard(
        title: 'Stress',
        value: '${stress.avg ?? '--'}',
        unit: '',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF6D4C41),
        trend: MetricTrend.stable,
        subtitle: stress.max != null ? 'Peak ${stress.max}' : null,
      ));
    }

    return cards;
  }

  List<Widget> _buildFullWidthCards(DailySummary summary) {
    final cards = <Widget>[];

    if (summary.sleep != null) {
      cards.add(Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SleepCard(sleep: summary.sleep!),
      ));
    }

    if (summary.steps != null) {
      cards.add(Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: StepsCard(steps: summary.steps!),
      ));
    }

    return cards;
  }
}

/* ----------------------- EMPTY STATE ----------------------- */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color _kPurple = AppTheme.purple;
  static const Color _kGreyText = AppTheme.greyText;
  static const Color _kLightPurple = Color(0xFFC9B7E6);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          const _DateSelector(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 4),
                    // Empty icon
                    SizedBox(
                      width: 86,
                      height: 86,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.storage_rounded,
                            size: 64,
                            color: _kLightPurple.withOpacity(0.75),
                          ),
                          Positioned(
                            right: 6,
                            bottom: 16,
                            child: Icon(
                              Icons.search_rounded,
                              size: 34,
                              color: _kLightPurple.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Data',
                      style: TextStyle(
                        color: _kPurple,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your trends will show up here.',
                      style: TextStyle(
                        color: _kGreyText.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Start Journaling',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

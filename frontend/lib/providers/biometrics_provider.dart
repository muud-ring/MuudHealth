import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/biometric_reading.dart';
import '../services/biometrics_api.dart';

class BiometricsState {
  final DailySummary? summary;
  final Map<String, BiometricReading> latestReadings;
  final DateTime selectedDate;
  final bool isLoading;
  final String? error;

  const BiometricsState({
    this.summary,
    this.latestReadings = const {},
    required this.selectedDate,
    this.isLoading = false,
    this.error,
  });

  bool get hasData =>
      summary != null &&
      (summary!.heartRate != null ||
          summary!.hrv != null ||
          summary!.spo2 != null ||
          summary!.temperature != null ||
          summary!.sleep != null ||
          summary!.steps != null ||
          summary!.stress != null ||
          summary!.wellnessScore != null);

  BiometricsState copyWith({
    DailySummary? summary,
    Map<String, BiometricReading>? latestReadings,
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
  }) {
    return BiometricsState(
      summary: summary ?? this.summary,
      latestReadings: latestReadings ?? this.latestReadings,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BiometricsNotifier extends StateNotifier<BiometricsState> {
  BiometricsNotifier()
      : super(BiometricsState(selectedDate: DateTime.now())) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dateStr = _formatDate(state.selectedDate);
      final results = await Future.wait([
        BiometricsApi.getDailySummary(dateStr),
        BiometricsApi.getLatest(),
      ]);
      final summary = results[0] as DailySummary;
      final latest = results[1] as Map<String, BiometricReading>;
      state = state.copyWith(
        summary: summary,
        latestReadings: latest,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await loadData();
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

final biometricsProvider =
    StateNotifierProvider<BiometricsNotifier, BiometricsState>((ref) {
  return BiometricsNotifier();
});

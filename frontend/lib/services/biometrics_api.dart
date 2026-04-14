// MUUD Health — Biometrics API Service
// Signal → Ring → Cloud pipeline
// © Muud Health — Armin Hoes, MD

import '../models/biometric_reading.dart';
import 'api_client.dart';

class BiometricsApi {
  BiometricsApi._();

  /// Submit single biometric reading
  static Future<void> recordReading(BiometricReading reading) async {
    final res = await ApiClient.post(
      '/api/v1/biometrics/reading',
      body: reading.toJson(),
    );
    ApiClient.handleResponse(res);
  }

  /// Submit batch readings (from Ring sync)
  static Future<void> recordBatch(List<BiometricReading> readings) async {
    final res = await ApiClient.post(
      '/api/v1/biometrics/batch',
      body: {'readings': readings.map((r) => r.toJson()).toList()},
    );
    ApiClient.handleResponse(res);
  }

  /// Get reading history
  static Future<List<BiometricReading>> getHistory({
    String range = '7d',
    String? type,
    int limit = 100,
  }) async {
    final params = <String>['range=$range', 'limit=$limit'];
    if (type != null) params.add('type=$type');
    final res = await ApiClient.get(
      '/api/v1/biometrics/history?${params.join("&")}',
    );
    final data = ApiClient.handleResponse(res);
    final list = (data['readings'] as List?) ?? [];
    return list.map((j) => BiometricReading.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// Get latest reading per type
  static Future<Map<String, BiometricReading>> getLatest() async {
    final res = await ApiClient.get('/api/v1/biometrics/latest');
    final data = ApiClient.handleResponse(res);
    final latest = data['latest'] as Map<String, dynamic>? ?? {};
    return latest.map((k, v) => MapEntry(k, BiometricReading.fromJson(v as Map<String, dynamic>)));
  }

  /// Get daily summary for a specific date (YYYY-MM-DD)
  static Future<DailySummary> getDailySummary(String date) async {
    final res = await ApiClient.get('/api/v1/biometrics/summary/$date');
    final data = ApiClient.handleResponse(res);
    return DailySummary.fromJson(data['summary'] as Map<String, dynamic>? ?? {});
  }

  /// Get range of daily summaries
  static Future<List<DailySummary>> getSummaryRange(String from, String to) async {
    final res = await ApiClient.get(
      '/api/v1/biometrics/summaries?from=$from&to=$to',
    );
    final data = ApiClient.handleResponse(res);
    final list = (data['summaries'] as List?) ?? [];
    return list.map((j) => DailySummary.fromJson(j as Map<String, dynamic>)).toList();
  }
}

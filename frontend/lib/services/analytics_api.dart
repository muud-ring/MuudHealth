// MUUD Health — Analytics API Service (MUUD Mirror AI data)
// © Muud Health — Armin Hoes, MD

import 'api_client.dart';

class AnalyticsApi {
  AnalyticsApi._();

  /// Get metric correlations (Infinity AI — Trends)
  static Future<Map<String, dynamic>> getCorrelation({
    String range = '30d',
    List<String> metrics = const ['heartRate', 'hrv', 'sleep', 'mood'],
  }) async {
    final params = 'range=$range&metrics=${metrics.join(",")}';
    final res = await ApiClient.get('/api/v1/analytics/correlation?$params');
    return ApiClient.handleResponse(res);
  }

  /// Get activity heatmap (Infinity AI — Trends)
  static Future<Map<String, dynamic>> getHeatmap({
    String range = '90d',
  }) async {
    final res = await ApiClient.get('/api/v1/analytics/heatmap?range=$range');
    return ApiClient.handleResponse(res);
  }

  /// Get sleep analytics (Infinity AI — Trends)
  static Future<Map<String, dynamic>> getSleepAnalytics({
    String range = '30d',
  }) async {
    final res = await ApiClient.get('/api/v1/analytics/sleep?range=$range');
    return ApiClient.handleResponse(res);
  }
}

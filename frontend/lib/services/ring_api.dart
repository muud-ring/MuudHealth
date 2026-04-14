// MUUD Health — Ring API Service (Smart Ring BLE → Cloud)
// © Muud Health — Armin Hoes, MD

import 'api_client.dart';

class RingApi {
  RingApi._();

  /// Register a new ring device
  static Future<Map<String, dynamic>> register({
    required String macAddress,
    required String firmwareVersion,
    required String model,
  }) async {
    final res = await ApiClient.post('/api/v1/ring/register', body: {
      'macAddress': macAddress,
      'firmwareVersion': firmwareVersion,
      'model': model,
    });
    return ApiClient.handleResponse(res);
  }

  /// Check for firmware updates
  static Future<Map<String, dynamic>> checkFirmware({
    required String currentVersion,
  }) async {
    final res = await ApiClient.get(
      '/api/v1/ring/firmware?current=$currentVersion',
    );
    return ApiClient.handleResponse(res);
  }

  /// Get ring connection status
  static Future<Map<String, dynamic>> getStatus() async {
    final res = await ApiClient.get('/api/v1/ring/status');
    return ApiClient.handleResponse(res);
  }
}

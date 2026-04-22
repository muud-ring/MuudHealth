// Muud Health — HealthKit / Google Fit Integration Service
// © Muud Health — Armin Hoes, MD

import 'dart:io';
import 'api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import 'biometrics_api.dart';

/// Platform-aware health data integration.
/// Uses HealthKit on iOS and Health Connect on Android.
class HealthDataService {
  HealthDataService._();

  static final Health _health = Health();
  static bool _authorized = false;

  /// Health data types to read from the platform.
  static final List<HealthDataType> _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.WEIGHT,
  ];

  /// Request health data permissions from the user.
  static Future<bool> requestPermissions() async {
    try {
      final permissions = _readTypes.map((_) => HealthDataAccess.READ).toList();
      _authorized = await _health.requestAuthorization(
        _readTypes,
        permissions: permissions,
      );
      debugPrint('[HealthData] Authorization: $_authorized');
      return _authorized;
    } catch (e) {
      debugPrint('[HealthData] Permission request failed: $e');
      return false;
    }
  }

  /// Check if health data access is currently authorized.
  static Future<bool> isAuthorized() async {
    try {
      // hasPermissions may not be available on all platforms
      return _authorized;
    } catch (_) {
      return false;
    }
  }

  /// Fetch today's step count.
  static Future<int> fetchTodaySteps() async {
    if (!_authorized) return 0;

    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('[HealthData] Steps fetch failed: $e');
      return 0;
    }
  }

  /// Fetch most recent heart rate reading.
  static Future<double?> fetchHeartRate() async {
    if (!_authorized) return null;

    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: oneHourAgo,
        endTime: now,
      );

      if (data.isEmpty) return null;

      // Return most recent reading
      final latest = data.last;
      return (latest.value as NumericHealthValue).numericValue.toDouble();
    } catch (e) {
      debugPrint('[HealthData] Heart rate fetch failed: $e');
      return null;
    }
  }

  /// Fetch last night's sleep data in minutes.
  static Future<int> fetchSleepMinutes() async {
    if (!_authorized) return 0;

    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED],
        startTime: yesterday,
        endTime: now,
      );

      if (data.isEmpty) return 0;

      // Sum all sleep segments
      int totalMinutes = 0;
      for (final point in data) {
        final duration = point.dateTo.difference(point.dateFrom);
        totalMinutes += duration.inMinutes;
      }
      return totalMinutes;
    } catch (e) {
      debugPrint('[HealthData] Sleep fetch failed: $e');
      return 0;
    }
  }

  /// Fetch blood oxygen saturation (SpO2) — most recent.
  static Future<double?> fetchBloodOxygen() async {
    if (!_authorized) return null;

    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 4));
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: oneHourAgo,
        endTime: now,
      );

      if (data.isEmpty) return null;
      return (data.last.value as NumericHealthValue).numericValue.toDouble();
    } catch (e) {
      debugPrint('[HealthData] Blood oxygen fetch failed: $e');
      return null;
    }
  }

  /// Sync all health data to the Muud backend.
  static Future<void> syncHealthData() async {
    if (!_authorized) {
      debugPrint('[HealthData] Not authorized — skipping sync');
      return;
    }

    try {
      final steps = await fetchTodaySteps();
      final heartRate = await fetchHeartRate();
      final sleepMinutes = await fetchSleepMinutes();
      final spo2 = await fetchBloodOxygen();

      final payload = {
        'source': Platform.isIOS ? 'healthkit' : 'health_connect',
        'steps': steps,
        'heartRate': heartRate,
        'sleepMinutes': sleepMinutes,
        'bloodOxygen': spo2,
        'syncedAt': DateTime.now().toIso8601String(),
      };

      // Post raw health sync payload directly to biometrics batch endpoint
      final res = await ApiClient.post('/api/v1/biometrics/reading', body: payload);
      ApiClient.handleResponse(res);
      debugPrint('[HealthData] Sync complete: $payload');
    } catch (e) {
      debugPrint('[HealthData] Sync failed: $e');
    }
  }
}

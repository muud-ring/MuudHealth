// Muud Health — Signal Loop Service (Frontend)
// © Muud Health — Armin Hoes, MD
//
// Client-side interface to the Signal → Insight → Action → Learn → Grow pipeline.
// Captures signals, fetches trends, and gets growth/recommendations.

import 'dart:convert';
import 'api_client.dart';
import '../models/trend_snapshot.dart';

class SignalLoopService {
  static const _base = '/api/v1/signals';

  /// Capture a single signal event.
  static Future<String?> captureSignal(String signalType, dynamic value, {Map<String, dynamic>? metadata}) async {
    try {
      final res = await ApiClient.post(_base, body: {
        'signalType': signalType,
        'value': value,
        if (metadata != null) 'metadata': metadata,
      });
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['signalId'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Capture a batch of signals (ring sync).
  static Future<int> captureBatch(List<Map<String, dynamic>> signals) async {
    try {
      final res = await ApiClient.post('$_base/batch', body: {'signals': signals});
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['captured'] as int? ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Get growth evaluation for the current user.
  static Future<Map<String, dynamic>?> getGrowthEvaluation() async {
    try {
      final res = await ApiClient.get('$_base/growth');
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get trend snapshots for the user.
  static Future<List<TrendSnapshot>> getTrends({String period = 'daily', int days = 30}) async {
    try {
      final res = await ApiClient.get('$_base/trends?period=$period&days=$days');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final list = data['snapshots'] as List<dynamic>? ?? [];
        return list.map((s) => TrendSnapshot.fromJson(s as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Force generation of a trend snapshot.
  static Future<TrendSnapshot?> generateSnapshot({DateTime? date, String period = 'daily'}) async {
    try {
      final res = await ApiClient.post('$_base/trends/generate', body: {
        if (date != null) 'date': date.toIso8601String(),
        'period': period,
      });
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['snapshot'] != null) {
          return TrendSnapshot.fromJson(data['snapshot'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get AI-powered recommendations (Learn stage).
  static Future<List<Map<String, dynamic>>> getRecommendations() async {
    try {
      final res = await ApiClient.get('$_base/recommendations');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['recommendations'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

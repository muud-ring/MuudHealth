import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage.dart';
import '../models/biometric_reading.dart';

class BiometricsApi {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.muudhealth.com',
  );

  static Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Future<void> recordReading(BiometricReading reading) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$_baseUrl/biometrics/reading'),
      headers: headers,
      body: jsonEncode(reading.toJson()),
    );
    if (res.statusCode != 201) throw Exception('Failed to record reading');
  }

  static Future<void> recordBatch(List<BiometricReading> readings) async {
    final headers = await _authHeaders();
    final res = await http.post(
      Uri.parse('$_baseUrl/biometrics/batch'),
      headers: headers,
      body: jsonEncode({'readings': readings.map((r) => r.toJson()).toList()}),
    );
    if (res.statusCode != 201) throw Exception('Failed to record batch');
  }

  static Future<List<BiometricReading>> getHistory({
    String? type,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) async {
    final headers = await _authHeaders();
    final params = <String, String>{'limit': '$limit'};
    if (type != null) params['type'] = type;
    if (from != null) params['from'] = from.toIso8601String();
    if (to != null) params['to'] = to.toIso8601String();

    final uri = Uri.parse('$_baseUrl/biometrics/history').replace(queryParameters: params);
    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) throw Exception('Failed to fetch history');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['readings'] as List?) ?? [];
    return list.map((j) => BiometricReading.fromJson(j)).toList();
  }

  static Future<Map<String, BiometricReading>> getLatest() async {
    final headers = await _authHeaders();
    final res = await http.get(Uri.parse('$_baseUrl/biometrics/latest'), headers: headers);
    if (res.statusCode != 200) throw Exception('Failed to fetch latest');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final latest = data['latest'] as Map<String, dynamic>? ?? {};
    return latest.map((k, v) => MapEntry(k, BiometricReading.fromJson(v)));
  }

  static Future<DailySummary> getDailySummary(String date) async {
    final headers = await _authHeaders();
    final res = await http.get(
      Uri.parse('$_baseUrl/biometrics/summary/$date'),
      headers: headers,
    );
    if (res.statusCode != 200) throw Exception('Failed to fetch summary');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return DailySummary.fromJson(data['summary'] ?? {});
  }

  static Future<List<DailySummary>> getSummaryRange(String from, String to) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_baseUrl/biometrics/summaries').replace(
      queryParameters: {'from': from, 'to': to},
    );
    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) throw Exception('Failed to fetch summaries');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['summaries'] as List?) ?? [];
    return list.map((j) => DailySummary.fromJson(j)).toList();
  }
}

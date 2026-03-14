import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/biometric_reading.dart';

class LocalCache {
  static const String _lastSyncKey = 'local_cache_last_sync';

  static Future<String> _cacheDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/cache/biometrics');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  /// Caches a [DailySummary] as a JSON file named by date.
  static Future<void> cacheDailySummary(DailySummary summary) async {
    try {
      final dir = await _cacheDir();
      final file = File('$dir/${summary.date}.json');
      await file.writeAsString(jsonEncode(summary.toJson()));
    } on FileSystemException {
      // Silently ignore file I/O errors to avoid crashing the caller.
    }
  }

  /// Retrieves a cached [DailySummary] for the given [date] string
  /// (expected format: yyyy-MM-dd). Returns null if not cached or on error.
  static Future<DailySummary?> getCachedSummary(String date) async {
    try {
      final dir = await _cacheDir();
      final file = File('$dir/$date.json');
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      final json = jsonDecode(contents) as Map<String, dynamic>;
      return DailySummary.fromJson(json);
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  /// Returns cached summaries whose dates fall within [from] and [to]
  /// (inclusive, compared lexicographically as yyyy-MM-dd strings).
  static Future<List<DailySummary>> getCachedSummaries(
    String from,
    String to,
  ) async {
    final summaries = <DailySummary>[];
    try {
      final dir = await _cacheDir();
      final cacheDir = Directory(dir);
      if (!await cacheDir.exists()) return summaries;

      final entities = await cacheDir.list().toList();
      for (final entity in entities) {
        if (entity is! File) continue;
        final name = entity.path.split('/').last;
        if (!name.endsWith('.json') || name == 'pending_queue.json') continue;

        final date = name.replaceAll('.json', '');
        if (date.compareTo(from) >= 0 && date.compareTo(to) <= 0) {
          try {
            final contents = await entity.readAsString();
            final json = jsonDecode(contents) as Map<String, dynamic>;
            summaries.add(DailySummary.fromJson(json));
          } on FormatException {
            // Skip corrupted files.
          }
        }
      }

      summaries.sort((a, b) => a.date.compareTo(b.date));
    } on FileSystemException {
      // Return whatever we collected so far.
    }
    return summaries;
  }

  /// Removes all cached biometric files.
  static Future<void> clearCache() async {
    try {
      final dir = await _cacheDir();
      final cacheDir = Directory(dir);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSyncKey);
    } on FileSystemException {
      // Best-effort cleanup.
    }
  }

  /// Records the current time as the last successful sync timestamp.
  static Future<void> setLastSync(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  /// Returns the last successful sync timestamp, or null if never synced.
  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSyncKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}

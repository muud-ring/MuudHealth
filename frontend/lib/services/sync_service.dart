import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/biometric_reading.dart';
import 'biometrics_api.dart';
import 'local_cache.dart';

class SyncService {
  static Future<String> _queuePath() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/cache/biometrics');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return '${dir.path}/pending_queue.json';
  }

  static Future<List<BiometricReading>> _readQueue() async {
    try {
      final path = await _queuePath();
      final file = File(path);
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final list = jsonDecode(contents) as List<dynamic>;
      return list
          .map((j) => BiometricReading.fromJson(j as Map<String, dynamic>))
          .toList();
    } on FileSystemException {
      return [];
    } on FormatException {
      return [];
    }
  }

  static Future<void> _writeQueue(List<BiometricReading> readings) async {
    try {
      final path = await _queuePath();
      final file = File(path);
      final json = readings.map((r) => r.toJson()).toList();
      await file.writeAsString(jsonEncode(json));
    } on FileSystemException {
      // Best-effort persistence.
    }
  }

  /// Adds a [BiometricReading] to the pending sync queue.
  static Future<void> queueReading(BiometricReading reading) async {
    final queue = await _readQueue();
    queue.add(reading);
    await _writeQueue(queue);
  }

  /// Attempts to sync all pending readings to the server via
  /// [BiometricsApi.recordBatch]. Successfully synced items are removed from
  /// the queue. If the batch call fails, the queue is left intact so a
  /// subsequent call can retry.
  static Future<void> syncPending() async {
    final queue = await _readQueue();
    if (queue.isEmpty) return;

    // Process in chunks of 50 to limit payload size and allow partial success.
    const batchSize = 50;
    final synced = <int>[];

    for (var i = 0; i < queue.length; i += batchSize) {
      final end = (i + batchSize > queue.length) ? queue.length : i + batchSize;
      final batch = queue.sublist(i, end);
      try {
        await BiometricsApi.recordBatch(batch);
        for (var j = i; j < end; j++) {
          synced.add(j);
        }
      } catch (_) {
        // This batch failed; leave those items in the queue and continue
        // trying subsequent batches so partial progress is possible.
      }
    }

    if (synced.isEmpty) return;

    // Remove successfully synced items (iterate in reverse to keep indices
    // stable).
    final remaining = <BiometricReading>[];
    for (var i = 0; i < queue.length; i++) {
      if (!synced.contains(i)) {
        remaining.add(queue[i]);
      }
    }

    await _writeQueue(remaining);
    await LocalCache.setLastSync(DateTime.now());
  }

  /// Returns the number of readings waiting to be synced.
  static Future<int> getPendingCount() async {
    final queue = await _readQueue();
    return queue.length;
  }
}

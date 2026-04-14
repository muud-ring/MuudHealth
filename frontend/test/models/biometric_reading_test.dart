import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/biometric_reading.dart';

void main() {
  group('BiometricReading', () {
    test('fromJson creates a valid BiometricReading', () {
      final json = {
        '_id': 'reading-123',
        'type': 'heart_rate',
        'value': 72,
        'unit': 'bpm',
        'source': 'smart_ring',
        'recordedAt': '2026-03-14T10:00:00.000Z',
        'metadata': {'confidence': 0.95},
      };

      final reading = BiometricReading.fromJson(json);

      expect(reading.id, 'reading-123');
      expect(reading.type, 'heart_rate');
      expect(reading.value, 72.0);
      expect(reading.unit, 'bpm');
      expect(reading.source, 'smart_ring');
      expect(reading.recordedAt, DateTime.parse('2026-03-14T10:00:00.000Z'));
      expect(reading.metadata['confidence'], 0.95);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        '_id': null,
        'type': 'spo2',
        'value': 98,
        'unit': '%',
        'recordedAt': '2026-03-14T12:00:00.000Z',
      };

      final reading = BiometricReading.fromJson(json);

      expect(reading.id, '');
      expect(reading.source, 'smart_ring');
      expect(reading.metadata, isEmpty);
    });

    test('toJson produces correct map', () {
      final reading = BiometricReading(
        id: 'reading-456',
        type: 'hrv',
        value: 45.5,
        unit: 'ms',
        source: 'manual',
        recordedAt: DateTime.parse('2026-03-14T08:30:00.000Z'),
        metadata: {'note': 'morning reading'},
      );

      final json = reading.toJson();

      expect(json['type'], 'hrv');
      expect(json['value'], 45.5);
      expect(json['unit'], 'ms');
      expect(json['source'], 'manual');
      expect(json['recordedAt'], '2026-03-14T08:30:00.000Z');
      expect(json['metadata']['note'], 'morning reading');
      // toJson should not include the id field
      expect(json.containsKey('_id'), false);
    });

    test('fromJson/toJson round-trip preserves data', () {
      final originalJson = {
        '_id': 'rt-001',
        'type': 'temperature',
        'value': 36.8,
        'unit': 'celsius',
        'source': 'smart_ring',
        'recordedAt': '2026-03-14T06:00:00.000Z',
        'metadata': {},
      };

      final reading = BiometricReading.fromJson(originalJson);
      final outputJson = reading.toJson();

      expect(outputJson['type'], originalJson['type']);
      expect(outputJson['value'], originalJson['value']);
      expect(outputJson['unit'], originalJson['unit']);
      expect(outputJson['source'], originalJson['source']);
      expect(outputJson['recordedAt'], originalJson['recordedAt']);
    });
  });

  group('DailySummary', () {
    test('fromJson with all sub-summaries', () {
      final json = {
        'date': '2026-03-14',
        'heartRate': {'avg': 72, 'min': 58, 'max': 120, 'resting': 58},
        'hrv': {'avg': 45, 'min': 30, 'max': 65},
        'spo2': {'avg': 97.5, 'min': 95.0},
        'temperature': {'avg': 36.6, 'min': 36.2, 'max': 37.1},
        'sleep': {
          'totalMinutes': 480,
          'deepMinutes': 90,
          'lightMinutes': 240,
          'remMinutes': 120,
          'awakeMinutes': 30,
          'score': 85,
        },
        'steps': {'total': 8500, 'goal': 10000},
        'stress': {'avg': 35, 'max': 72},
        'wellnessScore': 78.5,
      };

      final summary = DailySummary.fromJson(json);

      expect(summary.date, '2026-03-14');
      expect(summary.heartRate!.avg, 72);
      expect(summary.heartRate!.min, 58);
      expect(summary.heartRate!.max, 120);
      expect(summary.heartRate!.resting, 58);
      expect(summary.hrv!.avg, 45);
      expect(summary.hrv!.min, 30);
      expect(summary.hrv!.max, 65);
      expect(summary.spo2!.avg, 97.5);
      expect(summary.spo2!.min, 95.0);
      expect(summary.temperature!.avg, 36.6);
      expect(summary.temperature!.min, 36.2);
      expect(summary.temperature!.max, 37.1);
      expect(summary.sleep!.totalMinutes, 480);
      expect(summary.sleep!.deepMinutes, 90);
      expect(summary.sleep!.lightMinutes, 240);
      expect(summary.sleep!.remMinutes, 120);
      expect(summary.sleep!.awakeMinutes, 30);
      expect(summary.sleep!.score, 85);
      expect(summary.steps!.total, 8500);
      expect(summary.steps!.goal, 10000);
      expect(summary.stress!.avg, 35);
      expect(summary.stress!.max, 72);
      expect(summary.wellnessScore, 78.5);
    });

    test('fromJson with null/missing fields', () {
      final json = {
        'date': '2026-03-14',
      };

      final summary = DailySummary.fromJson(json);

      expect(summary.date, '2026-03-14');
      expect(summary.heartRate, isNull);
      expect(summary.hrv, isNull);
      expect(summary.spo2, isNull);
      expect(summary.temperature, isNull);
      expect(summary.sleep, isNull);
      expect(summary.steps, isNull);
      expect(summary.stress, isNull);
      expect(summary.wellnessScore, isNull);
    });

    test('fromJson with empty date defaults to empty string', () {
      final json = <String, dynamic>{};

      final summary = DailySummary.fromJson(json);

      expect(summary.date, '');
    });
  });

  group('HeartRateSummary', () {
    test('fromJson parses all fields', () {
      final json = {'avg': 72, 'min': 55, 'max': 130, 'resting': 55};
      final summary = HeartRateSummary.fromJson(json);

      expect(summary.avg, 72);
      expect(summary.min, 55);
      expect(summary.max, 130);
      expect(summary.resting, 55);
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{'avg': 72};
      final summary = HeartRateSummary.fromJson(json);

      expect(summary.avg, 72);
      expect(summary.min, isNull);
      expect(summary.max, isNull);
      expect(summary.resting, isNull);
    });
  });

  group('HrvSummary', () {
    test('fromJson parses all fields', () {
      final json = {'avg': 45, 'min': 30, 'max': 65};
      final summary = HrvSummary.fromJson(json);

      expect(summary.avg, 45);
      expect(summary.min, 30);
      expect(summary.max, 65);
    });
  });

  group('Spo2Summary', () {
    test('fromJson parses double values', () {
      final json = {'avg': 97.5, 'min': 95.0};
      final summary = Spo2Summary.fromJson(json);

      expect(summary.avg, 97.5);
      expect(summary.min, 95.0);
    });

    test('fromJson handles int values as doubles', () {
      final json = {'avg': 98, 'min': 96};
      final summary = Spo2Summary.fromJson(json);

      expect(summary.avg, 98.0);
      expect(summary.min, 96.0);
    });

    test('fromJson handles null values', () {
      final json = <String, dynamic>{};
      final summary = Spo2Summary.fromJson(json);

      expect(summary.avg, isNull);
      expect(summary.min, isNull);
    });
  });

  group('TemperatureSummary', () {
    test('fromJson parses double values', () {
      final json = {'avg': 36.6, 'min': 36.2, 'max': 37.1};
      final summary = TemperatureSummary.fromJson(json);

      expect(summary.avg, 36.6);
      expect(summary.min, 36.2);
      expect(summary.max, 37.1);
    });
  });

  group('SleepSummary', () {
    test('fromJson parses all fields', () {
      final json = {
        'totalMinutes': 480,
        'deepMinutes': 90,
        'lightMinutes': 240,
        'remMinutes': 120,
        'awakeMinutes': 30,
        'score': 85,
      };
      final summary = SleepSummary.fromJson(json);

      expect(summary.totalMinutes, 480);
      expect(summary.deepMinutes, 90);
      expect(summary.lightMinutes, 240);
      expect(summary.remMinutes, 120);
      expect(summary.awakeMinutes, 30);
      expect(summary.score, 85);
    });
  });

  group('StepsSummary', () {
    test('fromJson parses all fields', () {
      final json = {'total': 8500, 'goal': 10000};
      final summary = StepsSummary.fromJson(json);

      expect(summary.total, 8500);
      expect(summary.goal, 10000);
    });
  });

  group('StressSummary', () {
    test('fromJson parses all fields', () {
      final json = {'avg': 35, 'max': 72};
      final summary = StressSummary.fromJson(json);

      expect(summary.avg, 35);
      expect(summary.max, 72);
    });
  });
}

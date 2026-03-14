class BiometricReading {
  final String id;
  final String type;
  final double value;
  final String unit;
  final String source;
  final DateTime recordedAt;
  final Map<String, dynamic> metadata;

  BiometricReading({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.source,
    required this.recordedAt,
    this.metadata = const {},
  });

  factory BiometricReading.fromJson(Map<String, dynamic> json) {
    return BiometricReading(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] ?? '',
      source: json['source'] ?? 'smart_ring',
      recordedAt: DateTime.parse(json['recordedAt']),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    'unit': unit,
    'source': source,
    'recordedAt': recordedAt.toIso8601String(),
    'metadata': metadata,
  };
}

class DailySummary {
  final String date;
  final HeartRateSummary? heartRate;
  final HrvSummary? hrv;
  final Spo2Summary? spo2;
  final TemperatureSummary? temperature;
  final SleepSummary? sleep;
  final StepsSummary? steps;
  final StressSummary? stress;
  final double? wellnessScore;

  DailySummary({
    required this.date,
    this.heartRate,
    this.hrv,
    this.spo2,
    this.temperature,
    this.sleep,
    this.steps,
    this.stress,
    this.wellnessScore,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] ?? '',
      heartRate: json['heartRate'] != null ? HeartRateSummary.fromJson(json['heartRate']) : null,
      hrv: json['hrv'] != null ? HrvSummary.fromJson(json['hrv']) : null,
      spo2: json['spo2'] != null ? Spo2Summary.fromJson(json['spo2']) : null,
      temperature: json['temperature'] != null ? TemperatureSummary.fromJson(json['temperature']) : null,
      sleep: json['sleep'] != null ? SleepSummary.fromJson(json['sleep']) : null,
      steps: json['steps'] != null ? StepsSummary.fromJson(json['steps']) : null,
      stress: json['stress'] != null ? StressSummary.fromJson(json['stress']) : null,
      wellnessScore: (json['wellnessScore'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    if (heartRate != null) 'heartRate': heartRate!.toJson(),
    if (hrv != null) 'hrv': hrv!.toJson(),
    if (spo2 != null) 'spo2': spo2!.toJson(),
    if (temperature != null) 'temperature': temperature!.toJson(),
    if (sleep != null) 'sleep': sleep!.toJson(),
    if (steps != null) 'steps': steps!.toJson(),
    if (stress != null) 'stress': stress!.toJson(),
    if (wellnessScore != null) 'wellnessScore': wellnessScore,
  };
}

class HeartRateSummary {
  final int? avg, min, max, resting;
  HeartRateSummary({this.avg, this.min, this.max, this.resting});
  factory HeartRateSummary.fromJson(Map<String, dynamic> j) =>
    HeartRateSummary(avg: j['avg'], min: j['min'], max: j['max'], resting: j['resting']);
  Map<String, dynamic> toJson() => {'avg': avg, 'min': min, 'max': max, 'resting': resting};
}

class HrvSummary {
  final int? avg, min, max;
  HrvSummary({this.avg, this.min, this.max});
  factory HrvSummary.fromJson(Map<String, dynamic> j) =>
    HrvSummary(avg: j['avg'], min: j['min'], max: j['max']);
  Map<String, dynamic> toJson() => {'avg': avg, 'min': min, 'max': max};
}

class Spo2Summary {
  final double? avg;
  final double? min;
  Spo2Summary({this.avg, this.min});
  factory Spo2Summary.fromJson(Map<String, dynamic> j) =>
    Spo2Summary(avg: (j['avg'] as num?)?.toDouble(), min: (j['min'] as num?)?.toDouble());
  Map<String, dynamic> toJson() => {'avg': avg, 'min': min};
}

class TemperatureSummary {
  final double? avg, min, max;
  TemperatureSummary({this.avg, this.min, this.max});
  factory TemperatureSummary.fromJson(Map<String, dynamic> j) =>
    TemperatureSummary(avg: (j['avg'] as num?)?.toDouble(), min: (j['min'] as num?)?.toDouble(), max: (j['max'] as num?)?.toDouble());
  Map<String, dynamic> toJson() => {'avg': avg, 'min': min, 'max': max};
}

class SleepSummary {
  final int? totalMinutes, deepMinutes, lightMinutes, remMinutes, awakeMinutes, score;
  SleepSummary({this.totalMinutes, this.deepMinutes, this.lightMinutes, this.remMinutes, this.awakeMinutes, this.score});
  factory SleepSummary.fromJson(Map<String, dynamic> j) => SleepSummary(
    totalMinutes: j['totalMinutes'], deepMinutes: j['deepMinutes'],
    lightMinutes: j['lightMinutes'], remMinutes: j['remMinutes'],
    awakeMinutes: j['awakeMinutes'], score: j['score'],
  );
  Map<String, dynamic> toJson() => {
    'totalMinutes': totalMinutes, 'deepMinutes': deepMinutes,
    'lightMinutes': lightMinutes, 'remMinutes': remMinutes,
    'awakeMinutes': awakeMinutes, 'score': score,
  };
}

class StepsSummary {
  final int? total, goal;
  StepsSummary({this.total, this.goal});
  factory StepsSummary.fromJson(Map<String, dynamic> j) =>
    StepsSummary(total: j['total'], goal: j['goal']);
  Map<String, dynamic> toJson() => {'total': total, 'goal': goal};
}

class StressSummary {
  final int? avg, max;
  StressSummary({this.avg, this.max});
  factory StressSummary.fromJson(Map<String, dynamic> j) =>
    StressSummary(avg: j['avg'], max: j['max']);
  Map<String, dynamic> toJson() => {'avg': avg, 'max': max};
}

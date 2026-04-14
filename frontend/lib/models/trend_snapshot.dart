// Muud Health — Trend Snapshot Model (Cross-Platform Aggregate)
// © Muud Health — Armin Hoes, MD

class BiometricSummary {
  final double? avgHeartRate;
  final double? avgHrv;
  final double? avgSpO2;
  final double? avgTemperature;
  final int? totalSteps;
  final int? sleepMinutes;
  final double? sleepQuality;
  final double? stressLevel;

  const BiometricSummary({
    this.avgHeartRate, this.avgHrv, this.avgSpO2, this.avgTemperature,
    this.totalSteps, this.sleepMinutes, this.sleepQuality, this.stressLevel,
  });

  factory BiometricSummary.fromJson(Map<String, dynamic> json) => BiometricSummary(
        avgHeartRate: (json['avgHeartRate'] as num?)?.toDouble(),
        avgHrv: (json['avgHrv'] as num?)?.toDouble(),
        avgSpO2: (json['avgSpO2'] as num?)?.toDouble(),
        avgTemperature: (json['avgTemperature'] as num?)?.toDouble(),
        totalSteps: json['totalSteps'] as int?,
        sleepMinutes: json['sleepMinutes'] as int?,
        sleepQuality: (json['sleepQuality'] as num?)?.toDouble(),
        stressLevel: (json['stressLevel'] as num?)?.toDouble(),
      );
}

class BehavioralSummary {
  final int journalEntries;
  final int journalWordCount;
  final double? sentimentAvg;
  final int chatMessagesSent;
  final int connectionsActive;
  final int appSessionMinutes;
  final int vaultItemsSaved;

  const BehavioralSummary({
    this.journalEntries = 0, this.journalWordCount = 0, this.sentimentAvg,
    this.chatMessagesSent = 0, this.connectionsActive = 0,
    this.appSessionMinutes = 0, this.vaultItemsSaved = 0,
  });

  factory BehavioralSummary.fromJson(Map<String, dynamic> json) => BehavioralSummary(
        journalEntries: json['journalEntries'] as int? ?? 0,
        journalWordCount: json['journalWordCount'] as int? ?? 0,
        sentimentAvg: (json['sentimentAvg'] as num?)?.toDouble(),
        chatMessagesSent: json['chatMessagesSent'] as int? ?? 0,
        connectionsActive: json['connectionsActive'] as int? ?? 0,
        appSessionMinutes: json['appSessionMinutes'] as int? ?? 0,
        vaultItemsSaved: json['vaultItemsSaved'] as int? ?? 0,
      );
}

class WellnessScores {
  final int overallScore;
  final int physicalScore;
  final int mentalScore;
  final int socialScore;
  final int consistencyScore;

  const WellnessScores({
    this.overallScore = 0, this.physicalScore = 0,
    this.mentalScore = 0, this.socialScore = 0, this.consistencyScore = 0,
  });

  factory WellnessScores.fromJson(Map<String, dynamic> json) => WellnessScores(
        overallScore: json['overallScore'] as int? ?? 0,
        physicalScore: json['physicalScore'] as int? ?? 0,
        mentalScore: json['mentalScore'] as int? ?? 0,
        socialScore: json['socialScore'] as int? ?? 0,
        consistencyScore: json['consistencyScore'] as int? ?? 0,
      );
}

class TrendSnapshot {
  final String userSub;
  final DateTime date;
  final String period;
  final BiometricSummary biometrics;
  final BehavioralSummary behavioral;
  final WellnessScores wellness;
  final bool ringSource;
  final bool appSource;
  final bool portalSource;

  const TrendSnapshot({
    required this.userSub, required this.date, this.period = 'daily',
    this.biometrics = const BiometricSummary(),
    this.behavioral = const BehavioralSummary(),
    this.wellness = const WellnessScores(),
    this.ringSource = false, this.appSource = false, this.portalSource = false,
  });

  factory TrendSnapshot.fromJson(Map<String, dynamic> json) => TrendSnapshot(
        userSub: json['userSub'] as String? ?? '',
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        period: json['period'] as String? ?? 'daily',
        biometrics: json['biometrics'] != null
            ? BiometricSummary.fromJson(json['biometrics'] as Map<String, dynamic>)
            : const BiometricSummary(),
        behavioral: json['behavioral'] != null
            ? BehavioralSummary.fromJson(json['behavioral'] as Map<String, dynamic>)
            : const BehavioralSummary(),
        wellness: json['wellness'] != null
            ? WellnessScores.fromJson(json['wellness'] as Map<String, dynamic>)
            : const WellnessScores(),
        ringSource: (json['sources'] as Map<String, dynamic>?)?['ring'] as bool? ?? false,
        appSource: (json['sources'] as Map<String, dynamic>?)?['app'] as bool? ?? false,
        portalSource: (json['sources'] as Map<String, dynamic>?)?['portal'] as bool? ?? false,
      );

  int get sourceCount => [ringSource, appSource, portalSource].where((s) => s).length;
}

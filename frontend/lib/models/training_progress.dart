// MUUD Health — Training Progress Model (MUUD Academy)
// © Muud Health — Armin Hoes, MD

enum TrainingStatus { enrolled, inProgress, completed, certified }

class TrainingProgress {
  final String id;
  final String traineeSub;
  final String cohortId;
  final String programType; // MFP, CE, K12, CoachCapacity
  final List<String> completedModules;
  final int totalModules;
  final double supervisedHours;
  final TrainingStatus status;
  final DateTime? enrolledAt;
  final DateTime? certifiedAt;

  const TrainingProgress({
    required this.id,
    required this.traineeSub,
    required this.cohortId,
    this.programType = 'MFP',
    this.completedModules = const [],
    this.totalModules = 0,
    this.supervisedHours = 0.0,
    this.status = TrainingStatus.enrolled,
    this.enrolledAt,
    this.certifiedAt,
  });

  factory TrainingProgress.fromJson(Map<String, dynamic> json) {
    return TrainingProgress(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      traineeSub: json['traineeSub'] as String? ?? '',
      cohortId: json['cohortId'] as String? ?? '',
      programType: json['programType'] as String? ?? 'MFP',
      completedModules: (json['completedModules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      totalModules: json['totalModules'] as int? ?? 0,
      supervisedHours: (json['supervisedHours'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status'] as String?),
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.tryParse(json['enrolledAt'].toString())
          : null,
      certifiedAt: json['certifiedAt'] != null
          ? DateTime.tryParse(json['certifiedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'traineeSub': traineeSub,
    'cohortId': cohortId,
    'programType': programType,
    'completedModules': completedModules,
    'totalModules': totalModules,
    'supervisedHours': supervisedHours,
    'status': status.name,
    if (enrolledAt != null) 'enrolledAt': enrolledAt!.toIso8601String(),
    if (certifiedAt != null) 'certifiedAt': certifiedAt!.toIso8601String(),
  };

  double get progressPercent =>
      totalModules > 0 ? completedModules.length / totalModules : 0.0;

  TrainingProgress copyWith({
    String? id, String? traineeSub, String? cohortId, String? programType,
    List<String>? completedModules, int? totalModules, double? supervisedHours,
    TrainingStatus? status, DateTime? enrolledAt, DateTime? certifiedAt,
  }) {
    return TrainingProgress(
      id: id ?? this.id, traineeSub: traineeSub ?? this.traineeSub,
      cohortId: cohortId ?? this.cohortId, programType: programType ?? this.programType,
      completedModules: completedModules ?? this.completedModules,
      totalModules: totalModules ?? this.totalModules,
      supervisedHours: supervisedHours ?? this.supervisedHours,
      status: status ?? this.status, enrolledAt: enrolledAt ?? this.enrolledAt,
      certifiedAt: certifiedAt ?? this.certifiedAt,
    );
  }

  static TrainingStatus _parseStatus(String? value) {
    switch (value) {
      case 'in_progress':
      case 'inProgress':
        return TrainingStatus.inProgress;
      case 'completed':
        return TrainingStatus.completed;
      case 'certified':
        return TrainingStatus.certified;
      default:
        return TrainingStatus.enrolled;
    }
  }

  @override
  String toString() => 'TrainingProgress($programType, ${status.name}, ${(progressPercent * 100).toInt()}%)';
}

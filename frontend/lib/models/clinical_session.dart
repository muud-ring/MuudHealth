// MUUD Health — Clinical Session Model (MUUD Clinic)
// © Muud Health — Armin Hoes, MD

enum SessionType { psychiatry, therapy, coaching }

enum SessionStatus { scheduled, completed, cancelled }

class ClinicalSession {
  final String id;
  final String patientSub;
  final String providerSub;
  final SessionType sessionType;
  final SessionStatus status;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final String? notes;

  const ClinicalSession({
    required this.id,
    required this.patientSub,
    required this.providerSub,
    this.sessionType = SessionType.psychiatry,
    this.status = SessionStatus.scheduled,
    this.scheduledAt,
    this.completedAt,
    this.notes,
  });

  factory ClinicalSession.fromJson(Map<String, dynamic> json) {
    return ClinicalSession(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      patientSub: json['patientSub'] as String? ?? '',
      providerSub: json['providerSub'] as String? ?? '',
      sessionType: _parseSessionType(json['sessionType'] as String?),
      status: _parseStatus(json['status'] as String?),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientSub': patientSub,
    'providerSub': providerSub,
    'sessionType': sessionType.name,
    'status': status.name,
    if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    if (notes != null) 'notes': notes,
  };

  ClinicalSession copyWith({
    String? id, String? patientSub, String? providerSub,
    SessionType? sessionType, SessionStatus? status,
    DateTime? scheduledAt, DateTime? completedAt, String? notes,
  }) {
    return ClinicalSession(
      id: id ?? this.id, patientSub: patientSub ?? this.patientSub,
      providerSub: providerSub ?? this.providerSub,
      sessionType: sessionType ?? this.sessionType, status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt, notes: notes ?? this.notes,
    );
  }

  static SessionType _parseSessionType(String? value) {
    if (value == null) return SessionType.psychiatry;
    return SessionType.values.firstWhere((t) => t.name == value, orElse: () => SessionType.psychiatry);
  }

  static SessionStatus _parseStatus(String? value) {
    if (value == null) return SessionStatus.scheduled;
    return SessionStatus.values.firstWhere((s) => s.name == value, orElse: () => SessionStatus.scheduled);
  }

  @override
  String toString() => 'ClinicalSession($id, ${sessionType.name}, ${status.name})';
}

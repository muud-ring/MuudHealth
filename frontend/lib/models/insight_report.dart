// MUUD Health — Insight Report Model (MUUD Mirror AI output)
// © Muud Health — Armin Hoes, MD

enum ReportType { weekly, monthly, quarterly }

class InsightReport {
  final String id;
  final String userSub;
  final ReportType reportType;
  final String period; // e.g. "2026-W15", "2026-04", "2026-Q1"
  final String summary;
  final Map<String, dynamic> metrics;
  final List<String> recommendations;
  final DateTime? generatedAt;

  const InsightReport({
    required this.id,
    required this.userSub,
    this.reportType = ReportType.weekly,
    this.period = '',
    this.summary = '',
    this.metrics = const {},
    this.recommendations = const [],
    this.generatedAt,
  });

  factory InsightReport.fromJson(Map<String, dynamic> json) {
    return InsightReport(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userSub: json['userSub'] as String? ?? '',
      reportType: _parseType(json['reportType'] as String?),
      period: json['period'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      metrics: json['metrics'] as Map<String, dynamic>? ?? {},
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userSub': userSub,
    'reportType': reportType.name,
    'period': period,
    'summary': summary,
    'metrics': metrics,
    'recommendations': recommendations,
    if (generatedAt != null) 'generatedAt': generatedAt!.toIso8601String(),
  };

  InsightReport copyWith({
    String? id, String? userSub, ReportType? reportType,
    String? period, String? summary, Map<String, dynamic>? metrics,
    List<String>? recommendations, DateTime? generatedAt,
  }) {
    return InsightReport(
      id: id ?? this.id, userSub: userSub ?? this.userSub,
      reportType: reportType ?? this.reportType, period: period ?? this.period,
      summary: summary ?? this.summary, metrics: metrics ?? this.metrics,
      recommendations: recommendations ?? this.recommendations,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  static ReportType _parseType(String? value) {
    if (value == null) return ReportType.weekly;
    return ReportType.values.firstWhere((t) => t.name == value, orElse: () => ReportType.weekly);
  }

  @override
  String toString() => 'InsightReport(${reportType.name}: $period)';
}

// Muud Health — Service Plan Model
// © Muud Health — Armin Hoes, MD

enum PlanCategory { clinic, academy, coaching, content }

enum ClinicPlanType { PMF, TMF, CMF, general }

enum PlanFrequency { weekly, biweekly, monthly, onDemand, program }

class ServicePlan {
  final String id;
  final String ownerSub;
  final PlanCategory category;
  final ClinicPlanType planType;
  final PlanFrequency frequency;
  final int sessionDuration;
  final String status;
  final int impliedTier;
  final String? summary;
  final DateTime? startDate;
  final DateTime? endDate;

  const ServicePlan({
    required this.id,
    required this.ownerSub,
    this.category = PlanCategory.content,
    this.planType = ClinicPlanType.general,
    this.frequency = PlanFrequency.monthly,
    this.sessionDuration = 0,
    this.status = 'pending',
    this.impliedTier = 5,
    this.summary,
    this.startDate,
    this.endDate,
  });

  factory ServicePlan.fromJson(Map<String, dynamic> json) {
    final planData = json['plan'] as Map<String, dynamic>? ?? json;
    return ServicePlan(
      id: planData['_id'] as String? ?? '',
      ownerSub: planData['ownerSub'] as String? ?? '',
      category: _parseCategory(planData['category'] as String?),
      planType: _parsePlanType(planData['planType'] as String?),
      frequency: _parseFrequency(planData['frequency'] as String?),
      sessionDuration: planData['sessionDuration'] as int? ?? 0,
      status: planData['status'] as String? ?? 'pending',
      impliedTier: planData['impliedTier'] as int? ?? 5,
      summary: json['summary'] as String?,
      startDate: planData['startDate'] != null ? DateTime.tryParse(planData['startDate'].toString()) : null,
      endDate: planData['endDate'] != null ? DateTime.tryParse(planData['endDate'].toString()) : null,
    );
  }

  bool get isActive => status == 'active' && (endDate == null || endDate!.isAfter(DateTime.now()));

  String get displayName {
    switch (category) {
      case PlanCategory.clinic:
        return '${planType.name} (${sessionDuration}min ${frequency.name})';
      case PlanCategory.academy:
        return 'Muud Academy Program';
      case PlanCategory.coaching:
        return 'Wellness Coaching (${frequency.name})';
      case PlanCategory.content:
        return 'Premium Content Subscription';
    }
  }

  static PlanCategory _parseCategory(String? v) {
    switch (v) {
      case 'clinic': return PlanCategory.clinic;
      case 'academy': return PlanCategory.academy;
      case 'coaching': return PlanCategory.coaching;
      default: return PlanCategory.content;
    }
  }

  static ClinicPlanType _parsePlanType(String? v) {
    switch (v) {
      case 'PMF': return ClinicPlanType.PMF;
      case 'TMF': return ClinicPlanType.TMF;
      case 'CMF': return ClinicPlanType.CMF;
      default: return ClinicPlanType.general;
    }
  }

  static PlanFrequency _parseFrequency(String? v) {
    switch (v) {
      case 'weekly': return PlanFrequency.weekly;
      case 'biweekly': return PlanFrequency.biweekly;
      case 'monthly': return PlanFrequency.monthly;
      case 'on_demand': return PlanFrequency.onDemand;
      case 'program': return PlanFrequency.program;
      default: return PlanFrequency.monthly;
    }
  }
}

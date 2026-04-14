// Muud Health — Organization Model
// © Muud Health — Armin Hoes, MD

enum OrgSize { large, mid, small, starter }

enum OrgNeed { triad, dualMobile, dualWeb, solo }

class OrgMember {
  final String sub;
  final String role;
  final DateTime? joinedAt;

  const OrgMember({required this.sub, this.role = 'member', this.joinedAt});

  factory OrgMember.fromJson(Map<String, dynamic> json) => OrgMember(
        sub: json['sub'] as String? ?? '',
        role: json['role'] as String? ?? 'member',
        joinedAt: json['joinedAt'] != null ? DateTime.tryParse(json['joinedAt'].toString()) : null,
      );
}

class Organization {
  final String id;
  final String name;
  final String slug;
  final OrgSize size;
  final OrgNeed need;
  final int tier;
  final int totalLicenses;
  final int usedLicenses;
  final List<OrgMember> members;
  final String status;

  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    this.size = OrgSize.starter,
    this.need = OrgNeed.solo,
    this.tier = 5,
    this.totalLicenses = 10,
    this.usedLicenses = 0,
    this.members = const [],
    this.status = 'active',
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    final orgData = json['organization'] as Map<String, dynamic>? ?? json;
    final licenses = orgData['licenses'] as Map<String, dynamic>? ?? {};

    return Organization(
      id: orgData['_id'] as String? ?? '',
      name: orgData['name'] as String? ?? '',
      slug: orgData['slug'] as String? ?? '',
      size: _parseSize(orgData['size'] as String?),
      need: _parseNeed(orgData['need'] as String?),
      tier: orgData['tier'] as int? ?? 5,
      totalLicenses: licenses['total'] as int? ?? 10,
      usedLicenses: licenses['used'] as int? ?? 0,
      members: (orgData['members'] as List<dynamic>?)
              ?.map((m) => OrgMember.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      status: orgData['status'] as String? ?? 'active',
    );
  }

  int get remainingLicenses => totalLicenses - usedLicenses;

  static OrgSize _parseSize(String? v) {
    switch (v) {
      case 'large': return OrgSize.large;
      case 'mid': return OrgSize.mid;
      case 'small': return OrgSize.small;
      default: return OrgSize.starter;
    }
  }

  static OrgNeed _parseNeed(String? v) {
    switch (v) {
      case 'triad': return OrgNeed.triad;
      case 'dual_mobile': return OrgNeed.dualMobile;
      case 'dual_web': return OrgNeed.dualWeb;
      default: return OrgNeed.solo;
    }
  }
}

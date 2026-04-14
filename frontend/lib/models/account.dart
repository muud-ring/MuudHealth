// Muud Health — Account Model (Unified I/O/S Tier System)
// © Muud Health — Armin Hoes, MD

/// Account types in the Muud ecosystem.
enum AccountType { individual, organizational, superadmin }

/// Platform access flags.
class PlatformAccess {
  final bool app;
  final bool portal;
  final bool ring;

  const PlatformAccess({this.app = true, this.portal = false, this.ring = false});

  factory PlatformAccess.fromJson(Map<String, dynamic> json) => PlatformAccess(
        app: json['app'] as bool? ?? true,
        portal: json['portal'] as bool? ?? false,
        ring: json['ring'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {'app': app, 'portal': portal, 'ring': ring};
}

/// Data ownership configuration.
class DataOwnership {
  final String type; // 'individual' | 'organizational' | 'administrative'
  final String? owningOrganizationId;

  const DataOwnership({this.type = 'individual', this.owningOrganizationId});

  factory DataOwnership.fromJson(Map<String, dynamic> json) => DataOwnership(
        type: json['type'] as String? ?? 'individual',
        owningOrganizationId: json['owningOrganizationId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        if (owningOrganizationId != null) 'owningOrganizationId': owningOrganizationId,
      };
}

/// Unified Muud Account — represents the one-account solution across
/// Individual (I), Organizational (O), and Superadmin (S) account types.
class Account {
  final String id;
  final String ownerSub;
  final AccountType accountType;
  final int tier; // 1 = highest, 5 = lowest (3 max for S)
  final PlatformAccess platforms;
  final DataOwnership dataOwnership;
  final String status;
  final int privilegeLevel; // 0–100
  final List<String> entitlements;
  final DateTime? activatedAt;
  final DateTime? lastTierRecalculation;

  const Account({
    required this.id,
    required this.ownerSub,
    this.accountType = AccountType.individual,
    this.tier = 5,
    this.platforms = const PlatformAccess(),
    this.dataOwnership = const DataOwnership(),
    this.status = 'active',
    this.privilegeLevel = 20,
    this.entitlements = const [],
    this.activatedAt,
    this.lastTierRecalculation,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    final accountData = json['account'] as Map<String, dynamic>? ?? json;

    return Account(
      id: accountData['_id'] as String? ?? '',
      ownerSub: accountData['ownerSub'] as String? ?? '',
      accountType: _parseAccountType(accountData['accountType'] as String?),
      tier: accountData['tier'] as int? ?? 5,
      platforms: accountData['platforms'] != null
          ? PlatformAccess.fromJson(accountData['platforms'] as Map<String, dynamic>)
          : const PlatformAccess(),
      dataOwnership: accountData['dataOwnership'] != null
          ? DataOwnership.fromJson(accountData['dataOwnership'] as Map<String, dynamic>)
          : const DataOwnership(),
      status: accountData['status'] as String? ?? 'active',
      privilegeLevel: json['privilegeLevel'] as int? ?? 20,
      entitlements: (json['entitlements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      activatedAt: _parseDate(accountData['activatedAt']),
      lastTierRecalculation: _parseDate(accountData['lastTierRecalculation']),
    );
  }

  /// Whether this account is entitled to a specific feature.
  bool hasEntitlement(String feature) => entitlements.contains(feature);

  /// Whether this account has access to a platform.
  bool hasPlatform(String platform) {
    switch (platform) {
      case 'app':
        return platforms.app;
      case 'portal':
        return platforms.portal;
      case 'ring':
        return platforms.ring;
      default:
        return false;
    }
  }

  /// Human-readable tier label.
  String get tierLabel {
    switch (accountType) {
      case AccountType.individual:
        return 'Individual Tier $tier';
      case AccountType.organizational:
        return 'Enterprise Tier $tier';
      case AccountType.superadmin:
        return 'Superadmin S$tier';
    }
  }

  /// Whether this is a premium (paid) account.
  bool get isPremium => tier <= 4 && accountType != AccountType.superadmin;

  /// Whether this account has clinic access.
  bool get hasClinicAccess => tier <= 3 && accountType == AccountType.individual;

  static AccountType _parseAccountType(String? value) {
    switch (value) {
      case 'I':
        return AccountType.individual;
      case 'O':
        return AccountType.organizational;
      case 'S':
        return AccountType.superadmin;
      default:
        return AccountType.individual;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() => 'Account($ownerSub, ${accountType.name}, T$tier)';
}

// MUUD Health — UserProfile Model
// © Muud Health — Armin Hoes, MD

enum UserRole { patient, clinician, coach, educator, admin }

class UserProfile {
  final String sub;
  final String name;
  final String username;
  final String bio;
  final String location;
  final String phone;
  final String avatarKey;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.sub,
    this.name = '',
    this.username = '',
    this.bio = '',
    this.location = '',
    this.phone = '',
    this.avatarKey = '',
    this.role = UserRole.patient,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      sub: json['sub'] as String? ?? '',
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      location: json['location'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarKey: json['avatarKey'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'sub': sub,
    'name': name,
    'username': username,
    'bio': bio,
    'location': location,
    'phone': phone,
    'avatarKey': avatarKey,
    'role': role.name,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  UserProfile copyWith({
    String? sub,
    String? name,
    String? username,
    String? bio,
    String? location,
    String? phone,
    String? avatarKey,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      sub: sub ?? this.sub,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      avatarKey: avatarKey ?? this.avatarKey,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static UserRole _parseRole(String? value) {
    if (value == null) return UserRole.patient;
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.patient,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() => 'UserProfile(sub: $sub, name: $name, role: ${role.name})';
}

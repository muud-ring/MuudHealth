// MUUD Health — Connection & FriendRequest Models
// © Muud Health — Armin Hoes, MD

enum ConnectionTier { innerCircle, close, standard }

class Connection {
  final String id;
  final String userSub;
  final String connectedSub;
  final ConnectionTier tier;
  final DateTime? createdAt;

  // Hydrated fields (populated by backend joins)
  final String? name;
  final String? username;
  final String? avatarKey;

  const Connection({
    required this.id,
    required this.userSub,
    required this.connectedSub,
    this.tier = ConnectionTier.standard,
    this.createdAt,
    this.name,
    this.username,
    this.avatarKey,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userSub: json['userSub'] as String? ?? '',
      connectedSub: json['connectedSub'] as String? ?? '',
      tier: _parseTier(json['tier'] as String?),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      name: json['name'] as String?,
      username: json['username'] as String?,
      avatarKey: json['avatarKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userSub': userSub,
    'connectedSub': connectedSub,
    'tier': tier.name,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  Connection copyWith({
    String? id,
    String? userSub,
    String? connectedSub,
    ConnectionTier? tier,
    DateTime? createdAt,
    String? name,
    String? username,
    String? avatarKey,
  }) {
    return Connection(
      id: id ?? this.id,
      userSub: userSub ?? this.userSub,
      connectedSub: connectedSub ?? this.connectedSub,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarKey: avatarKey ?? this.avatarKey,
    );
  }

  static ConnectionTier _parseTier(String? value) {
    switch (value) {
      case 'inner_circle':
      case 'innerCircle':
        return ConnectionTier.innerCircle;
      case 'close':
        return ConnectionTier.close;
      default:
        return ConnectionTier.standard;
    }
  }

  @override
  String toString() => 'Connection($connectedSub, tier: ${tier.name})';
}

enum FriendRequestStatus { pending, accepted, declined }

class FriendRequest {
  final String id;
  final String fromSub;
  final String toSub;
  final FriendRequestStatus status;
  final DateTime? createdAt;

  // Hydrated
  final String? fromName;
  final String? fromUsername;
  final String? fromAvatarKey;

  const FriendRequest({
    required this.id,
    required this.fromSub,
    required this.toSub,
    this.status = FriendRequestStatus.pending,
    this.createdAt,
    this.fromName,
    this.fromUsername,
    this.fromAvatarKey,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      fromSub: json['fromSub'] as String? ?? '',
      toSub: json['toSub'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      fromName: json['fromName'] as String?,
      fromUsername: json['fromUsername'] as String?,
      fromAvatarKey: json['fromAvatarKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromSub': fromSub,
    'toSub': toSub,
    'status': status.name,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  FriendRequest copyWith({
    String? id,
    String? fromSub,
    String? toSub,
    FriendRequestStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromSub: fromSub ?? this.fromSub,
      toSub: toSub ?? this.toSub,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static FriendRequestStatus _parseStatus(String? value) {
    if (value == null) return FriendRequestStatus.pending;
    return FriendRequestStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => FriendRequestStatus.pending,
    );
  }

  @override
  String toString() => 'FriendRequest($fromSub → $toSub, ${status.name})';
}

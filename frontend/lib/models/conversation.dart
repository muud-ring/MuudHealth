// MUUD Health — Conversation & Message Models
// © Muud Health — Armin Hoes, MD

class Conversation {
  final String id;
  final List<String> members;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  // Hydrated
  final String? otherName;
  final String? otherAvatarKey;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.members,
    this.lastMessage,
    this.lastMessageAt,
    this.createdAt,
    this.otherName,
    this.otherAvatarKey,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      members: (json['members'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      otherName: json['otherName'] as String?,
      otherAvatarKey: json['otherAvatarKey'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'members': members,
    if (lastMessage != null) 'lastMessage': lastMessage,
    if (lastMessageAt != null) 'lastMessageAt': lastMessageAt!.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  Conversation copyWith({
    String? id,
    List<String>? members,
    String? lastMessage,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    String? otherName,
    String? otherAvatarKey,
    int? unreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      otherName: otherName ?? this.otherName,
      otherAvatarKey: otherAvatarKey ?? this.otherAvatarKey,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  String toString() => 'Conversation($id, members: ${members.length})';
}

class Message {
  final String id;
  final String conversationId;
  final String senderSub;
  final String body;
  final String? mediaUrl;
  final List<String> readBy;
  final DateTime? createdAt;

  // Hydrated
  final String? senderName;
  final String? senderAvatarKey;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderSub,
    required this.body,
    this.mediaUrl,
    this.readBy = const [],
    this.createdAt,
    this.senderName,
    this.senderAvatarKey,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      senderSub: json['senderSub'] as String? ?? '',
      body: json['body'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String?,
      readBy: (json['readBy'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      senderName: json['senderName'] as String?,
      senderAvatarKey: json['senderAvatarKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'senderSub': senderSub,
    'body': body,
    if (mediaUrl != null) 'mediaUrl': mediaUrl,
    'readBy': readBy,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderSub,
    String? body,
    String? mediaUrl,
    List<String>? readBy,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderSub: senderSub ?? this.senderSub,
      body: body ?? this.body,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      readBy: readBy ?? this.readBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'Message($id, from: $senderSub)';
}

// MUUD Health — Post Model (Journal entries, notes, reflections)
// © Muud Health — Armin Hoes, MD

enum PostType { journal, note, reflection, media }

enum PostVisibility { private_, connections, public_ }

class Post {
  final String id;
  final String authorSub;
  final PostType type;
  final String title;
  final String body;
  final List<String> mediaUrls;
  final List<String> tags;
  final PostVisibility visibility;
  final Map<String, int> reactions; // MUUD Notes 12-emoji system
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Hydrated
  final String? authorName;
  final String? authorAvatarKey;

  const Post({
    required this.id,
    required this.authorSub,
    this.type = PostType.journal,
    this.title = '',
    this.body = '',
    this.mediaUrls = const [],
    this.tags = const [],
    this.visibility = PostVisibility.private_,
    this.reactions = const {},
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorAvatarKey,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      authorSub: json['authorSub'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      visibility: _parseVisibility(json['visibility'] as String?),
      reactions: (json['reactions'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      authorName: json['authorName'] as String?,
      authorAvatarKey: json['authorAvatarKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorSub': authorSub,
    'type': type.name,
    'title': title,
    'body': body,
    'mediaUrls': mediaUrls,
    'tags': tags,
    'visibility': _visibilityToString(visibility),
    'reactions': reactions,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  Post copyWith({
    String? id,
    String? authorSub,
    PostType? type,
    String? title,
    String? body,
    List<String>? mediaUrls,
    List<String>? tags,
    PostVisibility? visibility,
    Map<String, int>? reactions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      authorSub: authorSub ?? this.authorSub,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      reactions: reactions ?? this.reactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalReactions => reactions.values.fold(0, (a, b) => a + b);

  static PostType _parseType(String? value) {
    if (value == null) return PostType.journal;
    return PostType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => PostType.journal,
    );
  }

  static PostVisibility _parseVisibility(String? value) {
    switch (value) {
      case 'private':
        return PostVisibility.private_;
      case 'connections':
        return PostVisibility.connections;
      case 'public':
        return PostVisibility.public_;
      default:
        return PostVisibility.private_;
    }
  }

  static String _visibilityToString(PostVisibility v) {
    switch (v) {
      case PostVisibility.private_:
        return 'private';
      case PostVisibility.connections:
        return 'connections';
      case PostVisibility.public_:
        return 'public';
    }
  }

  @override
  String toString() => 'Post($id, ${type.name}: $title)';
}

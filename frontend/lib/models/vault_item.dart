// MUUD Health — Vault Models
// © Muud Health — Armin Hoes, MD

class VaultItem {
  final String id;
  final String ownerSub;
  final String sourceType; // post, message, link, file
  final String? sourceId;
  final String? title;
  final String? preview;
  final List<String> tags;
  final String category;
  final DateTime? savedAt;

  const VaultItem({
    required this.id,
    required this.ownerSub,
    this.sourceType = 'post',
    this.sourceId,
    this.title,
    this.preview,
    this.tags = const [],
    this.category = 'general',
    this.savedAt,
  });

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      ownerSub: json['ownerSub'] as String? ?? '',
      sourceType: json['sourceType'] as String? ?? 'post',
      sourceId: json['sourceId'] as String?,
      title: json['title'] as String?,
      preview: json['preview'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      category: json['category'] as String? ?? 'general',
      savedAt: json['savedAt'] != null ? DateTime.tryParse(json['savedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ownerSub': ownerSub,
    'sourceType': sourceType,
    if (sourceId != null) 'sourceId': sourceId,
    if (title != null) 'title': title,
    if (preview != null) 'preview': preview,
    'tags': tags,
    'category': category,
    if (savedAt != null) 'savedAt': savedAt!.toIso8601String(),
  };

  VaultItem copyWith({
    String? id, String? ownerSub, String? sourceType, String? sourceId,
    String? title, String? preview, List<String>? tags, String? category,
    DateTime? savedAt,
  }) {
    return VaultItem(
      id: id ?? this.id, ownerSub: ownerSub ?? this.ownerSub,
      sourceType: sourceType ?? this.sourceType, sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title, preview: preview ?? this.preview,
      tags: tags ?? this.tags, category: category ?? this.category,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  String toString() => 'VaultItem($id, $sourceType: $title)';
}

class VaultTag {
  final String id;
  final String ownerSub;
  final String name;
  final String color;
  final int count;

  const VaultTag({
    required this.id,
    required this.ownerSub,
    required this.name,
    this.color = '#5B288E',
    this.count = 0,
  });

  factory VaultTag.fromJson(Map<String, dynamic> json) {
    return VaultTag(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      ownerSub: json['ownerSub'] as String? ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#5B288E',
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'ownerSub': ownerSub, 'name': name, 'color': color, 'count': count,
  };

  @override
  String toString() => 'VaultTag($name, count: $count)';
}

class ConversationItem {
  final String otherSub;
  final String name;
  final String username;
  final String avatarUrl;
  final String lastMessage;
  final DateTime? lastAt;

  const ConversationItem({
    required this.otherSub,
    required this.name,
    required this.username,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastAt,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    final otherSub = (json['otherSub'] ?? '').toString();

    final otherUser = (json['otherUser'] is Map)
        ? (json['otherUser'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final name = (otherUser['name'] ?? otherSub).toString();
    final username = (otherUser['username'] ?? '').toString();
    final avatarUrl = (otherUser['avatarUrl'] ?? '').toString();

    final lastMessage = (json['lastMessage'] ?? '').toString();

    DateTime? lastAt;
    final rawLastAt = json['lastAt'];
    if (rawLastAt != null) {
      try {
        lastAt = DateTime.parse(rawLastAt.toString());
      } catch (_) {}
    }

    return ConversationItem(
      otherSub: otherSub,
      name: name,
      username: username,
      avatarUrl: avatarUrl,
      lastMessage: lastMessage,
      lastAt: lastAt,
    );
  }
}

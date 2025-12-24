class Person {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl; // can be empty for now
  final String location;
  final String lastActive; // e.g. "3 days ago"
  final String moodChip; // e.g. "Sad", "Intermediate"

  // UI-only color key (simple): "purple" "orange" "green" "blue" "pink" "yellow" "grey"
  final String tint;

  const Person({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.location,
    required this.lastActive,
    required this.moodChip,
    required this.tint,
  });
}

class ConnectionRequest {
  final String id;
  final Person person;

  const ConnectionRequest({required this.id, required this.person});
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final String time; // e.g. "12m"

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
  });
}

import 'package:flutter/material.dart';

class InnerCircleMember {
  final String name;
  final String avatarUrl; // can be empty for placeholder
  final Color ringColor;

  const InnerCircleMember({
    required this.name,
    required this.avatarUrl,
    required this.ringColor,
  });
}

class ConnectionItem {
  final String name;
  final String lastSeen; // e.g. "3 days ago"
  final String moodLabel; // e.g. "Sad"
  final Color cardColor; // pastel background
  final Color moodBorderColor; // chip border

  final String avatarUrl;

  const ConnectionItem({
    required this.name,
    required this.lastSeen,
    required this.moodLabel,
    required this.cardColor,
    required this.moodBorderColor,
    required this.avatarUrl,
  });
}

class SuggestedFriend {
  final String name;
  final String handle; // e.g. "@james"
  final String avatarUrl;
  final Color ringColor;

  const SuggestedFriend({
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.ringColor,
  });
}

// MUUD Health — MUUD Notes Reaction System
// 12-emoji fidget dial mapped to Ring interaction (patented)
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The 12 MUUD Note emotions mapped to the Ring fidget dial.
/// Each position on the dial corresponds to one emotional state.
/// Users rotate the Ring to select their current mood — this maps
/// directly to the SCA (Detect) entry point of the product loop.
enum MuudEmotion {
  joy,
  love,
  calm,
  hope,
  grit,
  focus,
  sad,
  anxious,
  angry,
  tired,
  lonely,
  unsure,
}

class MuudNoteReaction {
  MuudNoteReaction._();

  /// Emoji for each emotion
  static const Map<MuudEmotion, String> emojis = {
    MuudEmotion.joy: '\u{1F60A}',       // 😊
    MuudEmotion.love: '\u{2764}\u{FE0F}', // ❤️
    MuudEmotion.calm: '\u{1F60C}',       // 😌
    MuudEmotion.hope: '\u{1F31F}',       // 🌟
    MuudEmotion.grit: '\u{1F4AA}',       // 💪
    MuudEmotion.focus: '\u{1F3AF}',      // 🎯
    MuudEmotion.sad: '\u{1F622}',        // 😢
    MuudEmotion.anxious: '\u{1F630}',    // 😰
    MuudEmotion.angry: '\u{1F624}',      // 😤
    MuudEmotion.tired: '\u{1F634}',      // 😴
    MuudEmotion.lonely: '\u{1F97A}',     // 🥺
    MuudEmotion.unsure: '\u{1F914}',     // 🤔
  };

  /// Human-readable labels
  static const Map<MuudEmotion, String> labels = {
    MuudEmotion.joy: 'Joy',
    MuudEmotion.love: 'Love',
    MuudEmotion.calm: 'Calm',
    MuudEmotion.hope: 'Hope',
    MuudEmotion.grit: 'Grit',
    MuudEmotion.focus: 'Focus',
    MuudEmotion.sad: 'Sad',
    MuudEmotion.anxious: 'Anxious',
    MuudEmotion.angry: 'Angry',
    MuudEmotion.tired: 'Tired',
    MuudEmotion.lonely: 'Lonely',
    MuudEmotion.unsure: 'Unsure',
  };

  /// Color mapped to each emotion (from PDS 2.0)
  static const Map<MuudEmotion, Color> colors = {
    MuudEmotion.joy: MuudColors.noteJoy,
    MuudEmotion.love: MuudColors.noteLove,
    MuudEmotion.calm: MuudColors.noteCalm,
    MuudEmotion.hope: MuudColors.noteHope,
    MuudEmotion.grit: MuudColors.noteGrit,
    MuudEmotion.focus: MuudColors.noteFocus,
    MuudEmotion.sad: MuudColors.noteSad,
    MuudEmotion.anxious: MuudColors.noteAnxious,
    MuudEmotion.angry: MuudColors.noteAngry,
    MuudEmotion.tired: MuudColors.noteTired,
    MuudEmotion.lonely: MuudColors.noteLonely,
    MuudEmotion.unsure: MuudColors.noteUnsure,
  };

  /// Positive emotions (top half of dial)
  static const List<MuudEmotion> positiveEmotions = [
    MuudEmotion.joy,
    MuudEmotion.love,
    MuudEmotion.calm,
    MuudEmotion.hope,
    MuudEmotion.grit,
    MuudEmotion.focus,
  ];

  /// Difficult emotions (bottom half of dial)
  static const List<MuudEmotion> difficultEmotions = [
    MuudEmotion.sad,
    MuudEmotion.anxious,
    MuudEmotion.angry,
    MuudEmotion.tired,
    MuudEmotion.lonely,
    MuudEmotion.unsure,
  ];

  /// Get all reactions as list of entries
  static List<MuudEmotionEntry> get all {
    return MuudEmotion.values
        .map((e) => MuudEmotionEntry(
              emotion: e,
              emoji: emojis[e]!,
              label: labels[e]!,
              color: colors[e]!,
            ))
        .toList();
  }

  /// Get emoji string for a named emotion (for JSON mapping)
  static String emojiForName(String name) {
    final emotion = MuudEmotion.values.firstWhere(
      (e) => e.name == name,
      orElse: () => MuudEmotion.unsure,
    );
    return emojis[emotion]!;
  }

  /// Get color for a named emotion
  static Color colorForName(String name) {
    final emotion = MuudEmotion.values.firstWhere(
      (e) => e.name == name,
      orElse: () => MuudEmotion.unsure,
    );
    return colors[emotion]!;
  }

  /// Ring dial position (0-11, clockwise from top)
  static int dialPosition(MuudEmotion emotion) {
    return MuudEmotion.values.indexOf(emotion);
  }
}

/// Convenience class for rendering emotion entries
class MuudEmotionEntry {
  final MuudEmotion emotion;
  final String emoji;
  final String label;
  final Color color;

  const MuudEmotionEntry({
    required this.emotion,
    required this.emoji,
    required this.label,
    required this.color,
  });
}

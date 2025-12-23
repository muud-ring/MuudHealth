import 'package:flutter/material.dart';
import '../models/people_models.dart';

class ConnectionCard extends StatelessWidget {
  final ConnectionItem item;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;

  const ConnectionCard({
    super.key,
    required this.item,
    this.onTap,
    this.onMenu,
  });

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: item.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _Avatar(ringColor: kPurple, url: item.avatarUrl),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: kPurple,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.lastSeen,
                    style: const TextStyle(
                      color: kGreyText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MoodChip(
                    label: item.moodLabel,
                    borderColor: item.moodBorderColor,
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: onMenu,
              icon: const Icon(Icons.more_vert, color: kPurple),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final Color borderColor;

  const _MoodChip({required this.label, required this.borderColor});

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.2),
        color: Colors.white.withOpacity(0.45),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: kPurple,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Color ringColor;
  final String url;

  const _Avatar({required this.ringColor, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2.5),
      ),
      child: ClipOval(
        child: url.isEmpty
            ? Container(
                color: const Color(0xFFEFEFEF),
                child: const Icon(Icons.person, color: Color(0xFFBDBDBD)),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEFEFEF),
                  child: const Icon(Icons.person, color: Color(0xFFBDBDBD)),
                ),
              ),
      ),
    );
  }
}

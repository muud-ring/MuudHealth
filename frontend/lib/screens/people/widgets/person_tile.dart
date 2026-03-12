import 'package:flutter/material.dart';
import '../data/people_models.dart';

class PersonTile extends StatelessWidget {
  final Person person;
  final VoidCallback? onTap;
  final VoidCallback? onTapMenu;

  const PersonTile({
    super.key,
    required this.person,
    this.onTap,
    this.onTapMenu,
  });

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  Color _bgForTint(String tint) {
    switch (tint) {
      case "purple":
        return const Color(0xFFE9DCFF);
      case "orange":
        return const Color(0xFFFFE3D7);
      case "green":
        return const Color(0xFFDFF5E2);
      case "blue":
        return const Color(0xFFDFE7FF);
      case "pink":
        return const Color(0xFFFFDDEA);
      case "yellow":
        return const Color(0xFFFFF0C9);
      default:
        return const Color(0xFFF3F3F3);
    }
  }

  Color _ringForTint(String tint) {
    switch (tint) {
      case "purple":
        return const Color(0xFF7B2FF2);
      case "orange":
        return const Color(0xFFFF6A3D);
      case "green":
        return const Color(0xFF22A447);
      case "blue":
        return const Color(0xFF2F5BFF);
      case "pink":
        return const Color(0xFFE12E7A);
      case "yellow":
        return const Color(0xFFB88700);
      default:
        return const Color(0xFFBDBDBD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _bgForTint(person.tint);
    final ring = _ringForTint(person.tint);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _Avatar(
              avatarUrl: person.avatarUrl,
              ring: ring,
              label: person.name,
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: const TextStyle(
                      color: kPurple,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),

                  if (person.lastActive.isNotEmpty)
                    Text(
                      person.lastActive,
                      style: const TextStyle(
                        color: kGreyText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  if (person.moodChip.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ring, width: 1.2),
                      ),
                      child: Text(
                        person.moodChip,
                        style: TextStyle(
                          color: ring,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            IconButton(
              onPressed: onTapMenu,
              icon: const Icon(Icons.more_vert, color: kPurple),
              splashRadius: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String avatarUrl;
  final Color ring;
  final String label;

  const _Avatar({
    required this.avatarUrl,
    required this.ring,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final letter = label.isNotEmpty
        ? label.trim().characters.first.toUpperCase()
        : "?";

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 3),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isNotEmpty
          ? Image.network(
              avatarUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(letter),
            )
          : _placeholder(letter),
    );
  }

  Widget _placeholder(String letter) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: Color(0xFF5B288E),
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}

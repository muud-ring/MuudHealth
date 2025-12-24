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
        return const Color(0xFFEFE6FF);
      case "orange":
        return const Color(0xFFFFE7DD);
      case "green":
        return const Color(0xFFE6F6E6);
      case "blue":
        return const Color(0xFFE8EEFF);
      case "pink":
        return const Color(0xFFFFE6F1);
      case "yellow":
        return const Color(0xFFFFF3D7);
      default:
        return const Color(0xFFF3F3F3);
    }
  }

  Color _chipBorderForTint(String tint) {
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
    final chipBorder = _chipBorderForTint(person.tint);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _Avatar(avatarUrl: person.avatarUrl),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (person.lastActive.isNotEmpty)
                    Text(
                      person.lastActive,
                      style: const TextStyle(
                        color: kGreyText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (person.moodChip.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: chipBorder, width: 1),
                      ),
                      child: Text(
                        person.moodChip,
                        style: TextStyle(
                          color: chipBorder,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onTapMenu,
              icon: const Icon(Icons.more_vert, color: kPurple),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String avatarUrl;
  const _Avatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFFFFF),
      ),
      child: const Icon(Icons.person, color: Color(0xFFBDBDBD), size: 24),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/people_models.dart';

class SuggestedAvatar extends StatelessWidget {
  final Person person;
  final VoidCallback? onTap;

  const SuggestedAvatar({super.key, required this.person, this.onTap});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

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
    final ring = _ringForTint(person.tint);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 78,
        child: Column(
          children: [
            _AvatarCircle(
              avatarUrl: person.avatarUrl,
              ring: ring,
              label: person.name,
            ),
            const SizedBox(height: 8),
            Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kPurple,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              person.handle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kGreyText,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String avatarUrl;
  final Color ring;
  final String label;

  const _AvatarCircle({
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
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 3),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isNotEmpty
          ? Image.network(
              avatarUrl,
              width: 54,
              height: 54,
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

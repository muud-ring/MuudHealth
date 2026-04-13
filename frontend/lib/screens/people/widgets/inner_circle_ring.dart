import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../data/people_models.dart';
import '../../../theme/app_theme.dart';

class InnerCircleRing extends StatelessWidget {
  final bool isEmpty;
  final List<Person> people;
  final VoidCallback? onTapAddFriends;
  final void Function(Person person)? onTapPerson;

  // center avatar should be ME
  final Person? centerPerson;

  const InnerCircleRing({
    super.key,
    required this.isEmpty,
    required this.people,
    this.onTapAddFriends,
    this.onTapPerson,
    this.centerPerson,
  });
  @override
  Widget build(BuildContext context) {
    final items = people.take(6).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 270,
            height: 270,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ring
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDADADA),
                      width: 2,
                    ),
                  ),
                ),

                // ring avatars
                if (!isEmpty) ..._buildRingAvatars(items),

                // center avatar (only in non-empty state, like your screenshot)
                if (!isEmpty) _CenterAvatar(person: centerPerson),

                // EMPTY STATE (matches screenshot copy)
                if (isEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.group_outlined,
                        size: 42,
                        color: Color(0xFFD7CDE3),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No Inner Circle",
                        style: TextStyle(
                          color: MuudColors.purple,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Your inner circles will show up here.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MuudColors.greyText,
                          fontSize: 13.5,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // EMPTY CTA (full width, pill, “Add friends”)
          if (isEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MuudColors.purple,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                onPressed: onTapAddFriends,
                child: const Text(
                  "Add friends",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildRingAvatars(List<Person> items) {
    final positions = <Offset>[
      const Offset(0.0, -0.92),
      const Offset(0.74, -0.56),
      const Offset(0.92, 0.06),
      const Offset(0.56, 0.74),
      const Offset(-0.56, 0.74),
      const Offset(-0.92, 0.06),
    ];

    final show = items.take(6).toList();

    return List.generate(show.length, (i) {
      final p = show[i];
      final pos = positions[i];

      return Align(
        alignment: Alignment(pos.dx, pos.dy),
        child: GestureDetector(
          onTap: onTapPerson == null ? null : () => onTapPerson!(p),
          child: _RingAvatar(
            avatarUrl: p.avatarUrl,
            label: p.name,
            ring: _ringForTint(p.tint),
          ),
        ),
      );
    });
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
        return MuudColors.purple;
    }
  }
}

class _CenterAvatar extends StatelessWidget {
  final Person? person;
  const _CenterAvatar({required this.person});
  @override
  Widget build(BuildContext context) {
    final name = person?.name ?? "You";
    final url = person?.avatarUrl ?? "";

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: MuudColors.purple, width: 6),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _placeholder(name),
            )
          : _placeholder(name),
    );
  }

  Widget _placeholder(String label) {
    final letter = label.isNotEmpty
        ? label.trim().characters.first.toUpperCase()
        : "Y";
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: MuudColors.purple,
          fontWeight: FontWeight.w900,
          fontSize: 36,
        ),
      ),
    );
  }
}

class _RingAvatar extends StatelessWidget {
  final String avatarUrl;
  final String label;
  final Color ring;

  const _RingAvatar({
    required this.avatarUrl,
    required this.label,
    required this.ring,
  });

  @override
  Widget build(BuildContext context) {
    final letter = label.isNotEmpty
        ? label.trim().characters.first.toUpperCase()
        : "?";

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 4),
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: avatarUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _placeholder(letter),
            )
          : _placeholder(letter),
    );
  }

  Widget _placeholder(String letter) {
    return Center(
      child: Text(
        letter,
        style: const TextStyle(
          color: MuudColors.purple,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}

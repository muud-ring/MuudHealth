import 'package:flutter/material.dart';
import '../data/people_models.dart';

class InnerCircleRing extends StatelessWidget {
  final bool isEmpty;
  final List<Person> people;
  final VoidCallback? onTapAddFriends;

  const InnerCircleRing({
    super.key,
    required this.isEmpty,
    required this.people,
    this.onTapAddFriends,
  });

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ring background
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD6CBE0),
                      width: 10,
                    ),
                  ),
                ),

                // avatars around ring (only if filled)
                if (!isEmpty) ..._buildRingAvatars(),

                // center content
                if (isEmpty)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.group_outlined,
                        size: 40,
                        color: Color(0xFFD7CDE3),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "No Inner Circle",
                        style: TextStyle(
                          color: kPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Add friends to your inner circle",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kGreyText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Your Inner Circle",
                        style: TextStyle(
                          color: kPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${people.length} people",
                        style: const TextStyle(
                          color: kGreyText,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          if (isEmpty)
            SizedBox(
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                onPressed: onTapAddFriends,
                child: const Text(
                  "Add Friends",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildRingAvatars() {
    // positions roughly match a ring layout
    // we just take up to 6 people for the ring preview
    final items = people.take(6).toList();

    final positions = <Offset>[
      const Offset(0.0, -0.92), // top
      const Offset(0.72, -0.55), // top-right
      const Offset(0.92, 0.05), // right
      const Offset(0.55, 0.72), // bottom-right
      const Offset(-0.55, 0.72), // bottom-left
      const Offset(-0.92, 0.05), // left
    ];

    return List.generate(items.length, (i) {
      final p = items[i];
      final pos = positions[i];

      return Align(
        alignment: Alignment(pos.dx, pos.dy),
        child: _RingAvatar(avatarUrl: p.avatarUrl),
      );
    });
  }
}

class _RingAvatar extends StatelessWidget {
  final String avatarUrl;
  const _RingAvatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isNotEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: Image.network(
            avatarUrl,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(),
          ),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3E3E3)),
      ),
      child: const Icon(Icons.person, color: Color(0xFFBDBDBD), size: 26),
    );
  }
}

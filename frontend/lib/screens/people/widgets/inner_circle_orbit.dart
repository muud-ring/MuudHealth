import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/people_models.dart';

class InnerCircleOrbit extends StatelessWidget {
  final String centerAvatarUrl;
  final List<InnerCircleMember> members;
  final VoidCallback? onTapSeeAll;
  final void Function(InnerCircleMember member)? onTapMember;
  final VoidCallback? onTapCenter;

  const InnerCircleOrbit({
    super.key,
    required this.centerAvatarUrl,
    required this.members,
    this.onTapSeeAll,
    this.onTapMember,
    this.onTapCenter,
  });

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    // Figma-like sizing
    const double size = 210;
    const double orbitRadius = 78;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // orbit ring
                Container(
                  width: orbitRadius * 2.1,
                  height: orbitRadius * 2.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                ),

                // center avatar (big)
                GestureDetector(
                  onTap: onTapCenter,
                  child: _RingAvatar(
                    size: 92,
                    ringWidth: 6,
                    ringColor: kPurple,
                    avatarUrl: centerAvatarUrl,
                  ),
                ),

                // orbit members
                ..._buildOrbitMembers(orbitRadius),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrbitMembers(double r) {
    if (members.isEmpty) return [];

    final int n = members.length;
    final double center = 105; // half of size=210

    // arrange evenly; start angle slightly upwards like Figma
    final double startAngle = -math.pi / 2.2;

    return List.generate(n, (i) {
      final m = members[i];
      final angle = startAngle + (2 * math.pi * i / n);
      final dx = center + r * math.cos(angle);
      final dy = center + r * math.sin(angle);

      return Positioned(
        left: dx - 22,
        top: dy - 22,
        child: GestureDetector(
          onTap: () => onTapMember?.call(m),
          child: _RingAvatar(
            size: 44,
            ringWidth: 3.5,
            ringColor: m.ringColor,
            avatarUrl: m.avatarUrl,
          ),
        ),
      );
    });
  }
}

class _RingAvatar extends StatelessWidget {
  final double size;
  final double ringWidth;
  final Color ringColor;
  final String avatarUrl;

  const _RingAvatar({
    required this.size,
    required this.ringWidth,
    required this.ringColor,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ringColor.withOpacity(0.18),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor, width: ringWidth),
        ),
        child: ClipOval(
          child: avatarUrl.isEmpty
              ? Container(
                  color: const Color(0xFFEFEFEF),
                  child: Icon(
                    Icons.person,
                    size: size * 0.45,
                    color: const Color(0xFFBDBDBD),
                  ),
                )
              : Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFEFEFEF),
                    child: Icon(
                      Icons.person,
                      size: size * 0.45,
                      color: const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

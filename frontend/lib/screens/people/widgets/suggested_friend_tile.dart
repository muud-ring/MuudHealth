import 'package:flutter/material.dart';
import '../models/people_models.dart';

class SuggestedFriendTile extends StatelessWidget {
  final SuggestedFriend friend;
  final VoidCallback? onTap;

  const SuggestedFriendTile({super.key, required this.friend, this.onTap});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: friend.ringColor, width: 3),
              ),
              child: ClipOval(
                child: friend.avatarUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFEFEFEF),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFFBDBDBD),
                        ),
                      )
                    : Image.network(
                        friend.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFEFEFEF),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              friend.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kPurple,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              friend.handle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kGreyText,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

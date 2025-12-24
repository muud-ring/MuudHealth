import 'package:flutter/material.dart';

import '../data/people_dummy_data.dart';
import '../widgets/primary_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    // For now just show first suggestion as demo profile
    final p = PeopleDummyData.suggestions.isNotEmpty
        ? PeopleDummyData.suggestions.first
        : PeopleDummyData.connections.first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: kPurple, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _Avatar(avatarUrl: p.avatarUrl),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: kPurple,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.handle,
                    style: const TextStyle(
                      color: kGreyText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    p.location,
                    style: const TextStyle(
                      color: kGreyText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  PrimaryButton(
                    text: "Message",
                    onTap: () => Navigator.pushNamed(context, '/people/chat'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Posts",
              style: TextStyle(
                color: kPurple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            _PostCard(
              title: "Yoga class was amazing today!",
              subtitle: "2h ago",
            ),
            _PostCard(
              title: "Feeling a bit low but going for a walk.",
              subtitle: "1d ago",
            ),
            _PostCard(title: "Meditation streak: 7 days ✅", subtitle: "3d ago"),
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
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: const Icon(Icons.person, color: Color(0xFFBDBDBD), size: 40),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PostCard({required this.title, required this.subtitle});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kPurple,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: kGreyText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

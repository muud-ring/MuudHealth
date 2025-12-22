import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kDivider = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPurple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: kPurple,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: const [
          SizedBox(height: 18),
          Text(
            "Account Settings",
            style: TextStyle(
              color: kPurple,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 18),
          _SettingsRow(icon: Icons.person_outline, title: "Security"),
          Divider(color: kDivider, height: 1),
          _SettingsRow(icon: Icons.lock_outline, title: "Profile Privacy"),
          Divider(color: kDivider, height: 1),
          _SettingsRow(
            icon: Icons.visibility_outlined,
            title: "Content Visibility",
          ),
          Divider(color: kDivider, height: 1),
          _SettingsRow(icon: Icons.notifications_none, title: "Notifications"),
          Divider(color: kDivider, height: 1),
          _SettingsRow(icon: Icons.help_outline, title: "Support"),
          Divider(color: kDivider, height: 1),
          _SettingsRow(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
          ),
          Divider(color: kDivider, height: 1),
          _SettingsRow(
            icon: Icons.article_outlined,
            title: "Terms & Conditions",
          ),
          Divider(color: kDivider, height: 1),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.title});

  static const Color kPurple = Color(0xFF5B288E);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // For now: no destination pages. We'll wire later.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$title: coming soon")));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Row(
          children: [
            Icon(icon, color: kPurple, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: kPurple,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: kPurple, size: 28),
          ],
        ),
      ),
    );
  }
}

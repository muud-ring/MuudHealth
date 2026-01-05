import 'package:flutter/material.dart';
import '../../services/token_storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kDivider = Color(0xFFE8E8E8);

  Future<void> _confirmAndLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log out?"),
        content: const Text("You’ll be signed out of MUUD Health."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Log out"),
          ),
        ],
      ),
    );

    if (yes != true) return;

    await TokenStorage.clearTokens();

    if (!context.mounted) return;

    // remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

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
        children: [
          const SizedBox(height: 18),
          const Text(
            "Account Settings",
            style: TextStyle(
              color: kPurple,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),

          const _SettingsRow(icon: Icons.person_outline, title: "Security"),
          const Divider(color: kDivider, height: 1),

          const _SettingsRow(
            icon: Icons.lock_outline,
            title: "Profile Privacy",
          ),
          const Divider(color: kDivider, height: 1),

          const _SettingsRow(
            icon: Icons.visibility_outlined,
            title: "Content Visibility",
          ),
          const Divider(color: kDivider, height: 1),

          const _SettingsRow(
            icon: Icons.notifications_none,
            title: "Notifications",
          ),
          const Divider(color: kDivider, height: 1),

          const _SettingsRow(icon: Icons.help_outline, title: "Support"),
          const Divider(color: kDivider, height: 1),

          const _SettingsRow(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
          ),
          const Divider(color: kDivider, height: 1),

          const _SettingsRow(
            icon: Icons.article_outlined,
            title: "Terms & Conditions",
          ),

          // ✅ Logout row (under Terms & Conditions)
          const Divider(color: kDivider, height: 1),
          _SettingsRow(
            icon: Icons.logout,
            title: "Logout",
            titleColor: Colors.red,
            iconColor: Colors.red,
            trailingColor: Colors.red,
            onTap: () => _confirmAndLogout(context),
          ),
          const Divider(color: kDivider, height: 1),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.trailingColor,
  });

  static const Color kPurple = Color(0xFF5B288E);

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  final Color? titleColor;
  final Color? iconColor;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap =
        onTap ??
        () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("$title: coming soon")));
        };

    return InkWell(
      onTap: effectiveOnTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? kPurple, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? kPurple,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: trailingColor ?? kPurple,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

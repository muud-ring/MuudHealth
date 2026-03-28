import 'package:flutter/material.dart';
import '../../services/token_storage.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const Color kDivider = Color(0xFFE8E8E8);

  Future<void> _confirmAndLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log out?"),
        content: const Text("You'll be signed out of MUUD Health."),
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back arrow and title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppTheme.purple,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Settings",
                        style: TextStyle(
                          color: AppTheme.purple,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Placeholder for symmetry
                  const SizedBox(width: 22),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Settings section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                "Account Settings",
                style: TextStyle(
                  color: AppTheme.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const _SettingsRow(
                    icon: Icons.account_circle_outlined,
                    title: "Security",
                  ),
                  const Divider(color: kDivider, height: 1),

                  const _SettingsRow(
                    icon: Icons.lock_outline,
                    title: "Profile Privacy",
                  ),
                  const Divider(color: kDivider, height: 1),

                  const _SettingsRow(
                    icon: Icons.remove_red_eye_outlined,
                    title: "Content Visibility",
                  ),
                  const Divider(color: kDivider, height: 1),

                  const _SettingsRow(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                  ),
                  const Divider(color: kDivider, height: 1),

                  const _SettingsRow(
                    icon: Icons.help_outline,
                    title: "Support",
                  ),
                  const Divider(color: kDivider, height: 1),

                  const _SettingsRow(
                    icon: Icons.policy_outlined,
                    title: "Privacy Policy",
                  ),
                  const Divider(color: kDivider, height: 1),

                  const _SettingsRow(
                    icon: Icons.description_outlined,
                    title: "Terms & Conditions",
                  ),
                  const Divider(color: kDivider, height: 1),

                  // ✅ Logout row (keeping functionality)
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
            ),
          ],
        ),
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
  static const Color kGray = Color(0xFF9E9E9E);

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
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppTheme.purple, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? AppTheme.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: trailingColor ?? kGray, size: 24),
          ],
        ),
      ),
    );
  }
}

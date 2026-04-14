// MUUD Health — Settings Screen
// Account settings with logout
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/route_names.dart';
import '../../services/token_storage.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmAndLogout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Log out?"),
        content: const Text("You'll be signed out of MUUD Health."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Log out")),
        ],
      ),
    );

    if (yes != true) return;
    await TokenStorage.clearTokens();
    if (!context.mounted) return;
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(MuudSpacing.base, MuudSpacing.sm, MuudSpacing.base, 0),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_ios, color: MuudColors.purple, size: 22),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text("Settings", style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple)),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),

            const SizedBox(height: MuudSpacing.xl),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.xl),
              child: Text(
                "Account Settings",
                style: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
              ),
            ),

            const SizedBox(height: MuudSpacing.base),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: MuudSpacing.xl),
                children: [
                  const _SettingsRow(icon: Icons.account_circle_outlined, title: "Security"),
                  const Divider(color: MuudColors.divider, height: 1),
                  const _SettingsRow(icon: Icons.lock_outline, title: "Profile Privacy"),
                  const Divider(color: MuudColors.divider, height: 1),
                  const _SettingsRow(icon: Icons.remove_red_eye_outlined, title: "Content Visibility"),
                  const Divider(color: MuudColors.divider, height: 1),
                  const _SettingsRow(icon: Icons.notifications_outlined, title: "Notifications"),
                  const Divider(color: MuudColors.divider, height: 1),
                  const _SettingsRow(icon: Icons.help_outline, title: "Support"),
                  const Divider(color: MuudColors.divider, height: 1),
                  const _SettingsRow(icon: Icons.policy_outlined, title: "Privacy Policy"),
                  const Divider(color: MuudColors.divider, height: 1),
                  const _SettingsRow(icon: Icons.description_outlined, title: "Terms & Conditions"),
                  const Divider(color: MuudColors.divider, height: 1),
                  _SettingsRow(
                    icon: Icons.logout,
                    title: "Logout",
                    titleColor: MuudColors.error,
                    iconColor: MuudColors.error,
                    trailingColor: MuudColors.error,
                    onTap: () => _confirmAndLogout(context),
                  ),
                  const Divider(color: MuudColors.divider, height: 1),
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

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final effectiveOnTap = onTap ?? () {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title: coming soon")));
    };

    return InkWell(
      onTap: effectiveOnTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MuudSpacing.lg),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? MuudColors.purple, size: 24),
            const SizedBox(width: MuudSpacing.base),
            Expanded(
              child: Text(
                title,
                style: MuudTypography.bodyMedium.copyWith(
                  color: titleColor ?? MuudColors.purple,
                  fontSize: 18,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: trailingColor ?? MuudColors.greyText, size: 24),
          ],
        ),
      ),
    );
  }
}

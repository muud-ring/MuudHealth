import 'package:flutter/material.dart';

import '../people/sheets/connection_requests_sheet.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.purple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Friend Requests",
              style: TextStyle(
                color: AppTheme.purple,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              tileColor: const Color(0xFFF5F2FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: const Icon(Icons.group_outlined, color: AppTheme.purple),
              title: const Text(
                "Connection Requests",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                "Tap to view and manage requests",
                style: TextStyle(color: AppTheme.greyText, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await ConnectionRequestsSheet.open(context);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "More notifications coming soon",
              style: TextStyle(color: AppTheme.greyText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

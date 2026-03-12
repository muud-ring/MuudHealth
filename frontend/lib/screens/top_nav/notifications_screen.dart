import 'package:flutter/material.dart';

import '../people/sheets/connection_requests_sheet.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kGreyText = Color(0xFF898384);

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
          "Notifications",
          style: TextStyle(
            color: kPurple,
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
                color: kPurple,
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
              leading: const Icon(Icons.group_outlined, color: kPurple),
              title: const Text(
                "Connection Requests",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                "Tap to view and manage requests",
                style: TextStyle(color: kGreyText, fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await ConnectionRequestsSheet.open(context);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "More notifications coming soon",
              style: TextStyle(color: kGreyText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

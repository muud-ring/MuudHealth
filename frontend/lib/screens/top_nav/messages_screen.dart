import 'package:flutter/material.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});
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
          "Messages",
          style: TextStyle(
            color: AppTheme.purple,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          "Messages screen (coming soon)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

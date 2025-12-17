import 'package:flutter/material.dart';
import '../services/token_storage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clear();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: const Center(child: Text('✅ Logged in! (Basic Home)')),
    );
  }
}

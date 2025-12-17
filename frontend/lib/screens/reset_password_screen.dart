import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _api = ApiService();
  final _code = TextEditingController();
  final _newPassword = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _reset(String identifier) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.confirmForgotPassword(
        identifier: identifier,
        code: _code.text.trim(),
        newPassword: _newPassword.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final identifier = (args['identifier'] ?? '') as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Resetting for: $identifier'),
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: 'Reset code'),
            ),
            TextField(
              controller: _newPassword,
              decoration: const InputDecoration(labelText: 'New password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _reset(identifier),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Update password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _api = ApiService();
  final _code = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verifyAndLogin(String identifier, String password) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.confirmSignup(identifier: identifier, code: _code.text.trim());

      final res = await _api.login(identifier: identifier, password: password);
      final tokens = res['tokens'] as Map<String, dynamic>;

      await TokenStorage.saveTokens(
        idToken: tokens['idToken'],
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final identifier = (args['identifier'] ?? '') as String;
    final password = (args['password'] ?? '') as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Code sent to: $identifier'),
            TextField(
              controller: _code,
              decoration: const InputDecoration(labelText: 'OTP code'),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () => _verifyAndLogin(identifier, password),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Verify & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

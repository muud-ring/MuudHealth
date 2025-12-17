import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _api = ApiService();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _birthdate = TextEditingController(); // YYYY-MM-DD

  bool _loading = false;
  String? _error;

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.signup(
        identifier: _identifier.text.trim(),
        password: _password.text,
        fullName: _fullName.text.trim(),
        username: _username.text.trim(),
        birthdate: _birthdate.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {
          'identifier': _identifier.text.trim(),
          'password': _password.text,
        },
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _fullName.dispose();
    _username.dispose();
    _birthdate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _identifier,
              decoration: const InputDecoration(
                labelText: 'Email or Phone (+1...)',
              ),
            ),
            TextField(
              controller: _fullName,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _birthdate,
              decoration: const InputDecoration(
                labelText: 'Birthdate (YYYY-MM-DD)',
              ),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _signup,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color kDisabledPurple = Color(0xFFB7A6C8);

  final _api = ApiService();

  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  bool _loading = false;
  String? _error;

  bool get _hasMinLen => _newPassword.text.length >= 8;
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newPassword.text);

  bool get _hasSpecial => RegExp(
    "[!@#\\\$%^&*(),.?\\\":{}|<>_\\-\\\\/\\[\\]=+;\\'`~]",
  ).hasMatch(_newPassword.text);

  bool get _passwordValid => _hasMinLen && _hasNumber && _hasSpecial;
  bool get _confirmMatches => _confirmPassword.text == _newPassword.text;

  bool get _canSubmit =>
      _passwordValid &&
      _confirmMatches &&
      !_loading &&
      _newPassword.text.isNotEmpty &&
      _confirmPassword.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _newPassword.addListener(() {
      if (mounted) setState(() {});
    });
    _confirmPassword.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _save({required String identifier, required String code}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (!_passwordValid) {
        throw Exception(
          'Must be 8 characters or more and include at least 1 number and 1 special character',
        );
      }
      if (!_confirmMatches) {
        throw Exception('Please make sure your passcode match');
      }

      await _api.confirmForgotPassword(
        identifier: identifier,
        code: code,
        newPassword: _newPassword.text,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final identifier = (args['identifier'] ?? '') as String;
    final code = (args['code'] ?? '') as String;

    final showPwError = _newPassword.text.isNotEmpty && !_passwordValid;
    final showConfirmError =
        _confirmPassword.text.isNotEmpty && !_confirmMatches;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.purple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Update Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.purple,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'New password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPassword,
                obscureText: _obscure1,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                    icon: Icon(
                      _obscure1
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black45,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: showPwError ? Colors.red : Colors.black54,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: showPwError ? Colors.red : AppTheme.purple,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              if (showPwError)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Must be 8 characters or more and include at least\n1 number and 1 special character',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Confirm new password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPassword,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                    icon: Icon(
                      _obscure2
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black45,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: showConfirmError ? Colors.red : Colors.black54,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: showConfirmError ? Colors.red : AppTheme.purple,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
              if (showConfirmError)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Please make sure your passcode match',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 26),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _canSubmit
                      ? () => _save(identifier: identifier, code: code)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    disabledBackgroundColor: kDisabledPurple,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

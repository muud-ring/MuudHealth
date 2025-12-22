import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../services/post_auth_redirect.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _api = ApiService();

  static const Color kPurple = Color(0xFF5B288E);
  static const Color kBorderGrey = Color(0xFFCCCCCC);

  final List<TextEditingController> _ctrl = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _ctrl) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  String _maskIdentifier(String identifier) {
    final id = identifier.trim();
    final digits = id.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 4 && (id.startsWith('+') || digits.length >= 10)) {
      final last4 = digits.substring(digits.length - 4);
      return 'Mobile number ending in ******$last4';
    }

    if (id.contains('@')) {
      final parts = id.split('@');
      final name = parts.first;
      final domain = parts.length > 1 ? parts[1] : '';
      final first = name.isNotEmpty ? name[0] : '';
      return 'Email $first*****@$domain';
    }

    return id;
  }

  String _getCode() => _ctrl.map((e) => e.text.trim()).join();

  Future<void> _verifyAndLogin({
    required String identifier,
    required String password,
  }) async {
    final code = _getCode();
    if (code.length != 6) {
      setState(() => _error = 'Please enter the 6-digit code.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.confirmSignup(identifier: identifier, code: code);

      final res = await _api.login(identifier: identifier, password: password);
      final tokens = (res['tokens'] as Map).cast<String, dynamic>();

      await TokenStorage.saveTokens(
        idToken: tokens['idToken'],
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/onboarding/01',
        (_) => false,
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resend: coming next (backend endpoint).')),
    );
  }

  void _onChanged(int index, String value) {
    // Keep only 1 digit
    if (value.length > 1) {
      final v = value.substring(value.length - 1);
      _ctrl[index].text = v;
      _ctrl[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _ctrl[index].text.length),
      );
    }

    // Move forward when user enters a digit
    if (value.isNotEmpty && index < 5) {
      _focus[index + 1].requestFocus();
      return;
    }

    // Move back when user deletes (stable, no keyboard listeners needed)
    if (value.isEmpty && index > 0) {
      _focus[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final identifier = (args['identifier'] ?? '') as String;
    final password = (args['password'] ?? '') as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: kPurple, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 60),

              const Text(
                'We sent you a code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Please enter the verification code sent to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                _maskIdentifier(identifier),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 55),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    height: 58,
                    child: TextField(
                      controller: _ctrl[i],
                      focusNode: _focus[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: kBorderGrey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.black87,
                            width: 1.2,
                          ),
                        ),
                      ),
                      onChanged: (v) => _onChanged(i, v),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () => _verifyAndLogin(
                          identifier: identifier,
                          password: password,
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
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
                          'Verify',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn’t receive a code? ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: _resend,
                    child: const Text(
                      "Resend",
                      style: TextStyle(
                        fontSize: 16,
                        color: kPurple,
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

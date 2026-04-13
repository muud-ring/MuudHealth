import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  const VerifyResetCodeScreen({super.key});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  static final Color kDisabledPurple = MuudColors.purple.withValues(alpha: 0.4);

  final _api = ApiService();

  final List<TextEditingController> _ctrl = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());

  bool _loading = false;

  String get _code => _ctrl.map((c) => c.text).join();
  bool get _complete => _code.length == 6 && !_code.contains(RegExp(r'[^0-9]'));

  @override
  void dispose() {
    for (final c in _ctrl) c.dispose();
    for (final f in _focus) f.dispose();
    super.dispose();
  }

  String _maskIdentifier(String id) {
    if (id.contains('@')) {
      final parts = id.split('@');
      final name = parts[0];
      final domain = parts[1];
      final visible = name.length > 2 ? name.substring(0, 2) : name;
      return '$visible*****@$domain';
    }
    final digits = id.replaceAll(RegExp(r'[^0-9]'), '');
    return 'Mobile number ending in ******${digits.substring(digits.length - 4)}';
  }

  void _onChanged(int i, String v) {
    if (v.length > 1) {
      final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
      for (int k = 0; k < 6; k++) {
        _ctrl[k].text = k < digits.length ? digits[k] : '';
      }
      FocusScope.of(context).requestFocus(_focus[digits.length.clamp(0, 5)]);
      setState(() {});
      return;
    }

    if (v.isNotEmpty && i < 5) {
      FocusScope.of(context).requestFocus(_focus[i + 1]);
    }
    setState(() {});
  }

  Future<void> _resend(String identifier) async {
    setState(() => _loading = true);
    try {
      await _api.forgotPassword(identifier: identifier);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Code resent')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continue(String identifier) {
    if (!_complete) return;
    context.push(Routes.resetPassword, extra: {'identifier': identifier, 'code': _code});
  }

  @override
  Widget build(BuildContext context) {
    final args = (GoRouterState.of(context).extra as Map?) ?? {};
    final identifier = (args['identifier'] ?? '') as String;

    return Scaffold(
      backgroundColor: MuudColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                'We sent you a\ncode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: MuudColors.purple,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Please enter the verification code sent to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _maskIdentifier(identifier),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  final hasValue = _ctrl[i].text.isNotEmpty;

                  return SizedBox(
                    width: 48,
                    height: 60, // ✅ fixed height
                    child: TextField(
                      controller: _ctrl[i],
                      focusNode: _focus[i],
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center, // ✅ FIX
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      strutStyle: const StrutStyle(
                        fontSize: 26,
                        height: 1.1,
                        forceStrutHeight: true,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: MuudRadius.mdAll,
                          borderSide: BorderSide(
                            color: hasValue ? MuudColors.purple : Colors.black38,
                            width: 1.4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: MuudRadius.mdAll,
                          borderSide: const BorderSide(
                            color: MuudColors.purple,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (v) => _onChanged(i, v),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _complete && !_loading
                      ? () => _continue(identifier)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MuudColors.purple,
                    disabledBackgroundColor: kDisabledPurple,
                    shape: const StadiumBorder(),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MuudColors.white,
                        )
                      : const Text(
                          'Verify to continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: MuudColors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn’t receive a code? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: _loading ? null : () => _resend(identifier),
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color: MuudColors.purple,
                        fontSize: 16,
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

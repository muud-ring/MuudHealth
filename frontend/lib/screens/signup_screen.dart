import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../services/api_service.dart';

// ✅ Legal popup imports
import 'legal/legal_modal_page.dart';
import 'legal/legal_texts.dart';
import 'package:muud_health_app/theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _api = ApiService();

  final _identifier = TextEditingController();
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  DateTime? _dob;
  bool _obscure = true;

  bool _loading = false;
  String? _error;
  // ✅ Figma-like disabled button color (light grey-purple)
  static const Color kDisabledPurple = Color(0xFFB7A6C8);

  // ✅ Tooltip copy (DOB info)
  static const String _dobTooltipText =
      "To help keep MUUD safe, you must provide your birthdate and be 14 or older. "
      "Providing your birthdate also helps make sure you get the right experience "
      "and recommendations for your age. We don’t share this information and it "
      "won’t be visible on your profile. For more details, please visit our ";

  // ✅ UI-only: enable button only when ALL fields filled + dob selected
  bool get _isFormComplete {
    return _identifier.text.trim().isNotEmpty &&
        _fullName.text.trim().isNotEmpty &&
        _username.text.trim().isNotEmpty &&
        _password.text.isNotEmpty &&
        _dob != null;
  }

  // ✅ Open legal popup (same as Login)
  void _openLegal({required String title, required String body}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LegalModalPage(title: title, body: body),
      ),
    );
  }

  // ✅ DOB tooltip modal (center popup with 25% black background)
  void _openDobTooltip() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x40000000), // ✅ black 25% opacity
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.86,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        const TextSpan(text: _dobTooltipText),
                        TextSpan(
                          text: 'Privacy Policy.',
                          style: const TextStyle(
                            color: AppTheme.purple,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(ctx); // close tooltip
                              _openLegal(
                                title: LegalTexts.privacyTitle,
                                body: LegalTexts.privacyBody,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.purple,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Okay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _identifier.addListener(_onFormChanged);
    _fullName.addListener(_onFormChanged);
    _username.addListener(_onFormChanged);
    _password.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  String _formatDobForBackend(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _formatDobForUI(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final y = d.year.toString().padLeft(4, '0');
    return '$m/$day/$y';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: 'Select date of birth',
    );

    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _signup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final identifier = _identifier.text.trim();
      final fullName = _fullName.text.trim();
      final username = _username.text.trim();
      final password = _password.text;

      if (identifier.isEmpty) throw Exception('Please enter email or phone.');
      if (fullName.isEmpty) throw Exception('Please enter your full name.');
      if (username.isEmpty) throw Exception('Please enter a username.');
      if (password.isEmpty) throw Exception('Please enter a password.');
      if (_dob == null) throw Exception('Please select your date of birth.');

      await _api.signup(
        identifier: identifier,
        password: password,
        fullName: fullName,
        username: username,
        birthdate: _formatDobForBackend(_dob!),
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {
          'identifier': identifier,
          'password': password,
          'fullName': fullName,
          'username': username,
          'dob': _formatDobForBackend(_dob!),
        },
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _identifier.removeListener(_onFormChanged);
    _fullName.removeListener(_onFormChanged);
    _username.removeListener(_onFormChanged);
    _password.removeListener(_onFormChanged);

    _identifier.dispose();
    _fullName.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool enabled = _isFormComplete && !_loading;

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
        centerTitle: true,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: AppTheme.purple,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18, 8, 18, 18 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),

            const _Label('Mobile number or email address'),
            const SizedBox(height: 8),
            _Field(
              controller: _identifier,
              hint: 'Enter your phone or email',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 14),

            const _Label('Full name'),
            const SizedBox(height: 8),
            _Field(
              controller: _fullName,
              hint: 'Enter your full name',
              keyboardType: TextInputType.name,
            ),

            const SizedBox(height: 14),

            const _Label('Username'),
            const SizedBox(height: 8),
            _Field(controller: _username, hint: 'Enter your username'),

            const SizedBox(height: 14),

            const _Label('Password'),
            const SizedBox(height: 8),
            _Field(
              controller: _password,
              hint: 'Enter your password',
              obscureText: _obscure,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.purple,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ✅ DOB label + info icon opens tooltip
            Row(
              children: [
                const _Label('Date of birth'),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _openDobTooltip,
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDob,
              child: AbsorbPointer(
                child: _Field(
                  controller: TextEditingController(
                    text: _dob == null ? '' : _formatDobForUI(_dob!),
                  ),
                  hint: 'MM/DD/YYYY',
                  suffix: IconButton(
                    onPressed: _pickDob,
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      color: AppTheme.purple,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Learn More opens tooltip modal
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'People who use our service may have uploaded\n',
                  ),
                  const TextSpan(text: 'your contact information to MUUD. '),
                  TextSpan(
                    text: 'Learn More',
                    style: const TextStyle(
                      color: AppTheme.purple,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _openDobTooltip();
                      },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Terms + Privacy open full-screen legal popup
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'By signing up, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: AppTheme.purple,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _openLegal(
                          title: LegalTexts.termsTitle,
                          body: LegalTexts.termsBody,
                        );
                      },
                  ),
                  const TextSpan(text: ' and\n'),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: AppTheme.purple,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _openLegal(
                          title: LegalTexts.privacyTitle,
                          body: LegalTexts.privacyBody,
                        );
                      },
                  ),
                  const TextSpan(
                    text:
                        '. You may receive SMS\nnotifications from us and can opt out any time.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: enabled ? _signup : null,
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
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4B4B4B),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD0D0D0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppTheme.purple,
            width: 1.6,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

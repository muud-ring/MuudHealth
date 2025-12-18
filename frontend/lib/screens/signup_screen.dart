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
  final _fullName = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  DateTime? _dob;
  bool _obscure = true;

  bool _loading = false;
  String? _error;

  static const Color kPurple = Color(0xFF5B288E);

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
      if (_dob == null) {
        throw Exception('Please select your date of birth.');
      }

      await _api.signup(
        identifier: _identifier.text.trim(),
        password: _password.text,
        fullName: _fullName.text.trim(),
        username: _username.text.trim(),
        birthdate: _formatDobForBackend(_dob!),
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _fullName.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kPurple),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: kPurple,
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
                  color: kPurple,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: const [
                _Label('Date of birth'),
                SizedBox(width: 6),
                Icon(Icons.info_outline, size: 16, color: Colors.black54),
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
                      color: kPurple,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Small legal text (matches layout)
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'People who use our service may have uploaded\n',
                  ),
                  TextSpan(text: 'your contact information to MUUD. '),
                  TextSpan(
                    text: 'Learn More',
                    style: TextStyle(
                      color: kPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12.5,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'By signing up, you agree to our '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: kPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' and\n'),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: kPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
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
                onPressed: _loading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple.withOpacity(_loading ? 0.5 : 0.45),
                  disabledBackgroundColor: kPurple.withOpacity(0.35),
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
            color: _SignupScreenState.kPurple,
            width: 1.6,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

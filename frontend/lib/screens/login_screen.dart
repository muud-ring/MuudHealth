import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../services/social_auth_service.dart';
import '../services/cognito_oauth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api = ApiService();

  final _identifier = TextEditingController();
  final _password = TextEditingController();

  final _socialAuth = SocialAuthService();

  bool _loading = false;
  String? _error;

  // Colors close to your design
  static const Color kPurple = Color(0xFF5B288E);

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.login(
        identifier: _identifier.text.trim(),
        password: _password.text,
      );

      final tokens = (res['tokens'] as Map).cast<String, dynamic>();

      await TokenStorage.saveTokens(
        idToken: tokens['idToken'],
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 28, 20, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),

              // Username or email
              const Text(
                'Username or email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _RoundedInput(
                controller: _identifier,
                hint: '',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // Password
              const Text(
                'Password',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _RoundedInput(controller: _password, hint: '', obscureText: true),

              const SizedBox(height: 10),

              // Forgot
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/forgot'),
                  child: const Text(
                    'Forgot username or password?',
                    style: TextStyle(
                      color: kPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Error
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Login button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
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
                          'Log in',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 26),

              // OR divider
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),

              const SizedBox(height: 18),

              // Social buttons row (UI only for now)
              // Social buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIconButton(
                    assetPath: 'assets/icons/google.png',
                    onTap: () async {
                      try {
                        final result = await CognitoOAuthService.instance
                            .signInWithGoogle();

                        await TokenStorage.saveTokens(
                          idToken: result.idToken!,
                          accessToken: result.accessToken!,
                          refreshToken: result.refreshToken,
                        );

                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                  const SizedBox(width: 18),
                  _SocialIconButton(
                    assetPath: 'assets/icons/apple.png',
                    onTap: () async {
                      try {
                        final result = await CognitoOAuthService.instance
                            .signInWithApple();

                        await TokenStorage.saveTokens(
                          idToken: result.idToken!,
                          accessToken: result.accessToken!,
                          refreshToken: result.refreshToken,
                        );

                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                  const SizedBox(width: 18),
                  _SocialIconButton(
                    assetPath: 'assets/icons/facebook.png',
                    onTap: () async {
                      try {
                        final result = await CognitoOAuthService.instance
                            .signInWithFacebook();

                        await TokenStorage.saveTokens(
                          idToken: result.idToken!,
                          accessToken: result.accessToken!,
                          refreshToken: result.refreshToken,
                        );

                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Join MUUD Today
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPurple, width: 2),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Join MUUD Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kPurple,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Footer links (UI only)
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: [
                    _FooterLink(text: 'Privacy Policy', onTap: () {}),
                    const Text('|', style: TextStyle(color: Colors.black45)),
                    _FooterLink(text: 'Terms of Use', onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: _FooterLink(text: 'HIPAA Notice', onTap: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _RoundedInput({
    required this.controller,
    required this.hint,
    this.obscureText = false,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _LoginScreenState.kPurple,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _SocialIconButton({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(child: Image.asset(assetPath, width: 28, height: 28)),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: _LoginScreenState.kPurple,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

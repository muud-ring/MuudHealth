import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color kPrimaryPurple = Color(0xFF5B288E);
  static const Color kLightPurple = Color(0xFFCBB6E6);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 26),

              // Logo (SVG)
              Center(
                child: SvgPicture.asset(
                  'assets/logo/muudLogoLogin.svg', // ✅ correct path
                  width: 190,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Email address',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(color: Colors.black38),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: _border(Colors.black26),
                  focusedBorder: _border(kPrimaryPurple),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Password',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: Colors.black38),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: _border(Colors.black26),
                  focusedBorder: _border(kPrimaryPurple),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot username or password?',
                    style: TextStyle(
                      fontSize: 13,
                      color: kPrimaryPurple,
                      decoration: TextDecoration.underline,
                      decorationColor: kPrimaryPurple,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kLightPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1, color: Colors.black12)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1, color: Colors.black12)),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialIconButton(assetPath: 'assets/icons/googleIcon.png'),
                  SizedBox(width: 14),
                  _SocialIconButton(assetPath: 'assets/icons/appleIcon.png'),
                  SizedBox(width: 14),
                  _SocialIconButton(assetPath: 'assets/icons/facebookIcon.png'),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimaryPurple, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Join MUUD Today',
                    style: TextStyle(
                      color: kPrimaryPurple,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Column(
                children: const [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [
                      _FooterLink(text: 'Privacy Policy'),
                      Text(
                        '|',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      _FooterLink(text: 'Terms of Use'),
                    ],
                  ),
                  SizedBox(height: 6),
                  _FooterLink(text: 'HIPAA Notice'),
                ],
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String assetPath;

  const _SocialIconButton({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 4),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Center(child: Image.asset(assetPath, width: 22, height: 22)),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black45,
          decoration: TextDecoration.underline,
          decorationColor: Colors.black26,
        ),
      ),
    );
  }
}

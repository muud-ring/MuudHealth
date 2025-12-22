import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';
import '../../services/post_auth_redirect.dart';

class OnboardingPage08 extends StatefulWidget {
  const OnboardingPage08({super.key});

  @override
  State<OnboardingPage08> createState() => _OnboardingPage08State();
}

class _OnboardingPage08State extends State<OnboardingPage08> {
  static const Color kPurple = Color(0xFF5B288E);

  bool loading = false;
  String? error;

  // Placeholder toggles (UI only)
  bool done1 = true;
  bool done2 = true;
  bool done3 = false;

  Future<void> _completeSetup() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await OnboardingApi.saveOnboarding(
        favoriteColor: OnboardingState.answers.favoriteColor,
        focusGoal: OnboardingState.answers.focusGoal.isEmpty
            ? "Other"
            : OnboardingState.answers.focusGoal,
        activities: OnboardingState.answers.activities,
        notificationsEnabled: OnboardingState.answers.notificationsEnabled,
        completed: true,
      );

      if (!mounted) return;
      await PostAuthRedirect.go(context);
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back, color: kPurple),
                onPressed: loading ? null : () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),

              const Text(
                "Just a moment while we get\nMUUD ready for you…",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Thank you for your patience :) We’re here to\nhelp you feel better.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: Color(0xFF6B6B6B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),

              _CheckRow(
                checked: done1,
                text: "Customize journal and journey",
                onTap: loading ? null : () => setState(() => done1 = !done1),
              ),
              const SizedBox(height: 12),
              _CheckRow(
                checked: done2,
                text: "Prepare your first wellness sessions",
                onTap: loading ? null : () => setState(() => done2 = !done2),
              ),
              const SizedBox(height: 12),
              _CheckRow(
                checked: done3,
                text: "Creating your optimal plan to enhance your mood",
                onTap: loading ? null : () => setState(() => done3 = !done3),
              ),

              if (error != null) ...[
                const SizedBox(height: 14),
                Text(
                  error!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: loading ? null : _completeSetup,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Complete setup",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
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

class _CheckRow extends StatelessWidget {
  final bool checked;
  final String text;
  final VoidCallback? onTap;

  const _CheckRow({
    required this.checked,
    required this.text,
    required this.onTap,
  });

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFFF4EAFB) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPurple.withOpacity(0.65), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPurple, width: 2),
                color: checked ? kPurple : Colors.transparent,
              ),
              child: checked
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

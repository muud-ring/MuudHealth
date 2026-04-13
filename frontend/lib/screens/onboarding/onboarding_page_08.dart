import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/onboarding_state.dart';
import '../../services/post_auth_redirect.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage08 extends StatefulWidget {
  const OnboardingPage08({super.key});

  @override
  State<OnboardingPage08> createState() => _OnboardingPage08State();
}

class _OnboardingPage08State extends State<OnboardingPage08> {
  bool loading = false;
  String? error;

  // Multi-selection toggles
  final Set<String> selectedOptions = {};

  final List<String> options = const [
    "Customize journal and journey",
    "Prepare your first wellness sessions",
    "Creating your optimal plan to enhance your mood",
  ];

  void _toggleOption(String option) {
    if (loading) return;
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option);
      } else {
        selectedOptions.add(option);
      }
    });
  }

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
    final hasSelection = selectedOptions.isNotEmpty;

    return Scaffold(
      backgroundColor: MuudColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: MuudColors.purple,
                  size: 22,
                ),
                onPressed: loading ? null : () => context.pop(),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                "Just a moment while we get\nMUUD ready for you...",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: MuudColors.purple,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                "Thank you for your patience :) We're here to\nhelp you feel better.",
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: MuudColors.purple,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Options list
              ...options.map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CheckRow(
                    checked: selectedOptions.contains(option),
                    text: option,
                    onTap: () => _toggleOption(option),
                  ),
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  style: const TextStyle(
                    color: MuudColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const Spacer(),

              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MuudColors.purple.withValues(alpha:
                      hasSelection ? 1 : 0.5,
                    ),
                    foregroundColor: MuudColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: MuudRadius.pillAll,
                    ),
                    elevation: 0,
                  ),
                  onPressed: loading ? null : _completeSetup,
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: MuudColors.white,
                          ),
                        )
                      : Text(
                          hasSelection ? "Complete setup" : "Continue",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: MuudColors.white,
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
  final VoidCallback onTap;

  const _CheckRow({
    required this.checked,
    required this.text,
    required this.onTap,
  });
  static const Color kSelectedBg = Color(0xFFF5E6FA);
  static const Color kSelectedBorder = Color(0xFFE8B4F8);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: MuudRadius.lgAll,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: checked ? kSelectedBg : const Color(0xFFF5F5F5),
          borderRadius: MuudRadius.lgAll,
          border: checked
              ? Border.all(color: kSelectedBorder, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: MuudColors.purple, width: 2),
                color: checked ? MuudColors.purple : Colors.transparent,
              ),
              child: checked
                  ? const Icon(Icons.check, color: MuudColors.white, size: 18)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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

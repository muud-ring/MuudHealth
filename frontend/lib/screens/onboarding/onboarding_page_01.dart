import 'package:flutter/material.dart';
import '../../services/onboarding_state.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class OnboardingPage01 extends StatelessWidget {
  const OnboardingPage01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MuudColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow (top-left)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: MuudColors.purple,
                    size: 22,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),

              const SizedBox(height: 32),

              // Title (bold)
              const Text(
                "MUUD Health",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: MuudColors.purple,
                  height: 1.1,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              const Text(
                "Develop healthy habits and\nnurture your mental\nwell-being.",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: MuudColors.purple,
                  height: 1.25,
                  letterSpacing: 0,
                ),
              ),

              // Illustration centered in remaining space
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Image.asset(
                      'assets/images/onboarding/onboarding01.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Bottom button (pill shape, full width)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MuudColors.purple,
                    foregroundColor: MuudColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: MuudRadius.pillAll,
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // ✅ DO NOT change logic
                    OnboardingState.reset();
                    context.push(Routes.onboarding('02'));
                  },
                  child: const Text(
                    "Next",
                    style: TextStyle(
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

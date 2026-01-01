import 'package:flutter/material.dart';
import '../../services/onboarding_state.dart';

class OnboardingPage01 extends StatelessWidget {
  const OnboardingPage01({super.key});

  static const Color kPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back arrow
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          alignment: Alignment.centerLeft,
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: kPurple,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),

                        const SizedBox(height: 28),

                        // Title
                        const Text(
                          "MUUD Health",
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: kPurple,
                            height: 1.05,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Subtitle
                        const Text(
                          "Develop healthy habits and\nnurture your mental\nwell-being.",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: kPurple,
                            height: 1.16,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Illustration (centered, constrained)
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 360,
                              // Use available height safely
                              maxHeight: (constraints.maxHeight * 0.38).clamp(
                                220.0,
                                320.0,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/onboarding/onboarding01.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // This pushes the button to the bottom when there is extra space.
                        const Expanded(child: SizedBox()),

                        // Next button
                        SizedBox(
                          width: double.infinity,
                          height: 62,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPurple,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // ✅ DO NOT change logic
                              OnboardingState.reset();
                              Navigator.pushNamed(context, '/onboarding/02');
                            },
                            child: const Text(
                              "Next",
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
              ),
            );
          },
        ),
      ),
    );
  }
}

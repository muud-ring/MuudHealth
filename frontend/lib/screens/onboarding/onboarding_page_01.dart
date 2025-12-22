import 'package:flutter/material.dart';

class OnboardingPage01 extends StatelessWidget {
  const OnboardingPage01({super.key});

  static const Color kPurple = Color(0xFF5B288E);

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
              // back
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back, color: kPurple),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 18),

              const Text(
                "MUUD Health",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Develop healthy habits and\nnurture your mental\nwell-being.",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kPurple,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              // Placeholder for the illustration
              Expanded(
                child: Center(
                  child: Container(
                    height: 260,
                    width: 260,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Illustration",
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Next onboarding page will be /onboarding/02
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
    );
  }
}

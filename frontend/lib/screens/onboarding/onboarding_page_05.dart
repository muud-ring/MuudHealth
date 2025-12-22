import 'package:flutter/material.dart';
import '../../services/onboarding_state.dart';

class OnboardingPage05 extends StatelessWidget {
  const OnboardingPage05({super.key});

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
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back, color: kPurple),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Text("Alarm illustration placeholder"),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Center(
                child: Text(
                  "MUUD wants to send you\nnotifications",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: kPurple,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "MUUD’s notifications will remind you to log\nyour journal/journey.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w500,
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
                    // Later you can request OS permission here.
                    OnboardingState.answers.notificationsEnabled =
                        true; // ✅ store
                    Navigator.pushNamed(context, '/onboarding/06');
                  },
                  child: const Text(
                    "Allow notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPurple),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () {
                    OnboardingState.answers.notificationsEnabled =
                        false; // ✅ store
                    Navigator.pushNamed(context, '/onboarding/06');
                  },
                  child: const Text(
                    "No thanks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: kPurple,
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

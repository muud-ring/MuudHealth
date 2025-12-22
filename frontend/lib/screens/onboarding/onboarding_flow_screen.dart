import 'package:flutter/material.dart';
import '../../services/onboarding_api.dart';
import '../../services/post_auth_redirect.dart'; // ✅ ADD THIS

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  static const Color kPurple = Color(0xFF5B288E);

  // --- onboarding answers
  String favoriteColor = "purple";
  String focusGoal = "";
  final List<String> selectedActivities = [];
  bool notificationsEnabled = false;

  bool loading = false;
  String? error;

  final List<String> goalOptions = const [
    "Improve mood",
    "Increase focus and productivity",
    "Self-improvement",
    "Reduce stress or anxiety",
    "Other",
  ];

  final List<String> activityOptions = const [
    "Meditation",
    "Exercise",
    "Reading",
    "Cooking",
    "Social",
    "Pet care",
  ];

  void toggleActivity(String a) {
    setState(() {
      if (selectedActivities.contains(a)) {
        selectedActivities.remove(a);
      } else {
        selectedActivities.add(a);
      }
    });
  }

  Future<void> _save({required bool completed}) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // ✅ Save onboarding to backend
      await OnboardingApi.saveOnboarding(
        favoriteColor: favoriteColor,
        focusGoal: focusGoal,
        activities: selectedActivities,
        notificationsEnabled: notificationsEnabled,
        completed: completed,
      );

      if (!mounted) return;

      // ✅ CENTRALIZED redirect (DO NOT push /home directly)
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Setup", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: loading ? null : () => _save(completed: false),
            child: const Text(
              "Skip",
              style: TextStyle(
                color: kPurple,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "1) Choose your goal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: goalOptions.map((g) {
                final selected = focusGoal == g;
                return ChoiceChip(
                  label: Text(g),
                  selected: selected,
                  onSelected: (_) => setState(() => focusGoal = g),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text(
              "2) Pick activities you like",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: activityOptions.map((a) {
                final selected = selectedActivities.contains(a);
                return FilterChip(
                  label: Text(a),
                  selected: selected,
                  onSelected: (_) => toggleActivity(a),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text(
              "3) Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SwitchListTile(
              value: notificationsEnabled,
              onChanged: (v) => setState(() => notificationsEnabled = v),
              title: const Text("Enable notifications"),
            ),

            const SizedBox(height: 18),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),

            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                onPressed: loading ? null : () => _save(completed: true),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
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
    );
  }
}

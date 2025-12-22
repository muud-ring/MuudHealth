class OnboardingAnswers {
  String favoriteColor = "purple";
  String focusGoal = "";
  List<String> activities = [];
  bool notificationsEnabled = false;

  // Optional: from Page 07 (first check-in)
  String firstMood = "";

  void reset() {
    favoriteColor = "purple";
    focusGoal = "";
    activities = [];
    notificationsEnabled = false;
    firstMood = "";
  }
}

import '../models/onboarding_answers.dart';

class OnboardingState {
  static final OnboardingAnswers answers = OnboardingAnswers();

  static void reset() => answers.reset();
}

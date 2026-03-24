import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/onboarding_answers.dart';

void main() {
  group('OnboardingAnswers', () => {
    test('default values are correct', () {
      final answers = OnboardingAnswers();

      expect(answers.favoriteColor, 'purple');
      expect(answers.focusGoal, '');
      expect(answers.activities, isEmpty);
      expect(answers.notificationsEnabled, false);
      expect(answers.firstMood, '');
    });

    test('reset restores all defaults', () {
      final answers = OnboardingAnswers()
        ..favoriteColor = 'blue'
        ..focusGoal = 'wellness'
        ..activities = ['running', 'yoga']
        ..notificationsEnabled = true
        ..firstMood = 'happy';

      answers.reset();

      expect(answers.favoriteColor, 'purple');
      expect(answers.focusGoal, '');
      expect(answers.activities, isEmpty);
      expect(answers.notificationsEnabled, false);
      expect(answers.firstMood, '');
    });

    test('fields can be modified independently', () {
      final answers = OnboardingAnswers();

      answers.favoriteColor = 'green';
      expect(answers.favoriteColor, 'green');
      expect(answers.focusGoal, ''); // unchanged

      answers.activities = ['meditation'];
      expect(answers.activities, ['meditation']);
      expect(answers.notificationsEnabled, false); // unchanged
    });

    test('activities list is mutable', () {
      final answers = OnboardingAnswers();

      answers.activities.add('swimming');
      expect(answers.activities, contains('swimming'));

      answers.activities.add('running');
      expect(answers.activities.length, 2);
    });
  });
}

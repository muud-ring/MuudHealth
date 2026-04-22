import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muud_health_app/theme/app_theme.dart';

void main() {
  group('AppTheme colors', () {
    test('purple is the correct brand color', () {
      expect(AppTheme.purple, const Color(0xFF5B288E));
    });

    test('greyText is the correct grey', () {
      expect(AppTheme.greyText, const Color(0xFF898384));
    });

    test('lightGrey is defined', () {
      expect(AppTheme.lightGrey, const Color(0xFFB7B1B3));
    });

    test('lightPurple is defined', () {
      expect(AppTheme.lightPurple, const Color(0xFFC9B7E6));
    });

    test('error color is brand red', () {
      // AppTheme.error = MuudColors.error = Color(0xFFD50101)
      expect(AppTheme.error, const Color(0xFFD50101));
    });
  });

  group('AppTheme text styles', () {
    test('headingLarge uses purple and bold', () {
      expect(AppTheme.headingLarge.color, AppTheme.purple);
      expect(AppTheme.headingLarge.fontSize, 24);
      expect(AppTheme.headingLarge.fontWeight, FontWeight.w700);
    });

    test('headingMedium uses purple and bold', () {
      // MuudTypography.headingMedium: fontSize 20, w600
      expect(AppTheme.headingMedium.color, AppTheme.purple);
      expect(AppTheme.headingMedium.fontSize, 20);
      expect(AppTheme.headingMedium.fontWeight, FontWeight.w600);
    });

    test('bodyText color matches MuudColors.bodyText', () {
      // MuudTypography.bodyMedium: color = MuudColors.bodyText = Color(0xFF4A4A4A)
      expect(AppTheme.bodyText.color, const Color(0xFF4A4A4A));
      expect(AppTheme.bodyText.fontSize, 14);
    });

    test('captionText uses greyText', () {
      expect(AppTheme.captionText.color, AppTheme.greyText);
      expect(AppTheme.captionText.fontSize, 12);
    });
  });

  group('AppTheme lightTheme', () {
    test('uses Material 3', () {
      expect(AppTheme.lightTheme.useMaterial3, true);
    });

    test('primary color is purple', () {
      expect(AppTheme.lightTheme.colorScheme.primary, AppTheme.purple);
    });

    test('scaffold background is white', () {
      expect(AppTheme.lightTheme.scaffoldBackgroundColor, AppTheme.white);
    });

    test('bottom nav selected color is purple', () {
      expect(
        AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
        AppTheme.purple,
      );
    });

    test('bottom nav unselected color is greyText', () {
      expect(
        AppTheme.lightTheme.bottomNavigationBarTheme.unselectedItemColor,
        AppTheme.greyText,
      );
    });
  });
}

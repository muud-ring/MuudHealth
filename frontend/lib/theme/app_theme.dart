import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color purple = Color(0xFF5B288E);
  static const Color greyText = Color(0xFF898384);
  static const Color white = Colors.white;
  static const Color error = Colors.red;
  static const Color darkText = Color(0xFF2D2D2D);
  static const Color lightGrey = Color(0xFFB7B1B3);
  static const Color lightPurple = Color(0xFFC9B7E6);

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    color: purple,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headingMedium = TextStyle(
    color: purple,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle bodyText = TextStyle(
    color: Colors.black87,
    fontSize: 14,
  );

  static const TextStyle captionText = TextStyle(
    color: greyText,
    fontSize: 12,
  );

  // ThemeData for MaterialApp
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        primary: purple,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: purple,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: purple,
        unselectedItemColor: greyText,
        backgroundColor: white,
        type: BottomNavigationBarType.fixed,
      ),
      scaffoldBackgroundColor: white,
    );
  }
}

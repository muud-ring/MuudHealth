// MUUD Health — PDS 2.0 Design System
// Psychiatry-led mental fitness platform combining care, coaching, and technology.
// © Muud Health — Armin Hoes, MD

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────────────────────────────────────

class MuudColors {
  MuudColors._();

  // ── Primary Brand ──────────────────────────────────────────────────────
  static const Color purple       = Color(0xFF5B288E);
  static const Color darkPurple   = Color(0xFF4F176E);
  static const Color lightPurple  = Color(0xFFC9B7E6);
  static const Color palePurple   = Color(0xFFEDE5F6);

  // ── Secondary ──────────────────────────────────────────────────────────
  static const Color magenta      = Color(0xFFAE00B1);
  static const Color accentBlue   = Color(0xFF007AFF);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF33B679);
  static const Color error        = Color(0xFFD50101);
  static const Color warning      = Color(0xFFF6BF25);
  static const Color info         = Color(0xFF007AFF);

  // ── Neutrals ───────────────────────────────────────────────────────────
  static const Color black        = Color(0xFF0A0A0B);
  static const Color darkText     = Color(0xFF2D2D2D);
  static const Color bodyText     = Color(0xFF4A4A4A);
  static const Color greyText     = Color(0xFF898384);
  static const Color neutral600   = Color(0xFF726C6C);
  static const Color lightGrey    = Color(0xFFB7B1B3);
  static const Color divider      = Color(0xFFE0DCDC);
  static const Color background   = Color(0xFFF2F0E8);
  static const Color surface      = Color(0xFFFAFAFA);
  static const Color white        = Color(0xFFFFFFFF);

  // ── Signal Pathway (SCA-IPA-BGA-SCA Ring) ──────────────────────────────
  static const Color signal       = Color(0xFF5B288E); // S — detect
  static const Color connect      = Color(0xFF7B52AB); // C
  static const Color action       = Color(0xFFAE00B1); // A
  static const Color insight      = Color(0xFF007AFF); // I — customer output
  static const Color plan         = Color(0xFF33B679); // P
  static const Color achieve      = Color(0xFF2E9E6E); // A
  static const Color build_       = Color(0xFFF6BF25); // B — internal
  static const Color grow         = Color(0xFFE8A517); // G
  static const Color advance      = Color(0xFFD4900A); // A
  static const Color sustain      = Color(0xFFD50101); // S — compound
  static const Color collaborate  = Color(0xFFAA0101); // C
  static const Color accelerate   = Color(0xFF880101); // A

  // ── Biometrics ─────────────────────────────────────────────────────────
  static const Color heartRate    = Color(0xFFE74C3C);
  static const Color hrv          = Color(0xFF9B59B6);
  static const Color spo2         = Color(0xFF3498DB);
  static const Color temperature  = Color(0xFFE67E22);
  static const Color sleep        = Color(0xFF2C3E50);
  static const Color steps        = Color(0xFF27AE60);
  static const Color stress       = Color(0xFFF39C12);

  // ── MUUD Notes (12-emoji ring dial) ────────────────────────────────────
  static const Color noteJoy      = Color(0xFFFFC107);
  static const Color noteLove     = Color(0xFFE91E63);
  static const Color noteCalm     = Color(0xFF4CAF50);
  static const Color noteHope     = Color(0xFF03A9F4);
  static const Color noteGrit     = Color(0xFFFF5722);
  static const Color noteFocus    = Color(0xFF673AB7);
  static const Color noteSad      = Color(0xFF607D8B);
  static const Color noteAnxious  = Color(0xFFFF9800);
  static const Color noteAngry    = Color(0xFFF44336);
  static const Color noteTired    = Color(0xFF795548);
  static const Color noteLonely   = Color(0xFF9E9E9E);
  static const Color noteUnsure   = Color(0xFF00BCD4);
}

// ─────────────────────────────────────────────────────────────────────────────
// SPACING TOKENS
// ─────────────────────────────────────────────────────────────────────────────

class MuudSpacing {
  MuudSpacing._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
}

// ─────────────────────────────────────────────────────────────────────────────
// RADIUS TOKENS
// ─────────────────────────────────────────────────────────────────────────────

class MuudRadius {
  MuudRadius._();

  static const double sm   = 6;
  static const double md   = 10;
  static const double lg   = 14;
  static const double xl   = 20;
  static const double pill = 999;

  static BorderRadius get smAll   => BorderRadius.circular(sm);
  static BorderRadius get mdAll   => BorderRadius.circular(md);
  static BorderRadius get lgAll   => BorderRadius.circular(lg);
  static BorderRadius get xlAll   => BorderRadius.circular(xl);
  static BorderRadius get pillAll => BorderRadius.circular(pill);
}

// ─────────────────────────────────────────────────────────────────────────────
// ELEVATION / SHADOW TOKENS
// ─────────────────────────────────────────────────────────────────────────────

class MuudShadows {
  MuudShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get bottomNav => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, -6),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// TYPOGRAPHY
// ─────────────────────────────────────────────────────────────────────────────

class MuudTypography {
  MuudTypography._();

  static const String _fontFamily = 'SF Pro Display';

  // ── Display ────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: MuudColors.purple,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: MuudColors.purple,
    height: 1.25,
  );

  // ── Heading ────────────────────────────────────────────────────────────
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: MuudColors.purple,
    height: 1.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: MuudColors.purple,
    height: 1.35,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: MuudColors.darkText,
    height: 1.35,
  );

  // ── Title ──────────────────────────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: MuudColors.darkText,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: MuudColors.darkText,
    height: 1.4,
  );

  // ── Body ───────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: MuudColors.bodyText,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: MuudColors.bodyText,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: MuudColors.greyText,
    height: 1.5,
  );

  // ── Caption / Label ────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: MuudColors.greyText,
    height: 1.3,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: MuudColors.greyText,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: MuudColors.white,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // ── Metric / Data Display ─────────────────────────────────────────────
  static const TextStyle metricLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: MuudColors.purple,
    height: 1.1,
  );

  static const TextStyle metricMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: MuudColors.darkText,
    height: 1.2,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: MuudColors.darkText,
    height: 1.2,
  );

  static const TextStyle metricUnit = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: MuudColors.greyText,
    height: 1.3,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BACKWARD-COMPAT ALIAS (migrate call-sites incrementally)
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // Legacy color aliases — prefer MuudColors directly
  static const Color purple      = MuudColors.purple;
  static const Color greyText    = MuudColors.greyText;
  static const Color white       = MuudColors.white;
  static const Color error       = MuudColors.error;
  static const Color darkText    = MuudColors.darkText;
  static const Color lightGrey   = MuudColors.lightGrey;
  static const Color lightPurple = MuudColors.lightPurple;

  // Legacy text style aliases
  static const TextStyle headingLarge  = MuudTypography.headingLarge;
  static const TextStyle headingMedium = MuudTypography.headingMedium;
  static const TextStyle bodyText      = MuudTypography.bodyMedium;
  static const TextStyle captionText   = MuudTypography.caption;

  // ── ThemeData ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: ColorScheme.fromSeed(
        seedColor: MuudColors.purple,
        primary: MuudColors.purple,
        secondary: MuudColors.magenta,
        error: MuudColors.error,
        surface: MuudColors.white,
        onPrimary: MuudColors.white,
        onSecondary: MuudColors.white,
        onError: MuudColors.white,
        onSurface: MuudColors.darkText,
      ),

      scaffoldBackgroundColor: MuudColors.white,

      // ── AppBar ───────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: MuudColors.white,
        foregroundColor: MuudColors.purple,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: MuudTypography.headingMedium,
        iconTheme: IconThemeData(color: MuudColors.purple),
      ),

      // ── Bottom Nav ───────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: MuudColors.purple,
        unselectedItemColor: MuudColors.greyText,
        backgroundColor: MuudColors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // ── Card ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: MuudColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: MuudRadius.lgAll),
        margin: const EdgeInsets.symmetric(
          horizontal: MuudSpacing.base,
          vertical: MuudSpacing.sm,
        ),
      ),

      // ── Elevated Button ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MuudColors.purple,
          foregroundColor: MuudColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: MuudSpacing.xl,
            vertical: MuudSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: MuudRadius.lgAll),
          textStyle: MuudTypography.button,
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MuudColors.purple,
          side: const BorderSide(color: MuudColors.purple, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: MuudSpacing.xl,
            vertical: MuudSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: MuudRadius.lgAll),
          textStyle: MuudTypography.button.copyWith(color: MuudColors.purple),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MuudColors.purple,
          textStyle: MuudTypography.titleMedium.copyWith(color: MuudColors.purple),
        ),
      ),

      // ── Input (TextField) ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MuudColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MuudSpacing.base,
          vertical: MuudSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: MuudRadius.mdAll,
          borderSide: const BorderSide(color: MuudColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: MuudRadius.mdAll,
          borderSide: const BorderSide(color: MuudColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: MuudRadius.mdAll,
          borderSide: const BorderSide(color: MuudColors.purple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: MuudRadius.mdAll,
          borderSide: const BorderSide(color: MuudColors.error),
        ),
        hintStyle: MuudTypography.bodyMedium.copyWith(color: MuudColors.lightGrey),
        labelStyle: MuudTypography.caption,
        errorStyle: MuudTypography.caption.copyWith(color: MuudColors.error),
      ),

      // ── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: MuudColors.palePurple,
        selectedColor: MuudColors.purple,
        labelStyle: MuudTypography.caption.copyWith(color: MuudColors.purple),
        shape: RoundedRectangleBorder(borderRadius: MuudRadius.pillAll),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: MuudSpacing.md,
          vertical: MuudSpacing.xs,
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: MuudColors.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: MuudColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(MuudRadius.xl),
            topRight: Radius.circular(MuudRadius.xl),
          ),
        ),
      ),

      // ── Dialog ───────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: MuudColors.white,
        shape: RoundedRectangleBorder(borderRadius: MuudRadius.xlAll),
        titleTextStyle: MuudTypography.headingSmall,
        contentTextStyle: MuudTypography.bodyMedium,
      ),

      // ── Floating Action Button ───────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MuudColors.purple,
        foregroundColor: MuudColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Tab Bar ──────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: MuudColors.purple,
        unselectedLabelColor: MuudColors.greyText,
        indicatorColor: MuudColors.purple,
        labelStyle: MuudTypography.titleMedium,
        unselectedLabelStyle: MuudTypography.bodyMedium,
      ),

      // ── Snackbar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: MuudColors.darkText,
        contentTextStyle: MuudTypography.bodyMedium.copyWith(color: MuudColors.white),
        shape: RoundedRectangleBorder(borderRadius: MuudRadius.mdAll),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colour palette
class AppColors {
  AppColors._();

  // Brand
  static const primary        = Color(0xFF2D6BE4);
  static const primaryLight   = Color(0xFF5B8FF5);
  static const primaryDark    = Color(0xFF1A4DB8);
  static const primarySurface = Color(0xFFEEF3FF);

  // Accent (tutors = warm amber)
  static const accent         = Color(0xFFF59E0B);
  static const accentSurface  = Color(0xFFFFFBEB);

  // Semantic
  static const success        = Color(0xFF10B981);
  static const successSurface = Color(0xFFECFDF5);
  static const error          = Color(0xFFEF4444);
  static const errorSurface   = Color(0xFFFEF2F2);
  static const warning        = Color(0xFFF59E0B);

  // Neutral scale
  static const grey50  = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey700 = Color(0xFF374151);
  static const grey800 = Color(0xFF1F2937);
  static const grey900 = Color(0xFF111827);

  // Surface
  static const white      = Color(0xFFFFFFFF);
  static const background = Color(0xFFF9FAFB);
}

// Text styles 
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.dmSerifDisplay(
    fontSize: 40, fontWeight: FontWeight.w400, color: AppColors.grey900,
    height: 1.1, letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.dmSerifDisplay(
    fontSize: 32, fontWeight: FontWeight.w400, color: AppColors.grey900,
    height: 1.15, letterSpacing: -0.3,
  );

  static TextStyle get headlineLarge => GoogleFonts.dmSerifDisplay(
    fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.grey900,
    height: 1.2,
  );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.grey900,
    height: 1.3,
  );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.grey900,
    height: 1.4,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.grey800,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.grey700,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.grey600,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.grey500,
    height: 1.5,
  );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey700,
    height: 1.4, letterSpacing: 0.1,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey500,
    height: 1.4, letterSpacing: 0.5,
  );
}

// ─── Spacing ───────────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 40;
  static const double huge = 56;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 24);
}

//  Radius 
class AppRadius {
  AppRadius._();

  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 28;
  static const double full = 999;

  static BorderRadius get smAll   => BorderRadius.circular(sm);
  static BorderRadius get mdAll   => BorderRadius.circular(md);
  static BorderRadius get lgAll   => BorderRadius.circular(lg);
  static BorderRadius get xlAll   => BorderRadius.circular(xl);
  static BorderRadius get xxlAll  => BorderRadius.circular(xxl);
  static BorderRadius get fullAll => BorderRadius.circular(full);
}

// ─── Shadows ───────────────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: AppColors.grey900.withOpacity(0.06),
      blurRadius: 8, offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: AppColors.grey900.withOpacity(0.08),
      blurRadius: 16, offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: AppColors.grey900.withOpacity(0.10),
      blurRadius: 32, offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get primary => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.30),
      blurRadius: 20, offset: const Offset(0, 6),
    ),
  ];
}

// Theme data
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.white,
      background: AppColors.background,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.grey800),
      titleTextStyle: AppTextStyles.titleMedium,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14, color: AppColors.grey400,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14, color: AppColors.grey600,
      ),
      errorStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12, color: AppColors.error,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.grey100, thickness: 1, space: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey100,
      selectedColor: AppColors.primarySurface,
      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey400,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VeriFi Design System Colors
class VeriFiColors {
  /// Primary Color: VeriFi Blue
  static const Color primary = Color(0xFF2563EB);

  /// Secondary Colors
  static const Color secondaryEE = Color(0xFFEEF2FF);
  static const Color secondaryDC = Color(0xFFDCE4FF);
  static const Color secondaryF8 = Color(0xFFF8FAFC);

  /// Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  /// Neutral Colors
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF4B5563);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
}

/// VeriFi Design System Border Radii
class VeriFiBorderRadius {
  static const double cards = 20.0;
  static const double buttons = 16.0;
  static const double inputs = 14.0;
  static const double modals = 24.0;

  static BorderRadius get cardsRadius => BorderRadius.circular(cards);
  static BorderRadius get buttonsRadius => BorderRadius.circular(buttons);
  static BorderRadius get inputsRadius => BorderRadius.circular(inputs);
  static BorderRadius get modalsRadius => BorderRadius.circular(modals);
}

/// VeriFi Design System Spacing (8-point grid)
class VeriFiSpacing {
  static const double s8 = 8.0;
  static const double s16 = 16.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
}

/// VeriFi Design System Typography
class VeriFiTypography {
  /// Headers
  static TextStyle get pageTitle => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: VeriFiColors.textDark,
      );

  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: VeriFiColors.textDark,
      );

  /// Body Text
  static TextStyle get bodyText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: VeriFiColors.textGrey,
      );

  /// Labels
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: VeriFiColors.textLight,
      );
}

/// VeriFi Central Theme Configuration
class VeriFiTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: VeriFiColors.background,
      colorScheme: const ColorScheme.light(
        primary: VeriFiColors.primary,
        secondary: VeriFiColors.secondaryDC,
        surface: VeriFiColors.surface,
        error: VeriFiColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: VeriFiColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: VeriFiTypography.sectionTitle,
        iconTheme: const IconThemeData(color: VeriFiColors.textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VeriFiColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: VeriFiBorderRadius.buttonsRadius,
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: VeriFiColors.primary,
          side: const BorderSide(color: VeriFiColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: VeriFiBorderRadius.buttonsRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VeriFiColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: VeriFiSpacing.s16,
          vertical: VeriFiSpacing.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: VeriFiBorderRadius.inputsRadius,
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: VeriFiBorderRadius.inputsRadius,
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: VeriFiBorderRadius.inputsRadius,
          borderSide: const BorderSide(color: VeriFiColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: VeriFiBorderRadius.inputsRadius,
          borderSide: const BorderSide(color: VeriFiColors.error),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme.dark(
        primary: VeriFiColors.primary,
        secondary: Color(0xFF1E293B),
        surface: Color(0xFF1E293B),
        error: VeriFiColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: VeriFiTypography.sectionTitle.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VeriFiColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: VeriFiBorderRadius.buttonsRadius,
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: VeriFiColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: VeriFiBorderRadius.buttonsRadius,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

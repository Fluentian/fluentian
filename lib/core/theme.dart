import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fluentian Design System
class FluentianColors {
  // Primary
  static const Color primary = Color(0xFF6C3BF5);
  static const Color primaryLight = Color(0xFFA97EF9);
  static const Color primaryTint = Color(0xFFF3EEFF);
  static const Color primaryDark = Color(0xFF4E22D4);

  // Accent / XP (Formerly Orange, now Violet per strict guidelines)
  static const Color accent = Color(0xFF6C3BF5);
  static const Color accentTint = Color(0xFFF3EEFF);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successTint = Color(0xFFE8F9F0);
  static const Color error = Color(0xFFEF4444);
  static const Color errorTint = Color(0xFFFFF0F0);
  static const Color info = Color(0xFF6B7280);
  static const Color infoTint = Color(0xFFF3F4F6);

  // Dark nav
  static const Color darkNav = Color(0xFF1A0A2E);
  static const Color darkCard = Color(0xFF1E1040);
  static const Color darkBorder = Color(0xFF3D2A7A);

  // Neutrals
  static const Color textPrimary = Color(0xFF1A0A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Backgrounds
  static const Color pageBg = Color(0xFFF8F7FC);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  // Dark mode
  static const Color darkPageBg = Color(0xFF0E0B1A);
  static const Color darkCardBg = Color(0xFF1A1528);

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A0A2E), Color(0xFF3516A8)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6C3BF5), Color(0xFFA97EF9)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6C3BF5), Color(0xFF4E22D4)],
  );

  static const LinearGradient goldenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6C3BF5), Color(0xFFA97EF9)],
  );

  static const LinearGradient proGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3EEFF), Color(0xFFE8D9FD)],
  );
}

class FluentianSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class FluentianRadius {
  static const double chip = 8;
  static const double medium = 12;
  static const double card = 16;
  static const double large = 20;
  static const double pill = 50;
}

class FluentianShadows {
  static BoxShadow subtle = BoxShadow(
    color: const Color(0xFF6C3BF5).withValues(alpha: 0.08),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static BoxShadow card = BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );
}

class FluentianTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: FluentianColors.pageBg,
      colorScheme: const ColorScheme.light(
        primary: FluentianColors.primary,
        secondary: FluentianColors.accent,
        surface: FluentianColors.cardBg,
        error: FluentianColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: FluentianColors.textPrimary,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: FluentianColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: FluentianColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: FluentianColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: FluentianColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: FluentianColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: FluentianColors.textSecondary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: FluentianColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: FluentianColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: FluentianColors.white,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: FluentianColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FluentianColors.primary,
          foregroundColor: FluentianColors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FluentianRadius.medium),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FluentianColors.primary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: FluentianColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FluentianRadius.medium),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FluentianColors.white,
        foregroundColor: FluentianColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: FluentianColors.textPrimary,
        ),
      ),
    );
  }
}

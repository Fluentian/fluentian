import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fluentian Design System
class FluentianColors {
  // Primary
  static const Color primary = Color(0xFF0A3B6A);
  static const Color primaryDark = Color(0xFF072D52);
  static const Color primaryLight = Color(0xFF2C5E90);
  static const Color primaryTint = Color(0xFFEAF2F8);

  // Secondary / accent
  static const Color secondary = Color(0xFF259291);
  static const Color secondaryLight = Color(0xFF4CB8B3);
  static const Color secondaryTint = Color(0xFFE8F7F6);
  static const Color accent = Color(0xFF33C8C0);
  static const Color accentTint = Color(0xFFE7F9F8);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successTint = Color(0xFFE8F9F0);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningTint = Color(0xFFFFF7E6);
  static const Color error = Color(0xFFDC2626);
  static const Color errorTint = Color(0xFFFFF0F0);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoTint = Color(0xFFE8F7FD);

  // Dark nav
  static const Color darkNav = Color(0xFF072D52);
  static const Color darkCard = Color(0xFF0A3B6A);
  static const Color darkBorder = Color(0xFF2C5E90);

  // Neutrals
  static const Color textPrimary = Color(0xFF072D52);
  // Darkened from #6B7280 to clear WCAG AA (~7:1 on white / ~6.4:1 on pageBg)
  // for secondary/body text that previously sat right at the 4.5:1 edge.
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Backgrounds
  static const Color pageBg = Color(0xFFF5F8FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  // Dark mode
  static const Color darkPageBg = Color(0xFF041E36);
  static const Color darkCardBg = Color(0xFF072D52);

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF072D52), Color(0xFF0A3B6A)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0A3B6A), Color(0xFF2C5E90)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0A3B6A), Color(0xFF072D52)],
  );

  static const LinearGradient goldenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF259291), Color(0xFF33C8C0)],
  );

  static const LinearGradient proGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F7F6), Color(0xFFE7F9F8)],
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
    color: const Color(0xFF0A3B6A).withValues(alpha: 0.08),
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
        onPrimary: Colors.white,
        secondary: FluentianColors.secondary,
        onSecondary: FluentianColors.darkPageBg,
        surface: FluentianColors.cardBg,
        error: FluentianColors.error,
        onError: Colors.white,
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

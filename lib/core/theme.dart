import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fluentian Design System — "Press"
///
/// The old system had the four tells that make an app look machine-designed:
/// Inter everywhere, a soft blur shadow under every surface, five decorative
/// gradients, and twelve different corner radii used at random. This replaces
/// all four with one deliberate idea: **the app is printed, not rendered.**
///
///  · Flat colour only. No gradient inside any shape.
///  · Hard edges. Two radii exist — 0 for surfaces, pill for genuinely round
///    things. Nothing in between.
///  · Depth comes from a 1px rule and a hard offset, never from blur.
///  · Paper ground, ink text. Never pure white behind a page.
///
/// Every accent below was checked against the paper ground; the ratio is in
/// the comment. Anything under 4.5:1 is annotated as fill-only.
class FluentianColors {
  // ── Ink ───────────────────────────────────────────────
  /// Near-black navy. All body text, all contours.
  static const Color primary = Color(0xFF16233D); // 12.72:1 on paper
  static const Color primaryDark = Color(0xFF0E1726);
  static const Color primaryLight = Color(0xFF3A4661);
  static const Color primaryTint = Color(0xFFDDDFE4);

  // ── Secondary: deep teal, not the old startup cyan ────
  static const Color secondary = Color(0xFF0E5C58); // 6.35:1
  static const Color secondaryLight = Color(0xFF1B7C77);
  static const Color secondaryTint = Color(0xFFD8E4E3);
  static const Color accent = Color(0xFF1B4FBF); // 5.85:1 — the French blue
  static const Color accentTint = Color(0xFFDADEEF);

  // ── Semantic ──────────────────────────────────────────
  // success and error are 1.53:1 apart in luminance, so they stay
  // distinguishable in greyscale and for red-green colour deficiency. They
  // must still always be paired with an icon or a position — never colour
  // alone. Any change to these two has to preserve that separation.
  static const Color success = Color(0xFF0A5637); // 7.12:1
  static const Color successTint = Color(0xFFD5E2DB);
  static const Color warning = Color(0xFF7F5200); // 5.49:1
  static const Color warningTint = Color(0xFFEDE4CF);
  static const Color error = Color(0xFFC0301A); // 4.64:1
  static const Color errorTint = Color(0xFFF0DCD8);
  static const Color info = Color(0xFF1B4FBF); // 5.85:1
  static const Color infoTint = Color(0xFFDADEEF);

  // ── Dark surfaces ─────────────────────────────────────
  static const Color darkNav = Color(0xFF0E1726);
  static const Color darkCard = Color(0xFF16233D);
  static const Color darkBorder = Color(0xFF2C3A55);

  // ── Type ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0E1726); // 14.60:1
  static const Color textSecondary = Color(0xFF4A4E57); // 6.78:1

  // ── Rules. Hairlines carry the structure the shadows used to fake.
  static const Color border = Color(0xFFC9C9C0);
  static const Color divider = Color(0xFFD8D8D1);

  // ── Grounds ───────────────────────────────────────────
  /// Uncoated paper. Deliberately not #FFFFFF and deliberately not cream.
  static const Color pageBg = Color(0xFFE8E8E2);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  static const Color darkPageBg = Color(0xFF0B121F);
  static const Color darkCardBg = Color(0xFF16233D);

  // ── "Gradients" ───────────────────────────────────────
  // Kept as named constants so the 22 existing call sites keep compiling, but
  // every one is now a flat fill: both stops are the same colour. A gradient
  // is the single fastest way to look generated, and `proGradient` used to
  // ramp between two near-identical off-whites, doing nothing at all.
  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0E1726), Color(0xFF0E1726)],
  );
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF16233D), Color(0xFF16233D)],
  );
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF16233D), Color(0xFF16233D)],
  );
  static const LinearGradient goldenGradient = LinearGradient(
    colors: [Color(0xFF7F5200), Color(0xFF7F5200)],
  );
  static const LinearGradient proGradient = LinearGradient(
    colors: [Color(0xFFE8E8E2), Color(0xFFE8E8E2)],
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

/// Two radii. `chip`, `medium`, `card` and `large` all resolve to the same
/// square edge on purpose — the old scale had five names for four
/// indistinguishable roundings, and screens ignored it and hand-rolled twelve
/// more. Keeping the names means no call site had to change.
class FluentianRadius {
  static const double chip = 0;
  static const double medium = 0;
  static const double card = 0;
  static const double large = 0;
  static const double pill = 999;
}

/// Letterpress offset, not a blur. A hard 2px shadow with zero blur reads as
/// something physically stacked on paper; an 8px soft blur reads as a
/// Material default nobody chose.
class FluentianShadows {
  static const BoxShadow subtle = BoxShadow(
    color: Color(0x1A0E1726),
    blurRadius: 0,
    offset: Offset(2, 2),
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x260E1726),
    blurRadius: 0,
    offset: Offset(3, 3),
  );
}

/// Hairline every surface shares, so cards read as objects without a shadow.
class FluentianBorders {
  static const BorderSide hairline = BorderSide(
    color: FluentianColors.border,
    width: 1,
  );
  static Border get all => const Border.fromBorderSide(hairline);
}

class FluentianTheme {
  // ── Type ──────────────────────────────────────────────
  // Bricolage Grotesque for anything that carries voice: it has real width and
  // optical-size variation, and it is not the face every generated interface
  // reaches for. IBM Plex Sans runs the body — a humanist face with actual
  // character in its terminals, excellent with French diacritics, and paired
  // with Noto Sans Ethiopic so Amharic renders rather than tofu.
  static TextStyle _display(double size, {FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: weight,
        height: 1.05,
        letterSpacing: -size * 0.02,
        color: color ?? FluentianColors.textPrimary,
      );

  static TextStyle _body(double size, {FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.ibmPlexSans(
        fontSize: size,
        fontWeight: weight,
        height: 1.45,
        color: color ?? FluentianColors.textSecondary,
      );

  /// Uppercase micro-label. Used for section eyebrows and data captions.
  static TextStyle label({Color? color, double size = 11}) =>
      GoogleFonts.ibmPlexMono(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: color ?? FluentianColors.textSecondary,
  );

  static List<String> get _fallbacks => [
    GoogleFonts.notoSansEthiopic().fontFamily ?? 'Noto Sans Ethiopic',
  ];

  static TextTheme _textTheme(Color heading, Color body) => TextTheme(
    displayLarge: _display(34, weight: FontWeight.w800, color: heading),
    displayMedium: _display(28, weight: FontWeight.w800, color: heading),
    headlineLarge: _display(25, color: heading),
    headlineMedium: _display(21, color: heading),
    titleLarge: _display(18, color: heading),
    titleMedium: _display(16, color: heading),
    bodyLarge: _body(16, color: body),
    bodyMedium: _body(14, color: body),
    bodySmall: _body(13, color: body),
    labelLarge: GoogleFonts.bricolageGrotesque(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: FluentianColors.white,
    ),
    labelSmall: label(color: body),
  ).apply(fontFamilyFallback: _fallbacks);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: FluentianColors.darkPageBg,
    colorScheme: const ColorScheme.dark(
      primary: FluentianColors.white,
      onPrimary: FluentianColors.darkPageBg,
      secondary: FluentianColors.secondaryLight,
      surface: FluentianColors.darkCardBg,
      onSurface: Colors.white,
      error: FluentianColors.error,
    ),
    textTheme: _textTheme(Colors.white, const Color(0xFFB9BDC6)),
    dividerColor: FluentianColors.darkBorder,
    appBarTheme: AppBarTheme(
      backgroundColor: FluentianColors.darkPageBg,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: _display(18, color: Colors.white),
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: FluentianColors.pageBg,
      colorScheme: const ColorScheme.light(
        primary: FluentianColors.primary,
        onPrimary: Colors.white,
        secondary: FluentianColors.secondary,
        onSecondary: Colors.white,
        surface: FluentianColors.cardBg,
        onSurface: FluentianColors.textPrimary,
        error: FluentianColors.error,
        onError: Colors.white,
      ),
      textTheme: _textTheme(FluentianColors.textPrimary, FluentianColors.textSecondary),
      dividerColor: FluentianColors.border,
      dividerTheme: const DividerThemeData(
        color: FluentianColors.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: const CardThemeData(
        color: FluentianColors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: FluentianBorders.hairline,
          borderRadius: BorderRadius.zero,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FluentianColors.primary,
          foregroundColor: FluentianColors.white,
          disabledBackgroundColor: FluentianColors.border,
          disabledForegroundColor: FluentianColors.textSecondary,
          minimumSize: const Size(double.infinity, 56),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FluentianColors.primary,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: FluentianColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FluentianColors.primary,
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FluentianColors.cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: FluentianBorders.hairline,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: FluentianBorders.hairline,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: FluentianColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: FluentianColors.error, width: 1.5),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: FluentianColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(color: FluentianColors.textSecondary),
        hintStyle: GoogleFonts.ibmPlexSans(color: FluentianColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FluentianColors.pageBg,
        foregroundColor: FluentianColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _display(18),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FluentianColors.primaryDark,
        contentTextStyle: GoogleFonts.ibmPlexSans(color: Colors.white, fontSize: 14),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: FluentianColors.cardBg,
        side: FluentianBorders.hairline,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        labelStyle: GoogleFonts.ibmPlexSans(fontSize: 13),
      ),
    );
  }
}

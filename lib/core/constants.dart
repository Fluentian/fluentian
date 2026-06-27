import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// App-wide constants for Fluentian
class AppConstants {
  static const String appName = 'Fluentian';
  static const String tagline = 'French made for you';
  static const double splashDuration = 2.5;
  static const int onboardingSlides = 3;
}

/// CEFR Levels
enum CEFRLevel {
  a0('A0', 'Complete Beginner', "I've never studied French", 0xFF9CA3AF),
  a1('A1', 'Absolute Beginner', 'I know a few words', 0xFF22C55E),
  a2('A2', 'Elementary', 'I can handle simple conversations', 0xFF14B8A6),
  b1('B1', 'Intermediate', 'I can talk about familiar topics', 0xFF3B82F6),
  b2('B2', 'Upper Intermediate', 'I can discuss complex topics', 0xFF6C3BF5),
  c1c2('C1/C2', 'Advanced', "I'm nearly fluent", 0xFFF59E0B);

  final String code;
  final String name;
  final String description;
  final int colorValue;

  const CEFRLevel(this.code, this.name, this.description, this.colorValue);

  Color get color => Color(colorValue);

  static CEFRLevel fromCode(String code) {
    final cleanCode = code.toUpperCase().replaceAll('/', '').trim();
    if (cleanCode == 'A0') return CEFRLevel.a0;
    if (cleanCode == 'A1') return CEFRLevel.a1;
    if (cleanCode == 'A2') return CEFRLevel.a2;
    if (cleanCode == 'B1') return CEFRLevel.b1;
    if (cleanCode == 'B2') return CEFRLevel.b2;
    return CEFRLevel.c1c2;
  }

  static String getFriendlyName(String code) {
    final cleanCode = code.toUpperCase().replaceAll('/', '').trim();
    if (cleanCode == 'A0') return 'Complete Beginner';
    if (cleanCode == 'A1') return 'Absolute Beginner';
    if (cleanCode == 'A2') return 'Elementary';
    if (cleanCode == 'B1') return 'Intermediate';
    if (cleanCode == 'B2') return 'Upper Intermediate';
    if (cleanCode == 'C1' || cleanCode == 'C2' || cleanCode == 'C1C2') {
      return 'Advanced';
    }
    return code;
  }
}

/// Daily goal options
class DailyGoal {
  final IconData iconData;
  final int xp;
  final String label;
  final String duration;

  const DailyGoal({
    required this.iconData,
    required this.xp,
    required this.label,
    required this.duration,
  });

  static const List<DailyGoal> goals = [
    DailyGoal(
      iconData: Iconsax.tree,
      xp: 10,
      label: 'Casual',
      duration: '5 min/day',
    ),
    DailyGoal(
      iconData: Iconsax.flash_1,
      xp: 20,
      label: 'Regular',
      duration: '10 min/day',
    ),
    DailyGoal(
      iconData: Iconsax.flash_15,
      xp: 50,
      label: 'Serious',
      duration: '20 min/day',
    ),
    DailyGoal(
      iconData: Iconsax.cup5,
      xp: 100,
      label: 'Intense',
      duration: '40 min/day',
    ),
  ];
}

/// Bottom nav tabs
enum NavTab {
  home('Home', Iconsax.home),
  aiCoach('AI Coach', Iconsax.message_programming),
  social('Social', Iconsax.heart),
  board('Board', Iconsax.clipboard_text),
  profile('Profile', Iconsax.user);

  final String label;
  final IconData iconData;

  const NavTab(this.label, this.iconData);
}

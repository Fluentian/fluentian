import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// App-wide constants for Fluentian
class AppConstants {
  static const String appName = 'Fluentian';
  static const String tagline = 'French made for you';
  static const double splashDuration = 2.5;
  static const int onboardingSlides = 3;
}

/// CEFR Levels.
///
/// These deliberately carry no colour. Each level used to own a hue -- grey,
/// green, teal, blue, navy, amber -- drawn at 15% alpha behind a numeral.
/// Six unrelated hues for six steps of one scale is decoration standing in
/// for hierarchy, and it belonged to the old palette. Level is a *sequence*,
/// so the screen renders it as one: the CEFR code, set in the mono face, in
/// ink. Rank reads off the ordering, not off a colour key nobody learns.
enum CEFRLevel {
  a0('A0', 'Complete Beginner', "I've never studied French"),
  a1('A1', 'Absolute Beginner', 'I know a few words'),
  a2('A2', 'Elementary', 'I can handle simple conversations'),
  b1('B1', 'Intermediate', 'I can talk about familiar topics'),
  b2('B2', 'Upper Intermediate', 'I can discuss complex topics'),
  c1c2('C1/C2', 'Advanced', "I'm nearly fluent");

  final String code;
  final String name;
  final String description;

  const CEFRLevel(this.code, this.name, this.description);

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

/// Daily goal options.
///
/// Minutes are the thing the learner is actually committing to, so minutes
/// are what the screen sets large. The icons this used to carry (a tree, a
/// lightning bolt, a trophy) were decoration standing in for a quantity that
/// is already a number.
class DailyGoal {
  final int minutes;
  final int xp;
  final String label;

  const DailyGoal({
    required this.minutes,
    required this.xp,
    required this.label,
  });

  String get duration => '$minutes min/day';

  static const List<DailyGoal> goals = [
    DailyGoal(minutes: 5, xp: 10, label: 'Casual'),
    DailyGoal(minutes: 10, xp: 20, label: 'Regular'),
    DailyGoal(minutes: 20, xp: 50, label: 'Serious'),
    DailyGoal(minutes: 40, xp: 100, label: 'Intense'),
  ];
}

/// Converts the learner's time preference into short lesson sessions.
int lessonsForDailyGoalMinutes(int minutes) => (minutes / 5).ceil().clamp(1, 8);

/// Why a learner is studying French — drives content personalization.
enum LearningMotivation {
  immigrationExam(
    'immigration_exam',
    'Immigration or exam prep',
    'TCF, TEF, DELF — for Canada, France, or elsewhere',
    Iconsax.airplane,
  ),
  workCareer(
    'work_career',
    'Work or career',
    'A new job, a promotion, or a Francophone employer',
    Iconsax.briefcase,
  ),
  travel(
    'travel',
    'Travel',
    'An upcoming trip or love of exploring',
    Iconsax.global,
  ),
  academic(
    'academic',
    'School or academics',
    'A class, degree, or academic requirement',
    Iconsax.teacher,
  ),
  familyRelationships(
    'family_relationships',
    'Family or relationships',
    'To connect with people who speak French',
    Iconsax.heart,
  ),
  generalInterest(
    'general_interest',
    'Just for me',
    'Curiosity, culture, or a personal challenge',
    Iconsax.star,
  );

  final String code;
  final String label;
  final String description;
  final IconData iconData;

  const LearningMotivation(
    this.code,
    this.label,
    this.description,
    this.iconData,
  );
}

/// Self-reported prior exposure to French, collected before any placement test.
enum PriorFrenchExposure {
  none('none', 'Never studied it', "I'm starting from zero"),
  aLittle(
    'a_little',
    'A little exposure',
    'A few words or phrases here and there',
  ),
  studiedBefore(
    'studied_before',
    'Studied it before',
    'In school or on my own, but it faded',
  ),
  usedToBeFluent(
    'used_to_be_fluent',
    'Used to be fluent',
    "I'm coming back to French after a long break",
  );

  final String code;
  final String label;
  final String description;

  const PriorFrenchExposure(this.code, this.label, this.description);
}

/// A curated timezone choice shown with a city/region name rather than a
/// raw UTC offset — most of Fluentian's audience is in East Africa, so
/// Addis Ababa is first and is the fallback default when device detection
/// isn't available.
class TimezoneOption {
  final String ianaName;
  final String displayName;
  final String offsetLabel;

  const TimezoneOption(this.ianaName, this.displayName, this.offsetLabel);

  static const List<TimezoneOption> curated = [
    TimezoneOption('Africa/Addis_Ababa', 'Addis Ababa', 'GMT+3'),
    TimezoneOption('Africa/Nairobi', 'Nairobi', 'GMT+3'),
    TimezoneOption('Africa/Mogadishu', 'Mogadishu', 'GMT+3'),
    TimezoneOption('Africa/Khartoum', 'Khartoum', 'GMT+2'),
    TimezoneOption('Africa/Cairo', 'Cairo', 'GMT+2'),
    TimezoneOption('Africa/Lagos', 'Lagos', 'GMT+1'),
    TimezoneOption('Africa/Kampala', 'Kampala', 'GMT+3'),
    TimezoneOption('Africa/Dar_es_Salaam', 'Dar es Salaam', 'GMT+3'),
    TimezoneOption('Asia/Riyadh', 'Riyadh', 'GMT+3'),
    TimezoneOption('Asia/Dubai', 'Dubai', 'GMT+4'),
    TimezoneOption('Europe/London', 'London', 'GMT+0/+1'),
    TimezoneOption('Europe/Paris', 'Paris', 'GMT+1/+2'),
    TimezoneOption('America/New_York', 'New York', 'GMT-5/-4'),
    TimezoneOption('America/Toronto', 'Toronto', 'GMT-5/-4'),
    TimezoneOption('America/Los_Angeles', 'Los Angeles', 'GMT-8/-7'),
  ];

  static const TimezoneOption fallbackDefault = TimezoneOption(
    'Africa/Addis_Ababa',
    'Addis Ababa',
    'GMT+3',
  );

  static TimezoneOption? findByIana(String ianaName) {
    for (final option in curated) {
      if (option.ianaName == ianaName) return option;
    }
    return null;
  }
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

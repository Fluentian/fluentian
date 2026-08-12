import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Persists in-progress onboarding selections (level, daily goal, birth
/// date, prior French exposure) as the learner answers each step. Without
/// this, an app kill mid-onboarding (phone call, low memory, etc.) silently
/// wiped every choice, because nothing was saved to the backend until the
/// very last screen -- the app always restarts onboarding at the level-pick
/// step (see main.dart), so a restart meant re-deciding everything from
/// scratch with no explanation. The draft is cleared once onboarding
/// actually completes.
class OnboardingDraftStore {
  OnboardingDraftStore._();
  static final OnboardingDraftStore instance = OnboardingDraftStore._();

  static const _levelKey = 'fluentian_onboarding_draft_level';
  static const _goalXpKey = 'fluentian_onboarding_draft_goal_xp';
  static const _birthDateKey = 'fluentian_onboarding_draft_birth_date';
  static const _exposureKey = 'fluentian_onboarding_draft_exposure';

  Future<void> saveLevel(CEFRLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_levelKey, level.code);
  }

  Future<CEFRLevel?> loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_levelKey);
    return code == null ? null : CEFRLevel.fromCode(code);
  }

  Future<void> saveGoalXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalXpKey, xp);
  }

  Future<int?> loadGoalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_goalXpKey);
  }

  Future<void> saveAboutYou({
    required DateTime birthDate,
    required PriorFrenchExposure exposure,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_birthDateKey, birthDate.toIso8601String());
    await prefs.setString(_exposureKey, exposure.code);
  }

  Future<DateTime?> loadBirthDate() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_birthDateKey);
    return iso == null ? null : DateTime.tryParse(iso);
  }

  Future<PriorFrenchExposure?> loadExposure() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_exposureKey);
    if (code == null) return null;
    for (final value in PriorFrenchExposure.values) {
      if (value.code == code) return value;
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_levelKey);
    await prefs.remove(_goalXpKey);
    await prefs.remove(_birthDateKey);
    await prefs.remove(_exposureKey);
  }
}

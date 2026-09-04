import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';

import '../providers/auth_provider.dart';

/// Haptics that respect the learner's Accessibility setting.
///
/// "Haptic feedback" was only honoured by one widget; every other call site
/// invoked `HapticFeedback.*` directly, so turning the switch off still buzzed
/// on answers, lesson completion, streak celebrations and partner matching.
/// The setting exists for people with sensory sensitivities, so it has to hold
/// everywhere rather than in one place.
class Haptics {
  const Haptics._();

  static bool _enabled(BuildContext context) =>
      context.read<AuthProvider>().user?.hapticFeedbackEnabled ?? true;

  static void light(BuildContext context) {
    if (_enabled(context)) HapticFeedback.lightImpact();
  }

  static void medium(BuildContext context) {
    if (_enabled(context)) HapticFeedback.mediumImpact();
  }

  static void heavy(BuildContext context) {
    if (_enabled(context)) HapticFeedback.heavyImpact();
  }

  static void selection(BuildContext context) {
    if (_enabled(context)) HapticFeedback.selectionClick();
  }
}

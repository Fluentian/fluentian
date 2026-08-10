import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_localization.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/onboarding_scaffold.dart';

class MotivationSetupScreen extends StatefulWidget {
  final String level;
  final int dailyGoalXp;
  final DateTime birthDate;
  final PriorFrenchExposure priorFrenchExposure;

  const MotivationSetupScreen({
    super.key,
    required this.level,
    required this.dailyGoalXp,
    required this.birthDate,
    required this.priorFrenchExposure,
  });

  @override
  State<MotivationSetupScreen> createState() => _MotivationSetupScreenState();
}

class _MotivationSetupScreenState extends State<MotivationSetupScreen> {
  LearningMotivation? _motivation;

  String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _finish(AuthProvider auth) async {
    final success = await auth.updateProfile({
      'current_level': widget.level,
      'daily_goal_xp': widget.dailyGoalXp,
      'birth_date': _isoDate(widget.birthDate),
      'prior_french_exposure': widget.priorFrenchExposure.code,
      'learning_motivation': _motivation!.code,
      // Fixed default rather than device auto-detection -- almost all of
      // Fluentian's audience is East African; changeable later in Settings.
      'timezone': 'Africa/Addis_Ababa',
    });
    if (!mounted) return;
    if (success) {
      await auth.completeOnboarding(selectedLevel: widget.level);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: LText('Failed to save profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return OnboardingScaffold(
          step: 4,
          totalSteps: 4,
          title: "What's your why?",
          subtitle:
              'The clearer your reason, the more we can tailor your lessons to it.',
          body: Column(
            children: LearningMotivation.values
                .map(
                  (option) => OnboardingOptionCard(
                    iconData: option.iconData,
                    label: option.label,
                    description: option.description,
                    selected: _motivation == option,
                    onTap: () => setState(() => _motivation = option),
                  ),
                )
                .toList(),
          ),
          buttonLabel: 'Start learning',
          isLoading: auth.isLoading,
          onButtonPressed: _motivation != null && !auth.isLoading
              ? () => _finish(auth)
              : null,
        );
      },
    );
  }
}

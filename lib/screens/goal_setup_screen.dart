import 'package:flutter/material.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/onboarding_draft_store.dart';
import '../widgets/onboarding_scaffold.dart';
import 'about_you_setup_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  final CEFRLevel level;
  const GoalSetupScreen({super.key, required this.level});

  factory GoalSetupScreen.fromPlacement({required String levelCode}) {
    return GoalSetupScreen(level: CEFRLevel.fromCode(levelCode));
  }

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  int _selectedIndex = 1; // Default: Regular

  @override
  void initState() {
    super.initState();
    // Restores a goal picked before an app kill mid-onboarding forced a
    // restart back at the level-pick step.
    OnboardingDraftStore.instance.loadGoalXp().then((xp) {
      if (!mounted || xp == null) return;
      final index = DailyGoal.goals.indexWhere((g) => g.xp == xp);
      if (index != -1) setState(() => _selectedIndex = index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 2,
      totalSteps: 4,
      title: 'Set your daily goal',
      subtitle: 'Consistency beats intensity. Pick what fits your life.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(DailyGoal.goals.length, (i) {
          return _GoalRow(
            goal: DailyGoal.goals[i],
            selected: _selectedIndex == i,
            onTap: () => setState(() => _selectedIndex = i),
          );
        }),
      ),
      buttonLabel: 'Continue',
      onButtonPressed: () {
        OnboardingDraftStore.instance.saveGoalXp(
          DailyGoal.goals[_selectedIndex].xp,
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AboutYouSetupScreen(
              level: widget.level.code,
              dailyGoalXp: DailyGoal.goals[_selectedIndex].xp,
            ),
          ),
        );
      },
    );
  }
}

/// One commitment level.
///
/// Was a 2x2 grid of icon tiles -- the arrangement every goal-picker ships.
/// The grid also buried the only number that matters (minutes) under an
/// icon and an XP figure. Here minutes lead, set in the display face at a
/// size you read before the label, and the rows share the ink-invert
/// selection used by every other onboarding step.
class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final DailyGoal goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '${context.tr(goal.label)}, ${goal.duration}, ${goal.xp} XP',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: selected ? FluentianColors.primary : FluentianColors.cardBg,
            border: Border.all(
              color: selected
                  ? FluentianColors.primary
                  : FluentianColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${goal.minutes}',
                      style: text.displaySmall?.copyWith(
                        height: 1.0,
                        color: selected
                            ? Colors.white
                            : FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'min',
                      style: FluentianTheme.label(
                        color: selected
                            ? FluentianColors.onInkMuted
                            : FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      goal.label,
                      style: text.titleSmall?.copyWith(
                        color: selected
                            ? Colors.white
                            : FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'a day  ·  ${goal.xp} XP',
                      style: FluentianTheme.label(
                        color: selected
                            ? FluentianColors.onInkMuted
                            : FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1 : 0,
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

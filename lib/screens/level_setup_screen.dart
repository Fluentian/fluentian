import 'package:flutter/material.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/onboarding_draft_store.dart';
import '../widgets/onboarding_scaffold.dart';
import 'goal_setup_screen.dart';
import 'placement_test_screen.dart';

class LevelSetupScreen extends StatefulWidget {
  const LevelSetupScreen({super.key});
  @override
  State<LevelSetupScreen> createState() => _LevelSetupScreenState();
}

class _LevelSetupScreenState extends State<LevelSetupScreen> {
  CEFRLevel? _selected;

  @override
  void initState() {
    super.initState();
    // Restores a choice made before an app kill mid-onboarding -- this is
    // always the screen the app restarts on (see main.dart), so without
    // this the learner had to re-decide their level every time.
    OnboardingDraftStore.instance.loadLevel().then((level) {
      if (mounted && level != null) setState(() => _selected = level);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 1,
      totalSteps: 4,
      title: "What's your French level?",
      subtitle: "We'll create the perfect path for you.",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...CEFRLevel.values.map(
            (level) => _LevelRow(
              level: level,
              isSelected: _selected == level,
              onTap: () => setState(() => _selected = level),
            ),
          ),
        ],
      ),
      // The placement test is a real alternative to picking a level, not an
      // afterthought floating under the list -- it sits next to the primary
      // action where the learner is already deciding.
      footer: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlacementTestScreen()),
          ),
          child: const LText('Not sure? Take the placement test'),
        ),
      ),
      buttonLabel: 'Continue',
      onButtonPressed: _selected != null
          ? () {
              OnboardingDraftStore.instance.saveLevel(_selected!);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GoalSetupScreen(level: _selected!),
                ),
              );
            }
          : null,
    );
  }
}

/// One rung of the level ladder.
///
/// The code plate on the left is the whole idea: A0 through C1/C2 set in the
/// mono face, so the six options read as one ordered scale at a glance. The
/// selected row inverts to solid ink, matching [OnboardingOptionCard] -- the
/// rest of onboarding answers questions the same way, and this screen should
/// not invent a second selection language.
class _LevelRow extends StatelessWidget {
  final CEFRLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelRow({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = isSelected ? Colors.white : FluentianColors.textPrimary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${level.code} ${context.tr(level.name)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? FluentianColors.primary
                : FluentianColors.cardBg,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: isSelected
                  ? FluentianColors.primary
                  : FluentianColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // The code plate. Fixed width so all six align into a column
              // and the scale is legible vertically.
              Container(
                width: 52,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : FluentianColors.pageBg,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : FluentianColors.border,
                  ),
                ),
                child: Text(
                  level.code,
                  style: FluentianTheme.label(
                    size: 13,
                    color: isSelected
                        ? FluentianColors.primary
                        : FluentianColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      level.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LText(
                      level.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? FluentianColors.onInkMuted
                            : FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1 : 0,
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

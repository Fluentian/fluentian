import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
        children: List.generate(DailyGoal.goals.length, (i) {
          final goal = DailyGoal.goals[i];
          final selected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected
                    ? FluentianColors.primaryTint
                    : FluentianColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? FluentianColors.primary
                      : FluentianColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  if (selected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: FluentianColors.primary,
                        size: 20,
                      ),
                    ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          goal.iconData,
                          size: 32,
                          color: FluentianColors.primary,
                        ),
                        const SizedBox(height: 8),
                        LText(
                          '${goal.xp} XP',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LText(
                          '${goal.label} · ${goal.duration}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/constants.dart';
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
            (level) => _LevelCard(
              level: level,
              isSelected: _selected == level,
              onTap: () => setState(() => _selected = level),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlacementTestScreen()),
              ),
              child: LText(
                'Take placement test instead',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: FluentianColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      buttonLabel: 'Continue',
      onButtonPressed: _selected != null
          ? () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GoalSetupScreen(level: _selected!),
              ),
            )
          : null,
    );
  }
}

class _LevelCard extends StatelessWidget {
  final CEFRLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? FluentianColors.primaryTint
              : FluentianColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? FluentianColors.primary
                : FluentianColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // CEFR badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: level.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: LText(
                  '${CEFRLevel.values.indexOf(level) + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: level.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    level.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                  LText(
                    level.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: FluentianColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

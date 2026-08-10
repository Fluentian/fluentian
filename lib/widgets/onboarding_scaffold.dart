import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import 'common_widgets.dart';

/// Shared chrome for onboarding steps: back arrow + "Step X of Y" header,
/// title/subtitle, scrollable body, and a pinned bottom action button.
/// Factored out once four onboarding screens started needing the same
/// hand-rolled layout (previously each screen duplicated it).
class OnboardingScaffold extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget body;
  final String buttonLabel;
  final VoidCallback? onButtonPressed;
  final bool isLoading;
  final Widget? footer;

  const OnboardingScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.isLoading = false,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  LText(
                    'Step $step of $totalSteps',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: step / totalSteps,
                  minHeight: 5,
                  backgroundColor: FluentianColors.border,
                  valueColor: const AlwaysStoppedAnimation(
                    FluentianColors.primary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    LText(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LText(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    body,
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: footer,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FluentianButton(
                text: isLoading ? 'Saving...' : buttonLabel,
                onPressed: isLoading ? null : onButtonPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single selectable option card used across onboarding steps -- icon,
/// label, description, animated selection state. Shared so the "why are
/// you learning French" and "prior exposure" screens feel identical.
class OnboardingOptionCard extends StatelessWidget {
  final IconData? iconData;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const OnboardingOptionCard({
    super.key,
    this.iconData,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? FluentianColors.primaryTint : FluentianColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? FluentianColors.primary : FluentianColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: FluentianColors.primary.withValues(alpha: .15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            if (iconData != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? FluentianColors.primary
                      : FluentianColors.pageBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  size: 22,
                  color: selected ? Colors.white : FluentianColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  LText(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: FluentianColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: selected ? 1 : 0,
              child: const Icon(
                Icons.check_circle_rounded,
                color: FluentianColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

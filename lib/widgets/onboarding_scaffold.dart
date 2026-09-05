import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import 'tibeb_band.dart';
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
      backgroundColor: FluentianColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.tr('Back'),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Step $step / $totalSteps',
                    style: FluentianTheme.label(),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: step / totalSteps),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => TibebBand(height: 12, progress: v),
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
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: LText(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge,
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
    return Semantics(
      button: true,
      selected: selected,
      label: context.tr(label),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Selected inverts to solid ink rather than a pale tint. A tinted
            // card with a checkmark is the default everywhere; a filled block
            // reads as a decision that has been made.
            color: selected ? FluentianColors.primary : FluentianColors.cardBg,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: selected
                  ? FluentianColors.primary
                  : FluentianColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    FluentianShadows.subtle,
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
                        ? Colors.white
                        : FluentianColors.pageBg,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Icon(
                    iconData,
                    size: 22,
                    color: selected
                        ? FluentianColors.primary
                        : FluentianColors.textSecondary,
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
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LText(
                      description,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        color: selected
                            ? const Color(0xFFC7CCD6)
                            : FluentianColors.textSecondary,
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

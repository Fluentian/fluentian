import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/app_localization.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../services/onboarding_draft_store.dart';
import '../widgets/onboarding_scaffold.dart';
import 'motivation_setup_screen.dart';

class AboutYouSetupScreen extends StatefulWidget {
  final String level;
  final int dailyGoalXp;

  const AboutYouSetupScreen({
    super.key,
    required this.level,
    required this.dailyGoalXp,
  });

  @override
  State<AboutYouSetupScreen> createState() => _AboutYouSetupScreenState();
}

class _AboutYouSetupScreenState extends State<AboutYouSetupScreen> {
  static const _minimumAge = 13;

  DateTime? _birthDate;
  PriorFrenchExposure? _exposure;

  @override
  void initState() {
    super.initState();
    // Restores answers given before an app kill mid-onboarding forced a
    // restart back at the level-pick step.
    OnboardingDraftStore.instance.loadBirthDate().then((date) {
      if (mounted && date != null) setState(() => _birthDate = date);
    });
    OnboardingDraftStore.instance.loadExposure().then((exposure) {
      if (mounted && exposure != null) setState(() => _exposure = exposure);
    });
  }

  /// Latest birth date that still satisfies the 13+ requirement.
  DateTime get _maxBirthDate {
    final now = DateTime.now();
    return DateTime(now.year - _minimumAge, now.month, now.day);
  }

  int? get _age {
    final birth = _birthDate;
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickBirthDate() async {
    DateTime tempDate = _birthDate ?? DateTime(2000, 1, 1);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: FluentianColors.cardBg,
            border: Border(top: FluentianBorders.hairline),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 8, 6),
                child: Row(
                  children: [
                    Text('BIRTH DATE', style: FluentianTheme.label()),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() => _birthDate = tempDate);
                        Navigator.pop(context);
                      },
                      child: const LText('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: tempDate.isAfter(_maxBirthDate)
                      ? _maxBirthDate
                      : tempDate,
                  minimumDate: DateTime(1930),
                  // Fluentian requires users to be at least 13 -- don't let
                  // the picker itself offer a date that would fail that.
                  maximumDate: _maxBirthDate,
                  onDateTimeChanged: (value) => tempDate = value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool get _canContinue => _birthDate != null && _exposure != null;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 3,
      totalSteps: 4,
      title: 'Tell us about yourself',
      subtitle: 'A couple of quick things to personalize your journey.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('BIRTH DATE'),
          const SizedBox(height: 10),
          _BirthDateField(
            date: _birthDate,
            age: _age,
            formatted: _birthDate == null ? null : _formatDate(_birthDate!),
            onTap: _pickBirthDate,
          ),
          const SizedBox(height: 28),
          const _SectionLabel('YOUR FRENCH SO FAR'),
          const SizedBox(height: 10),
          ...PriorFrenchExposure.values.map(
            (option) => OnboardingOptionCard(
              label: option.label,
              description: option.description,
              selected: _exposure == option,
              onTap: () => setState(() => _exposure = option),
            ),
          ),
        ],
      ),
      buttonLabel: 'Continue',
      onButtonPressed: _canContinue
          ? () {
              OnboardingDraftStore.instance.saveAboutYou(
                birthDate: _birthDate!,
                exposure: _exposure!,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MotivationSetupScreen(
                    level: widget.level,
                    dailyGoalXp: widget.dailyGoalXp,
                    birthDate: _birthDate!,
                    priorFrenchExposure: _exposure!,
                  ),
                ),
              );
            }
          : null,
    );
  }
}

/// A field-set caption. Mono, upper, tracked -- the same label voice used for
/// step counters and plate captions, so the form reads as one document
/// rather than a stack of unrelated bold headings.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: FluentianTheme.label());
}

/// The birth-date field.
///
/// Dropped the birthday-cake icon: a cake for a date-of-birth input is the
/// cute-icon reflex, and it says nothing the label doesn't. Once filled, the
/// row inverts to ink like every other answered question in onboarding, and
/// the chosen date is set in the mono face because it is data, not prose.
class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.date,
    required this.age,
    required this.formatted,
    required this.onTap,
  });

  final DateTime? date;
  final int? age;
  final String? formatted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final filled = date != null;

    return Semantics(
      button: true,
      label: filled
          ? '${context.tr('Birth date')} $formatted'
          : context.tr('Select your birth date'),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(14, 16, 10, 16),
          decoration: BoxDecoration(
            color: filled ? FluentianColors.primary : FluentianColors.cardBg,
            border: Border.all(
              color: filled ? FluentianColors.primary : FluentianColors.border,
              width: filled ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: filled
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatted!,
                            style: FluentianTheme.label(
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$age years old',
                            style: FluentianTheme.label(
                              color: FluentianColors.onInkMuted,
                            ),
                          ),
                        ],
                      )
                    : LText(
                        'Select your birth date',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: filled ? Colors.white : FluentianColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

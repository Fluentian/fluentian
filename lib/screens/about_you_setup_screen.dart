import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_localization.dart';
import '../core/constants.dart';
import '../core/theme.dart';
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
  DateTime? _birthDate;
  PriorFrenchExposure? _exposure;

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
            color: FluentianColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    LText(
                      'Your birth date',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
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
                  initialDateTime: tempDate,
                  minimumDate: DateTime(1930),
                  maximumDate: DateTime.now(),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
          LText(
            'Birth date',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickBirthDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _birthDate != null
                    ? FluentianColors.primaryTint
                    : FluentianColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _birthDate != null
                      ? FluentianColors.primary
                      : FluentianColors.border,
                  width: _birthDate != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _birthDate != null
                          ? FluentianColors.primary
                          : FluentianColors.pageBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.cake_rounded,
                      size: 22,
                      color: _birthDate != null
                          ? Colors.white
                          : FluentianColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LText(
                      _birthDate != null
                          ? '${_formatDate(_birthDate!)} · $_age years old'
                          : 'Tap to select your birth date',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _birthDate != null
                            ? FluentianColors.textPrimary
                            : FluentianColors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: FluentianColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          LText(
            'Your French so far',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
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

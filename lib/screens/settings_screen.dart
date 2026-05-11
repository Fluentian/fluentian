import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminder = true;
  bool _phoneticHints = true;
  bool _speaking = true;
  bool _autoPlay = true;
  bool _highContrast = false;
  bool _reduceAnim = false;
  bool _haptic = true;
  bool _streakNotif = true;
  bool _reviewNotif = true;
  bool _badgeNotif = true;
  bool _msgNotif = true;
  int _fontIndex = 1; // 0=small, 1=medium, 2=large
  double _ttsSpeed = 1.0;
  double _micSensitivity = 0.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile mini header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: FluentianColors.primaryTint,
                      border: Border.all(
                        color: FluentianColors.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: FluentianColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sara Tesfaye',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Edit profile →',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: FluentianColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Group 1 — Learning
            _SettingsGroup(
              title: 'Learning',
              children: [
                SettingsRow(
                  icon: Icons.language_rounded,
                  label: 'Interface language',
                  trailing: '🇬🇧 English',
                  onTap: () {},
                ),
                SettingsRow(
                  icon: Icons.track_changes_rounded,
                  label: 'Daily goal',
                  trailing: '50 XP / day',
                  onTap: () {},
                ),
                ToggleRow(
                  icon: Icons.notifications_rounded,
                  label: 'Learning reminder',
                  value: _reminder,
                  onChanged: (v) => setState(() => _reminder = v),
                ),
                ToggleRow(
                  icon: Icons.text_fields_rounded,
                  label: 'Show phonetic hints',
                  value: _phoneticHints,
                  onChanged: (v) => setState(() => _phoneticHints = v),
                ),
                ToggleRow(
                  icon: Icons.mic_rounded,
                  label: 'Speaking exercises',
                  value: _speaking,
                  onChanged: (v) => setState(() => _speaking = v),
                ),
                SettingsRow(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI feedback detail',
                  trailing: 'Standard',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Group 2 — Audio & voice
            _SettingsGroup(
              title: 'Audio & voice',
              children: [
                ToggleRow(
                  icon: Icons.play_circle_rounded,
                  label: 'Auto-play audio',
                  value: _autoPlay,
                  onChanged: (v) => setState(() => _autoPlay = v),
                ),
                _SliderRow(
                  label: 'TTS playback speed',
                  value: _ttsSpeed,
                  min: 0.5,
                  max: 2.0,
                  displayValue: '${_ttsSpeed.toStringAsFixed(1)}×',
                  onChanged: (v) => setState(() => _ttsSpeed = v),
                ),
                SettingsRow(
                  icon: Icons.record_voice_over_rounded,
                  label: 'AI Coach voice',
                  trailing: 'Marie (Parisian)',
                  onTap: () {},
                ),
                _SliderRow(
                  label: 'Microphone sensitivity',
                  value: _micSensitivity,
                  min: 0.0,
                  max: 1.0,
                  displayValue: '${(_micSensitivity * 100).toInt()}%',
                  onChanged: (v) => setState(() => _micSensitivity = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Group 3 — Accessibility
            _SettingsGroup(
              title: 'Accessibility',
              children: [
                _FontSizeSelector(
                  index: _fontIndex,
                  onChanged: (i) => setState(() => _fontIndex = i),
                ),
                ToggleRow(
                  icon: Icons.contrast_rounded,
                  label: 'High contrast mode',
                  value: _highContrast,
                  onChanged: (v) => setState(() => _highContrast = v),
                ),
                ToggleRow(
                  icon: Icons.animation_rounded,
                  label: 'Reduce animations',
                  value: _reduceAnim,
                  onChanged: (v) => setState(() => _reduceAnim = v),
                ),
                ToggleRow(
                  icon: Icons.vibration_rounded,
                  label: 'Haptic feedback',
                  value: _haptic,
                  onChanged: (v) => setState(() => _haptic = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Group 4 — Notifications
            _SettingsGroup(
              title: 'Notifications',
              children: [
                ToggleRow(
                  customIconData: Iconsax.flash_1,
                  label: 'Streak reminder',
                  value: _streakNotif,
                  onChanged: (v) => setState(() => _streakNotif = v),
                ),
                ToggleRow(
                  customIconData: Iconsax.book,
                  label: 'Review due',
                  value: _reviewNotif,
                  onChanged: (v) => setState(() => _reviewNotif = v),
                ),
                ToggleRow(
                  customIconData: Iconsax.cup,
                  label: 'Badges',
                  value: _badgeNotif,
                  onChanged: (v) => setState(() => _badgeNotif = v),
                ),
                ToggleRow(
                  customIconData: Iconsax.message,
                  label: 'Messages',
                  value: _msgNotif,
                  onChanged: (v) => setState(() => _msgNotif = v),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Group 5 — Account
            _SettingsGroup(
              title: 'Account',
              children: [
                SettingsRow(
                  icon: Icons.star_rounded,
                  label: 'Subscription status',
                  trailingWidget: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: FluentianColors.primaryTint,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'Free plan',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.primary,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
                SettingsRow(
                  icon: Icons.lock_rounded,
                  label: 'Privacy settings',
                  onTap: () {},
                ),
                SettingsRow(
                  icon: Icons.download_rounded,
                  label: 'Download for offline',
                  onTap: () {},
                ),
                SettingsRow(
                  icon: Icons.help_rounded,
                  label: 'Help & support',
                  onTap: () {},
                ),
                SettingsRow(
                  icon: Icons.star_border_rounded,
                  label: 'Rate Fluentian ⭐',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Danger zone
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FluentianColors.errorTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FluentianColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: FluentianColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign out',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: FluentianColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_forever_rounded,
                            size: 18,
                            color: FluentianColors.error,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Delete account',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: FluentianColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Column(
            children: List.generate(children.length * 2 - 1, (i) {
              if (i.isOdd)
                return Divider(height: 1, color: FluentianColors.divider);
              return children[i ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label, displayValue;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                displayValue,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.primary,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: FluentianColors.primary,
              inactiveTrackColor: FluentianColors.primary.withValues(
                alpha: 0.15,
              ),
              thumbColor: FluentianColors.primary,
              overlayColor: FluentianColors.primary.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _FontSizeSelector extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _FontSizeSelector({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            'Font size',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: FluentianColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: FluentianColors.pageBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: List.generate(3, (i) {
                final sizes = [13.0, 16.0, 20.0];
                return GestureDetector(
                  onTap: () => onChanged(i),
                  child: Container(
                    width: 40,
                    height: 36,
                    decoration: BoxDecoration(
                      color: index == i
                          ? FluentianColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'A',
                        style: GoogleFonts.inter(
                          fontSize: sizes[i],
                          fontWeight: FontWeight.w600,
                          color: index == i
                              ? Colors.white
                              : FluentianColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

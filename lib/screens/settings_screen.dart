import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../services/app_logger.dart';
import '../services/download_settings.dart';
import '../services/local_push_service.dart';
import 'legal_document_screen.dart';
import 'offline_downloads_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _wifiOnlyDownloads = true;

  @override
  void initState() {
    super.initState();
    DownloadSettings.instance.getWifiOnly().then((value) {
      if (mounted) setState(() => _wifiOnlyDownloads = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: FluentianColors.pageBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: LText(
          'Your settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900),
        ),
        backgroundColor: FluentianColors.pageBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _AccountHeader(onEdit: () => _showProfileEditor(context)),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Learning language',
            children: [
              _LanguageRow(
                locale: context.watch<AppLocaleController>().locale,
                onChanged: (locale) async {
                  await context.read<AppLocaleController>().setLocale(locale);
                  if (!context.mounted) return;
                  final auth = context.read<AuthProvider>();
                  final ok = await auth.updateLearningLanguage(
                    locale.languageCode,
                  );
                  if (!context.mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          auth.errorMessage ?? 'Could not save language.',
                        ),
                      ),
                    );
                  }
                  await context.read<ContentProvider>().changeContentLanguage();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Learning',
            children: [
              _DailyGoalRow(
                minutes: user.dailyGoalMinutes,
                onChanged: (minutes) =>
                    _save(context, {'daily_goal_minutes': minutes}),
              ),
              _SwitchRow(
                icon: Icons.text_fields_rounded,
                label: 'Phonetic hints',
                value: user.phoneticHintsEnabled,
                onChanged: (value) =>
                    _save(context, {'phonetic_hints_enabled': value}),
              ),
              _SwitchRow(
                icon: Icons.mic_rounded,
                label: 'Speaking exercises',
                value: user.speakingExercisesEnabled,
                onChanged: (value) =>
                    _save(context, {'speaking_exercises_enabled': value}),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Offline downloads',
            children: [
              _SwitchRow(
                icon: Icons.wifi_rounded,
                label: 'Wi-Fi-only downloads',
                value: _wifiOnlyDownloads,
                onChanged: (value) async {
                  setState(() => _wifiOnlyDownloads = value);
                  await DownloadSettings.instance.setWifiOnly(value);
                },
              ),
              _RowShell(
                icon: Icons.download_for_offline_rounded,
                label: 'Downloaded lessons',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OfflineDownloadsScreen(),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: FluentianColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Audio',
            children: [
              _SwitchRow(
                icon: Icons.play_circle_rounded,
                label: 'Auto-play lesson audio',
                value: user.autoplayAudio,
                onChanged: (value) => _save(context, {'autoplay_audio': value}),
              ),
              _SwitchRow(
                icon: Icons.volume_up_rounded,
                label: 'Sound effects',
                value: user.soundEnabled,
                onChanged: (value) => _save(context, {'sound_enabled': value}),
              ),
              _SliderRow(
                icon: Icons.speed_rounded,
                label: 'TTS speed',
                value: user.ttsSpeed.clamp(0.6, 1.6),
                min: 0.6,
                max: 1.6,
                displayValue: '${user.ttsSpeed.toStringAsFixed(1)}x',
                onChanged: (value) => _save(context, {
                  'tts_speed': double.parse(value.toStringAsFixed(1)),
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Notifications',
            children: [
              _SwitchRow(
                icon: Icons.notifications_rounded,
                label: 'Allow notifications',
                value: user.notificationsEnabled,
                onChanged: (value) =>
                    _save(context, {'notifications_enabled': value}),
              ),
              _SwitchRow(
                icon: Icons.alarm_rounded,
                label: 'Daily lesson reminder',
                value: user.learningReminderEnabled,
                onChanged: user.notificationsEnabled
                    ? (value) =>
                          _save(context, {'learning_reminder_enabled': value})
                    : null,
              ),
              _TimeRow(
                time: user.reminderTime,
                enabled:
                    user.notificationsEnabled && user.learningReminderEnabled,
                onTap: () => _pickReminderTime(context, user.reminderTime),
              ),
              _TimezoneRow(
                timezone: user.timezone,
                onTap: () => _pickTimezone(context, user.timezone),
              ),
              _SwitchRow(
                icon: Icons.work_outline_rounded,
                label: 'New Board opportunities',
                value: user.opportunityNotificationsEnabled,
                onChanged: user.notificationsEnabled
                    ? (value) => _save(context, {
                        'opportunity_notifications_enabled': value,
                      })
                    : null,
              ),
              _RowShell(
                icon: Icons.send_to_mobile_rounded,
                label: 'Test notification',
                enabled: user.notificationsEnabled,
                onTap: user.notificationsEnabled
                    ? () => _emitTestNotification(context)
                    : null,
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: FluentianColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Accessibility',
            children: [
              _FontScaleRow(
                value: user.fontScale,
                onChanged: (value) => _save(context, {'font_scale': value}),
              ),
              _SwitchRow(
                icon: Icons.contrast_rounded,
                label: 'High contrast',
                value: user.highContrastEnabled,
                onChanged: (value) =>
                    _save(context, {'high_contrast_enabled': value}),
              ),
              _SwitchRow(
                icon: Icons.motion_photos_pause_rounded,
                label: 'Reduce animations',
                value: user.reduceAnimationsEnabled,
                onChanged: (value) =>
                    _save(context, {'reduce_animations_enabled': value}),
              ),
              _SwitchRow(
                icon: Icons.vibration_rounded,
                label: 'Haptic feedback',
                value: user.hapticFeedbackEnabled,
                onChanged: (value) =>
                    _save(context, {'haptic_feedback_enabled': value}),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsGroup(
            title: 'Privacy & account',
            children: [
              _RowShell(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy policy',
                onTap: () => _openLegalPage(context, 'privacy'),
                trailing: const Icon(
                  Icons.open_in_new_rounded,
                  color: FluentianColors.textSecondary,
                  size: 20,
                ),
              ),
              _RowShell(
                icon: Icons.description_outlined,
                label: 'Terms and conditions',
                onTap: () => _openLegalPage(context, 'terms'),
                trailing: const Icon(
                  Icons.open_in_new_rounded,
                  color: FluentianColors.textSecondary,
                  size: 20,
                ),
              ),
              _RowShell(
                icon: Icons.delete_forever_outlined,
                label: 'Delete my account',
                onTap: () => _confirmAccountDeletion(context),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: FluentianColors.error,
                  size: 20,
                ),
              ),
            ],
          ),
          if (!kReleaseMode) ...[
            const SizedBox(height: 16),
            _SettingsGroup(title: 'Diagnostics', children: [_DebugLogsRow()]),
          ],
          const SizedBox(height: 16),
          _DangerAction(
            isLoading: auth.isLoading,
            onSignOut: () async {
              await auth.logout();
              if (context.mounted) {
                // AuthProvider drives _AppRoot back to SignInScreen. Only
                // remove pages opened above the app root; pushing a standalone
                // sign-in route here would remain above Home after the next
                // successful login and make account switching appear broken.
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, Map<String, dynamic> data) async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateSettings(data);
    if (ok && data['haptic_feedback_enabled'] == true && context.mounted) {
      HapticFeedback.selectionClick();
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not save setting.')),
      );
    }
  }

  Future<void> _pickReminderTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !context.mounted) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await _save(context, {'reminder_time': value});
  }

  Future<void> _pickTimezone(BuildContext context, String current) async {
    final picked = await showModalBottomSheet<TimezoneOption>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: FluentianColors.pageBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: FluentianColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: LText(
                        'Choose your timezone',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: TimezoneOption.curated.length,
                      itemBuilder: (context, index) {
                        final option = TimezoneOption.curated[index];
                        final selected = option.ianaName == current;
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () => Navigator.pop(context, option),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: selected
                                ? FluentianColors.primaryTint
                                : Colors.transparent,
                            title: LText(
                              option.displayName,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: FluentianColors.textPrimary,
                              ),
                            ),
                            subtitle: LText(
                              option.offsetLabel,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: FluentianColors.textSecondary,
                              ),
                            ),
                            trailing: selected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: FluentianColors.primary,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (picked == null || !context.mounted) return;
    await _save(context, {'timezone': picked.ianaName});
  }

  Future<void> _emitTestNotification(BuildContext context) async {
    try {
      await LocalPushService.instance.showTestNotification();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: LText('Test notification sent.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LText('Enable notifications before sending a test.'),
        ),
      );
    }
  }

  void _openLegalPage(BuildContext context, String slug) {
    Navigator.of(context).push(
      LegalDocumentScreen.route(
        title: slug == 'privacy' ? 'Privacy policy' : 'Terms and conditions',
        url: 'https://api.fluentianapp.binovatechnologies.com/$slug',
      ),
    );
  }

  Future<void> _confirmAccountDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: FluentianColors.error,
        ),
        title: const LText('Delete your account?'),
        content: const LText(
          'This permanently removes your profile, learning progress, messages, social data, notifications, and device tokens. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const LText('Keep account'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: FluentianColors.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const LText('Delete permanently'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: LText(
          ok
              ? 'Your account was deleted.'
              : auth.errorMessage ?? 'Could not delete your account.',
        ),
      ),
    );
  }

  Future<void> _showProfileEditor(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.displayName);
    final goalController = TextEditingController(text: user.learningGoal ?? '');
    final bioController = TextEditingController(text: user.bio ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            final keyboard = MediaQuery.of(context).viewInsets.bottom;
            final initial = nameController.text.trim().isEmpty
                ? 'U'
                : nameController.text.trim()[0].toUpperCase();
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .9,
              ),
              decoration: const BoxDecoration(
                color: FluentianColors.pageBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 10, 20, keyboard + 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: FluentianColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: FluentianColors.headerGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: FluentianColors.primary.withValues(
                              alpha: .22,
                            ),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .35),
                                width: 2,
                              ),
                            ),
                            child: LText(
                              initial,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LText(
                                  'Make your profile yours',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LText(
                                  'Help your learning circle know who you are and what you are aiming for.',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: .78),
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ProfileEditField(
                      controller: nameController,
                      icon: Icons.badge_outlined,
                      label: 'Display name',
                      hint: 'How should other learners greet you?',
                      maxLength: 100,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    _ProfileEditField(
                      controller: goalController,
                      icon: Icons.flag_outlined,
                      label: 'My French mission',
                      hint: 'Speak confidently on my next adventure',
                      maxLength: 255,
                    ),
                    const SizedBox(height: 14),
                    _ProfileEditField(
                      controller: bioController,
                      icon: Icons.auto_awesome_outlined,
                      label: 'My story',
                      hint: 'What brought you to French? Share a little spark.',
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: isSaving
                            ? null
                            : () async {
                                setState(() => isSaving = true);
                                final ok = await auth.updateProfile({
                                  'display_name': nameController.text.trim(),
                                  'learning_goal': goalController.text.trim(),
                                  'bio': bioController.text.trim(),
                                });
                                if (!context.mounted) return;
                                if (ok) {
                                  Navigator.pop(context);
                                } else {
                                  setState(() => isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        auth.errorMessage ??
                                            'Could not save profile.',
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: LText(
                          isSaving ? 'Saving your profile…' : 'Save my profile',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FluentianColors.textPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    nameController.dispose();
    goalController.dispose();
    bioController.dispose();
  }
}

class _ProfileEditField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;
  final int maxLines;
  final int maxLength;
  final ValueChanged<String>? onChanged;

  const _ProfileEditField({
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    required this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FluentianColors.border),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FluentianColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: FluentianColors.primary, size: 20),
          ),
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          alignLabelWithHint: true,
          counterStyle: GoogleFonts.inter(
            fontSize: 10,
            color: FluentianColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DebugLogsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _RowShell(
      icon: Icons.bug_report_rounded,
      label: 'Copy debug logs',
      onTap: () async {
        final logs = await AppLogger.instance.exportText();
        final text = logs.trim().isEmpty ? 'No debug logs recorded yet.' : logs;
        await Clipboard.setData(ClipboardData(text: text));
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: LText('Debug logs copied.')));
      },
      trailing: const Icon(
        Icons.copy_rounded,
        color: FluentianColors.textSecondary,
        size: 20,
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  final VoidCallback onEdit;

  const _AccountHeader({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final initial = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : 'U';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: FluentianColors.headerGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: FluentianColors.primary.withValues(alpha: .18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .25)),
            ),
            child: Center(
              child: LText(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: LText(
                        user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user.isFounder)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: .22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.crown_15,
                              size: 11,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3),
                            LText(
                              'Founder',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: LText(
                        'Free plan',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                LText(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: .72),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('Edit profile'),
            onPressed: onEdit,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: .14),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
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
          child: LText(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w900,
              color: FluentianColors.textSecondary,
            ),
          ),
        ),
        Material(
          color: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: FluentianColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(children.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Divider(height: 1, color: FluentianColors.divider);
              }
              return children[index ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final Locale locale;
  final ValueChanged<Locale> onChanged;

  const _LanguageRow({required this.locale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      (Locale('en'), 'English'),
      (Locale('am'), 'አማርኛ'),
      (Locale('om'), 'Afaan Oromoo'),
    ];
    return _RowShell(
      icon: Icons.language_rounded,
      label: 'Learning language',
      trailing: DropdownButton<String>(
        value: locale.languageCode,
        underline: const SizedBox.shrink(),
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option.$1.languageCode,
                child: LText(option.$2),
              ),
            )
            .toList(),
        onChanged: (code) {
          if (code != null) onChanged(Locale(code));
        },
      ),
    );
  }
}

class _DailyGoalRow extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;

  const _DailyGoalRow({required this.minutes, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [5, 10, 15, 20, 30, 40];
    return _RowShell(
      icon: Icons.track_changes_rounded,
      label: 'Daily goal',
      trailing: DropdownButton<int>(
        value: options.contains(minutes) ? minutes : 15,
        underline: const SizedBox.shrink(),
        items: options
            .map(
              (value) =>
                  DropdownMenuItem(value: value, child: LText('$value min')),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _TimezoneRow extends StatelessWidget {
  final String timezone;
  final VoidCallback onTap;

  const _TimezoneRow({required this.timezone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final option = TimezoneOption.findByIana(timezone);
    return _RowShell(
      icon: Icons.public_rounded,
      label: 'Timezone',
      onTap: onTap,
      trailing: LText(
        option?.displayName ?? timezone,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: FluentianColors.primary,
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String time;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeRow({
    required this.time,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      icon: Icons.schedule_rounded,
      label: 'Reminder time',
      enabled: enabled,
      onTap: enabled ? onTap : null,
      trailing: LText(
        time,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: enabled
              ? FluentianColors.primary
              : FluentianColors.textSecondary,
        ),
      ),
    );
  }
}

class _FontScaleRow extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _FontScaleRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = ['Small', 'Medium', 'Large'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_size_rounded,
                color: FluentianColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LText(
                  'Font size',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: FluentianColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: List.generate(
                labels.length,
                (index) =>
                    ButtonSegment(value: index, label: LText(labels[index])),
              ),
              selected: {value.clamp(0, 2)},
              onSelectionChanged: (selected) => onChanged(selected.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      secondary: _SettingIcon(icon: icon),
      title: LText(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: FluentianColors.textPrimary,
        ),
      ),
      value: value,
      activeThumbColor: FluentianColors.primary,
      onChanged: onChanged,
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: FluentianColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: LText(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: FluentianColors.textPrimary,
                  ),
                ),
              ),
              LText(
                displayValue,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RowShell extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final bool enabled;
  final VoidCallback? onTap;

  const _RowShell({
    required this.icon,
    required this.label,
    required this.trailing,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _SettingIcon(icon: icon, enabled: enabled),
            const SizedBox(width: 12),
            Expanded(
              child: LText(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: enabled
                      ? FluentianColors.textPrimary
                      : FluentianColors.textSecondary,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _DangerAction extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSignOut;

  const _DangerAction({required this.isLoading, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onSignOut,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FluentianColors.errorTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FluentianColors.error.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: FluentianColors.error),
            const SizedBox(width: 12),
            LText(
              isLoading ? 'Signing out...' : 'Sign out',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: FluentianColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  final IconData icon;
  final bool enabled;

  const _SettingIcon({required this.icon, this.enabled = true});

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: enabled ? FluentianColors.primaryTint : FluentianColors.pageBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      size: 18,
      color: enabled ? FluentianColors.primary : FluentianColors.textSecondary,
    ),
  );
}

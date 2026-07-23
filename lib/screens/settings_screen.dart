import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/app_logger.dart';
import '../services/local_push_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text(
          'Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _AccountHeader(onEdit: () => _showProfileEditor(context)),
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
          _SettingsGroup(title: 'Debug', children: [_DebugLogsRow()]),
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
    final ok = await context.read<AuthProvider>().updateSettings(data);
    if (ok && data['haptic_feedback_enabled'] == true && context.mounted) {
      HapticFeedback.selectionClick();
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save setting.')));
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

  Future<void> _emitTestNotification(BuildContext context) async {
    try {
      await LocalPushService.instance.showTestNotification();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test notification sent.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enable notifications before sending a test.'),
        ),
      );
    }
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit profile',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: goalController,
                    decoration: const InputDecoration(
                      labelText: 'Learning goal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                              Navigator.pop(context);
                              if (!ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not save profile.'),
                                  ),
                                );
                              }
                            },
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save profile'),
                    ),
                  ),
                ],
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
        ).showSnackBar(const SnackBar(content: Text('Debug logs copied.')));
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
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: FluentianColors.primaryTint,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: FluentianColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit profile',
            onPressed: onEdit,
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
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: FluentianColors.textSecondary,
            ),
          ),
        ),
        Material(
          color: Colors.white,
          elevation: 1,
          shadowColor: FluentianColors.primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
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
                  DropdownMenuItem(value: value, child: Text('$value min')),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
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
      trailing: Text(
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
                child: Text(
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
                    ButtonSegment(value: index, label: Text(labels[index])),
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
      secondary: Icon(icon, color: FluentianColors.primary),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15,
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
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: FluentianColors.textPrimary,
                  ),
                ),
              ),
              Text(
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
            Icon(
              icon,
              color: enabled
                  ? FluentianColors.primary
                  : FluentianColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
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
            Text(
              isLoading ? 'Signing out...' : 'Sign out',
              style: GoogleFonts.inter(
                fontSize: 15,
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

BoxDecoration _panelDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
  boxShadow: [FluentianShadows.subtle],
);

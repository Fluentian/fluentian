import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final content = context.watch<ContentProvider>();
    final user = auth.user;
    final stats = content.stats;

    if (user == null) {
      return const Scaffold(
        backgroundColor: FluentianColors.pageBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final xp = stats?.totalXp ?? user.xpTotal;
    final weeklyXp = stats?.weeklyXp ?? 0;
    final streak = stats?.streakDays ?? user.streakDays;
    final hearts = stats?.hearts ?? user.hearts;
    final lessons = stats?.lessonsCompleted ?? 0;
    final units = stats?.unitsCompleted ?? 0;
    final levelName = CEFRLevel.getFriendlyName(user.currentLevel);
    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U';
    final nextLevelXp = 500;
    final xpProgress = nextLevelXp == 0 ? 0.0 : (xp % nextLevelXp) / nextLevelXp;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _panelDecoration(),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: FluentianColors.primaryTint,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FluentianColors.primary.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: FluentianColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '@${user.username}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: FluentianColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Pill(
                                icon: Iconsax.teacher,
                                text: levelName,
                                color: FluentianColors.primary,
                              ),
                              _Pill(
                                icon: Icons.favorite_rounded,
                                text: '$hearts/5 hearts',
                                color: FluentianColors.error,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ],
                ),
                if ((user.learningGoal ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FluentianColors.primaryTint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      user.learningGoal!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.35,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Level progress',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(xpProgress * 100).round()}%',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 10,
                    backgroundColor:
                        FluentianColors.primary.withValues(alpha: 0.12),
                    valueColor:
                        const AlwaysStoppedAnimation(FluentianColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${xp % nextLevelXp} of $nextLevelXp XP toward the next milestone',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FluentianColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _MetricCard(
                icon: Icons.bolt_rounded,
                label: 'Total XP',
                value: '$xp',
                color: FluentianColors.primary,
              ),
              _MetricCard(
                icon: Icons.calendar_today_rounded,
                label: 'Last 7 days',
                value: '$weeklyXp XP',
                color: FluentianColors.info,
              ),
              _MetricCard(
                icon: Iconsax.flash_15,
                label: 'Streak',
                value: '$streak days',
                color: FluentianColors.accent,
              ),
              _MetricCard(
                icon: Icons.check_circle_rounded,
                label: 'Lessons',
                value: '$lessons done',
                color: FluentianColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _panelDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning summary',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryLine(
                  icon: Iconsax.book5,
                  label: 'Units completed',
                  value: '$units',
                ),
                _SummaryLine(
                  icon: Icons.track_changes_rounded,
                  label: 'Daily goal',
                  value: '${user.dailyGoalMinutes} min',
                ),
                _SummaryLine(
                  icon: Icons.notifications_rounded,
                  label: 'Daily reminder',
                  value: user.learningReminderEnabled
                      ? user.reminderTime
                      : 'Off',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.manage_accounts_rounded),
            label: const Text('Edit profile and settings'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: FluentianColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: FluentianColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: FluentianColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: FluentianColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Pill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/user_avatar.dart';
import '../widgets/avatar_picker_sheet.dart';
import '../services/referral_service.dart';
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
        body: SafeArea(child: FluentianShimmer(child: SkeletonProfile())),
      );
    }

    final xp = stats?.totalXp ?? user.xpTotal;
    final weeklyXp = stats?.weeklyXp ?? 0;
    final streak = stats?.streakDays ?? user.streakDays;
    final lessons = stats?.lessonsCompleted ?? 0;
    final units = stats?.unitsCompleted ?? 0;
    final levelName = CEFRLevel.getFriendlyName(user.currentLevel);
    final nextLevelXp = 500;
    final xpProgress = nextLevelXp == 0
        ? 0.0
        : (xp % nextLevelXp) / nextLevelXp;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _heroDecoration(),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(
                      avatarUrl: user.avatarUrl,
                      name: user.displayName,
                      size: 76,
                      showEditBadge: true,
                      onTap: () => AvatarPickerSheet.show(
                        context,
                        currentAvatarUrl: user.avatarUrl,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LText(
                            user.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          LText(
                            '@${user.username}',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: FluentianColors.onInkMuted,
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
                                color: FluentianColors.accent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white.withValues(alpha: .13),
                      borderRadius: BorderRadius.circular(0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(0),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Iconsax.setting_2,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if ((user.learningGoal ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .16),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Iconsax.flag,
                          color: FluentianColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LText(
                            user.learningGoal!,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InviteCard(username: user.username),
          const SizedBox(height: 16),
          _SectionLabel(text: 'MY MOMENTUM'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _panelDecoration(radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LText(
                      'Level progress',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    LText(
                      '${(xpProgress * 100).round()}%',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    minHeight: 11,
                    backgroundColor: FluentianColors.primary.withValues(
                      alpha: 0.12,
                    ),
                    valueColor: const AlwaysStoppedAnimation(
                      FluentianColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Iconsax.status_up,
                      size: 16,
                      color: FluentianColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: LText(
                        '${xp % nextLevelXp} of $nextLevelXp XP toward the next milestone',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(text: 'AT A GLANCE'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.38,
            children: [
              _MetricCard(
                icon: Iconsax.flash_15,
                label: 'Total XP',
                value: '$xp',
                color: FluentianColors.primary,
              ),
              _MetricCard(
                icon: Iconsax.calendar_1,
                label: 'This week',
                value: '$weeklyXp XP',
                color: FluentianColors.info,
              ),
              _MetricCard(
                icon: Iconsax.flash_15,
                label: 'Streak',
                value: '$streak ${streak == 1 ? 'day' : 'days'}',
                color: FluentianColors.warning,
              ),
              _MetricCard(
                icon: Iconsax.tick_circle,
                label: 'Lessons',
                value: '$lessons done',
                color: FluentianColors.success,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionLabel(text: 'WEEKLY STREAK HEATMAP'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _panelDecoration(radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: FluentianColors.warningTint,
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: const Icon(
                            Iconsax.flash_15,
                            color: FluentianColors.warning,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        LText(
                          'Weekly Activity',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FluentianColors.warningTint,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.flash_15,
                            color: FluentianColors.warning,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          LText(
                            '$streak ${streak == 1 ? 'Day' : 'Days'}',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer<ContentProvider>(
                  builder: (context, contentProvider, _) {
                    final daysActive = contentProvider.weeklyActiveDays;
                    final dayLabels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final todayIndex = DateTime.now().weekday - 1;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (index) {
                        final isActive = daysActive[index];
                        final isToday = index == todayIndex;

                        return Column(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? FluentianColors.warning
                                    : (isToday
                                          ? FluentianColors.warningTint
                                          : FluentianColors.pageBg),
                                border: isToday
                                    ? Border.all(
                                        color: FluentianColors.warning,
                                        width: 2,
                                      )
                                    : Border.all(color: FluentianColors.border),
                                boxShadow: isActive
                                    ? [
                                        FluentianShadows.subtle,
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isActive
                                    ? const Icon(
                                        Iconsax.flash_15,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : LText(
                                        dayLabels[index],
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 13,
                                          fontWeight: isToday
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isToday
                                              ? FluentianColors.warning
                                              : FluentianColors.textSecondary,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            LText(
                              dayLabels[index],
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 11,
                                fontWeight: isToday
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: isToday
                                    ? FluentianColors.warning
                                    : FluentianColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(text: 'LEARNING RHYTHM'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _panelDecoration(radius: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: FluentianColors.primaryTint,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: const Icon(
                        Iconsax.chart_2,
                        color: FluentianColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    LText(
                      'Learning summary',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SummaryLine(
                  icon: Iconsax.book5,
                  label: 'Units completed',
                  value: '$units',
                ),
                _SummaryLine(
                  icon: Iconsax.status_up,
                  label: 'Daily goal',
                  value: '${user.dailyGoalMinutes} min',
                ),
                _SummaryLine(
                  icon: Iconsax.notification,
                  label: 'Daily reminder',
                  value: user.learningReminderEnabled
                      ? user.reminderTime
                      : 'Off',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
              icon: const Icon(Iconsax.user_edit),
              label: const LText('Personalize my profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FluentianColors.textPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
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
      decoration: _metricDecoration(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: LText(
                  value,
                  maxLines: 1,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: FluentianColors.textPrimary,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              LText(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.textSecondary,
                ),
              ),
            ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: FluentianColors.pageBg,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: FluentianColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: FluentianColors.primaryTint,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Icon(icon, color: FluentianColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LText(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: FluentianColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          LText(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
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

  const _Pill({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          LText(
            text,
            style: GoogleFonts.ibmPlexSans(
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

BoxDecoration _heroDecoration() => BoxDecoration(
  gradient: FluentianColors.headerGradient,
  borderRadius: BorderRadius.circular(0),
  boxShadow: [
    FluentianShadows.subtle,
  ],
);

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: LText(
      text,
      style: FluentianTheme.label(color: FluentianColors.textSecondary),
    ),
  );
}

class _InviteCard extends StatelessWidget {
  final String username;
  const _InviteCard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          const Icon(
            Iconsax.user_add,
            color: FluentianColors.primary,
            size: 25,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  'Learn together',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                LText(
                  'Invite a friend and keep each other motivated.',
                  style: TextStyle(
                    fontSize: 12,
                    color: FluentianColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Share invite',
            onPressed: () => ReferralService.instance.shareInvite(username),
            icon: const Icon(Iconsax.share, color: FluentianColors.primary),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _panelDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: FluentianColors.border),
  boxShadow: [FluentianShadows.subtle],
);

BoxDecoration _metricDecoration(Color color) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(0),
  border: Border.all(color: color.withValues(alpha: 0.14)),
  boxShadow: [FluentianShadows.subtle],
);

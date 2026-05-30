import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/bottom_nav.dart';
import 'profile_screen.dart';
import 'lesson_list_screen.dart';
import 'lesson_detail_screen.dart';
import 'social_screen.dart';
import 'opportunity_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeContent(),
      const SocialScreen(),
      const OpportunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: IndexedStack(index: _navIndex, children: screens),
      bottomNavigationBar: FluentianBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<AuthProvider, ContentProvider>(
        builder: (context, auth, content, _) {
          if (content.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (content.status == ContentStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content.error ?? 'Connection error',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => content.loadHomeData(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = auth.user;
          final stats = content.stats;
          final xp = stats?.totalXp ?? 0;
          final streak = stats?.streakDays ?? 0;
          final hearts = stats?.hearts ?? 5;

          final xpForNextLevel = 500; // Simplified for MVP
          final xpProgress = xp % xpForNextLevel;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user?.greeting ?? "Hello"}, ${user?.displayName ?? "Learner"}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.textPrimary,
                          ),
                        ),
                      ),
                      StatChip(
                        emoji: '🔥',
                        value: '$streak',
                        color: FluentianColors.accent,
                        bgColor: FluentianColors.accentTint,
                      ),
                      const SizedBox(width: 6),
                      StatChip(
                        icon: Icons.bolt_rounded,
                        value: '$xp XP',
                        color: FluentianColors.primary,
                        bgColor: FluentianColors.primaryTint,
                      ),
                      const SizedBox(width: 6),
                      StatChip(
                        icon: Icons.favorite_rounded,
                        value: '$hearts/5',
                        color: FluentianColors.error,
                        bgColor: FluentianColors.errorTint,
                      ),
                    ],
                  ),
                ),

                // Streak banner
                if (streak > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: FluentianColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$streak-day streak!',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Don\'t break it — practice today',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Iconsax.flash_15,
                                color: Colors.white,
                                size: 40,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: xpProgress / xpForNextLevel,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$xpProgress / $xpForNextLevel XP to next level',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Continue learning
                SectionHeader(
                  title: 'Continue learning',
                  actionText: 'View all',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LessonListScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: Builder(
                    builder: (context) {
                      final nextLessons = content.getIncompleteLessons(3);
                      if (nextLessons.isEmpty) {
                        return Center(
                          child: Text(
                            'All caught up!',
                            style: GoogleFonts.inter(
                              color: FluentianColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: nextLessons.map((l) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LessonDetailScreen(lessonId: l.id),
                                ),
                              );
                            },
                            child: _LessonCard(
                              title: l.title,
                              unit: 'Next up',
                              iconData: Iconsax.book_1,
                              xp: '${l.xpReward} XP',
                              progress: 0.0,
                              color: FluentianColors.primary,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Daily challenge
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FluentianColors.accentTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: FluentianColors.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.cup5,
                          color: FluentianColors.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAILY CHALLENGE',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: FluentianColors.accent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Complete 3 lessons today',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: FluentianColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 22,
                          lineWidth: 4,
                          percent: 2 / 3,
                          center: Text(
                            '2/3',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.primary,
                            ),
                          ),
                          progressColor: FluentianColors.primary,
                          backgroundColor: FluentianColors.primary.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Your learning path
                if (content.courses.isNotEmpty) ...[
                  const SectionHeader(title: 'Your learning path'),
                  const SizedBox(height: 12),
                  ..._buildUnitList(context, content),
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildUnitList(BuildContext context, ContentProvider content) {
    if (content.courses.isEmpty) return [];

    final course = content.courses.first;
    final units = course.units;

    if (units.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'No units available yet.',
            style: GoogleFonts.inter(color: FluentianColors.textSecondary),
          ),
        ),
      ];
    }

    return units.map((u) {
      int completedLessons = 0;
      for (final lesson in u.lessons) {
        if (content.isLessonCompleted(lesson.id)) completedLessons++;
      }
      final totalLessons = u.lessons.length;
      final progress = totalLessons > 0
          ? (completedLessons / totalLessons)
          : 0.0;

      // A unit is locked if the previous unit is NOT fully completed.
      // (For MVP, let's keep all units unlocked, or unlock based on the first lesson)
      final locked = !content.isLessonUnlocked(u.lessons, 0);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: GestureDetector(
          onTap: locked
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LessonListScreen(initialUnitId: u.id),
                  ),
                ),
          child: AnimatedOpacity(
            opacity: locked ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                boxShadow: [FluentianShadows.subtle],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: FluentianColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.auto_stories_rounded,
                          size: 22,
                          color: FluentianColors.primary,
                        ),
                        if (locked)
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Unit ${u.unitNo} · ${course.levelMin}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$completedLessons/$totalLessons',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CircularPercentIndicator(
                        radius: 16,
                        lineWidth: 3,
                        percent: progress,
                        progressColor: FluentianColors.primary,
                        backgroundColor: FluentianColors.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _LessonCard extends StatelessWidget {
  final String title, unit, xp;
  final IconData iconData;
  final double progress;
  final Color color;
  const _LessonCard({
    required this.title,
    required this.unit,
    required this.iconData,
    required this.xp,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillBadge(
            text: unit,
            bgColor: color.withValues(alpha: 0.15),
            textColor: color,
            fontSize: 11,
          ),
          const Spacer(),
          Center(
            child: Icon(iconData, color: FluentianColors.primary, size: 28),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FluentianColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              XpChip(value: xp),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

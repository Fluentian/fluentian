import 'package:fluentian/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../services/notifications_api.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/bottom_nav.dart';
import 'profile_screen.dart';
import 'lesson_list_screen.dart';
import 'lesson_detail_screen.dart';
import 'opportunity_screen.dart';
import 'explore_screen.dart';
import 'notifications_screen.dart';
import 'srs_review_screen.dart';

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
      const ExploreScreen(),
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

class _HomeContent extends StatefulWidget {
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshHearts();
    });
  }

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
          final hearts = auth.user?.hearts ?? stats?.hearts ?? 5;

          final xpForNextLevel = 500; // Simplified for MVP
          final xpProgress = xp % xpForNextLevel;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHero(
                  greeting: user?.greeting ?? 'Hello',
                  displayName: user?.displayName ?? 'Learner',
                  streak: streak,
                  xp: xp,
                  xpProgress: xpProgress,
                  xpForNextLevel: xpForNextLevel,
                  hearts: hearts,
                  maxHearts: auth.maxHearts,
                  nextHeartRefillAt: auth.nextHeartRefillAt,
                  onHeartRefreshDue: () => auth.refreshHearts(),
                ),
                const SizedBox(height: 20),

                // SRS Daily Review Banner
                FutureBuilder<List<QuestionModel>>(
                  future: content.getDueSrsQuestions(),
                  builder: (context, snapshot) {
                    final dueQuestions = snapshot.data;
                    if (dueQuestions != null && dueQuestions.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SrsReviewScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: FluentianColors.border),
                              boxShadow: [FluentianShadows.subtle],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: FluentianColors.primaryTint,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Iconsax.message5,
                                    color: FluentianColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daily Review Time!',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: FluentianColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${dueQuestions.length} questions ready for you',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: FluentianColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  height: 42,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SrsReviewScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: FluentianColors.primary,
                                      minimumSize: const Size(84, 42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Review',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                Builder(
                  builder: (context) {
                    final assessment = content.firstLessonByKind('exam_drill');
                    if (assessment == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  LessonDetailScreen(lessonId: assessment.id),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: FluentianColors.border),
                              boxShadow: [FluentianShadows.subtle],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: FluentianColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Iconsax.task_square,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Final assessment',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: FluentianColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Check your progress and unlock what is next',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: FluentianColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Iconsax.arrow_right_3,
                                  color: FluentianColors.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

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
                  height: 132,
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
                          return _LessonCard(
                            title: l.title,
                            unit: 'Next up',
                            iconData: Iconsax.book_1,
                            xp: '${l.xpReward} XP',
                            progress: 0.0,
                            color: FluentianColors.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      LessonDetailScreen(lessonId: l.id),
                                ),
                              );
                            },
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: FluentianColors.border),
                      boxShadow: [FluentianShadows.subtle],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Iconsax.cup5,
                            color: Color(0xFFF97316),
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAILY CHALLENGE',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFF97316),
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Complete 3 lessons today',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: FluentianColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircularPercentIndicator(
                          radius: 24,
                          lineWidth: 5,
                          percent: 2 / 3,
                          center: Text(
                            '2/3',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFF97316),
                            ),
                          ),
                          progressColor: const Color(0xFFF97316),
                          backgroundColor: const Color(
                            0xFFF97316,
                          ).withValues(alpha: 0.15),
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
                          Iconsax.book_1,
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
                              Iconsax.lock,
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
                      mainAxisSize: MainAxisSize.min,
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
                    mainAxisSize: MainAxisSize.min,
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

class _HomeHero extends StatelessWidget {
  static const _fullHeartMessages = [
    'Ready for a French streak',
    'Full hearts, full focus',
    'Practice energy restored',
    'You are lesson-ready',
  ];

  final String greeting;
  final String displayName;
  final int streak;
  final int xp;
  final int xpProgress;
  final int xpForNextLevel;
  final int hearts;
  final int maxHearts;
  final DateTime? nextHeartRefillAt;
  final VoidCallback onHeartRefreshDue;

  const _HomeHero({
    required this.greeting,
    required this.displayName,
    required this.streak,
    required this.xp,
    required this.xpProgress,
    required this.xpForNextLevel,
    required this.hearts,
    required this.maxHearts,
    required this.nextHeartRefillAt,
    required this.onHeartRefreshDue,
  });

  @override
  Widget build(BuildContext context) {
    final levelProgress = (xpProgress / xpForNextLevel).clamp(0.0, 1.0);
    final heartsFull = hearts >= maxHearts;
    final now = DateTime.now();
    final fullHeartMessage =
        _fullHeartMessages[(now.day + now.hour) % _fullHeartMessages.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: FluentianColors.border),
          boxShadow: [FluentianShadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          color: FluentianColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        streak > 0
                            ? '$streak day streak is active. Keep it warm today.'
                            : 'Start a streak with one focused lesson today.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _NotificationButton(),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HeroStatTile(
                    icon: Iconsax.flash_15,
                    label: 'Streak',
                    value: '${streak}d',
                    tint: const Color(0xFFFFF7ED),
                    color: const Color(0xFFF97316),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeroStatTile(
                    icon: Iconsax.award5,
                    label: 'XP',
                    value: _compactNumber(xp),
                    tint: const Color(0xFFEFF6FF),
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _HeroStatTile(
                    icon: Iconsax.heart5,
                    label: 'Hearts',
                    value: '$hearts/$maxHearts',
                    tint: FluentianColors.errorTint,
                    color: FluentianColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: FluentianColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.status_up,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level progress',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$xpProgress / $xpForNextLevel XP to next level',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: heartsFull
                    ? FluentianColors.successTint
                    : FluentianColors.errorTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: heartsFull
                      ? FluentianColors.success.withValues(alpha: 0.18)
                      : FluentianColors.error.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    heartsFull ? Iconsax.tick_circle : Iconsax.timer_1,
                    size: 20,
                    color: heartsFull
                        ? FluentianColors.success
                        : FluentianColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      heartsFull ? fullHeartMessage : 'Next heart refill',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  HeartStatusChip(
                    hearts: hearts,
                    maxHearts: maxHearts,
                    nextRefillAt: nextHeartRefillAt,
                    showHearts: false,
                    onRefreshDue: onHeartRefreshDue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return '$value';
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: NotificationsApi.instance.getUnreadCount(),
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: FluentianColors.pageBg,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Iconsax.notification,
                    color: FluentianColors.textPrimary,
                    size: 21,
                  ),
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: const BoxDecoration(
                    color: FluentianColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color tint;
  final Color color;

  const _HeroStatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FluentianColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 4, color: color),
          ),
          Positioned(
            right: -10,
            bottom: -12,
            child: Icon(icon, color: color.withValues(alpha: 0.07), size: 58),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.12)),
                  ),
                  child: Center(
                    child: Transform.translate(
                      offset: icon == Iconsax.award5
                          ? const Offset(0, 1)
                          : Offset.zero,
                      child: Icon(icon, color: color, size: 17),
                    ),
                  ),
                ),
                Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        value,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: FluentianColors.textPrimary,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: FluentianColors.textSecondary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final String title, unit, xp;
  final IconData iconData;
  final double progress;
  final Color color;
  final VoidCallback onTap;
  const _LessonCard({
    required this.title,
    required this.unit,
    required this.iconData,
    required this.xp,
    required this.progress,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 232,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FluentianColors.border),
              boxShadow: [FluentianShadows.subtle],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: FluentianColors.primaryTint,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        iconData,
                        color: FluentianColors.primary,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PillBadge(
                                text: unit,
                                bgColor: color.withValues(alpha: 0.12),
                                textColor: color,
                                fontSize: 10,
                              ),
                              const Spacer(),
                              XpChip(value: xp),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: color.withValues(alpha: 0.14),
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.arrow_right_3,
                        color: Colors.white,
                        size: 16,
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
  }
}

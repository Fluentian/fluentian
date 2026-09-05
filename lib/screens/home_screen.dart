import 'dart:async';
import 'package:fluentian/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../services/in_app_notification_service.dart';
import '../local_db/app_database.dart';
import '../services/outbox_manager.dart';
import '../services/notifications_api.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';
import '../core/constants.dart';
import '../widgets/common_widgets.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tibeb_band.dart';
import 'profile_screen.dart';
import 'lesson_list_screen.dart';
import 'lesson_detail_screen.dart';
import 'explore_screen.dart';
import 'community_screen.dart';
import 'opportunity_screen.dart';
import 'notifications_screen.dart';
import 'srs_review_screen.dart';
import '../widgets/user_avatar.dart';
import '../widgets/avatar_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final Set<int> _activatedTabs = {0}; // Only Home is active initially
  late final List<Widget?> _tabWidgets = List.filled(5, null);

  @override
  void initState() {
    super.initState();
    _tabWidgets[0] = _HomeContent(key: const ValueKey('tab_home'));
  }

  Widget _getTabWidget(int index) {
    if (_tabWidgets[index] != null) return _tabWidgets[index]!;

    switch (index) {
      case 0:
        _tabWidgets[0] = _HomeContent(key: const ValueKey('tab_home'));
        break;
      case 1:
        _tabWidgets[1] = const ExploreScreen(key: ValueKey('tab_explore'));
        break;
      case 2:
        _tabWidgets[2] = const CommunityScreen(key: ValueKey('tab_community'));
        break;
      case 3:
        _tabWidgets[3] = const OpportunityScreen(key: ValueKey('tab_board'));
        break;
      case 4:
        _tabWidgets[4] = const ProfileScreen(key: ValueKey('tab_profile'));
        break;
    }
    return _tabWidgets[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: IndexedStack(
        index: _navIndex,
        children: List.generate(5, (index) {
          if (!_activatedTabs.contains(index)) {
            return const SizedBox.shrink();
          }
          return _getTabWidget(index);
        }),
      ),
      bottomNavigationBar: FluentianBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (_navIndex != i) {
            setState(() {
              _activatedTabs.add(i);
              _navIndex = i;
            });
          }
        },
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({super.key});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  Future<List<QuestionModel>>? _dueQuestionsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initialLoad();
    });
  }

  Future<void> _initialLoad() async {
    final content = context.read<ContentProvider>();
    final auth = context.read<AuthProvider>();
    // Sequential to avoid a burst of new TLS connections on cold start; the
    // shared keep-alive client reuses one connection. See ApiClient._client.
    if (content.courses.isEmpty || content.status == ContentStatus.idle) {
      await content.loadHomeData();
    }
    await content.loadLessonProgress();
    await auth.refreshHearts();
    if (!mounted) return;
    setState(() {
      _dueQuestionsFuture = content.getDueSrsQuestions();
    });
  }

  void _refreshDueQuestions() {
    final future = context.read<ContentProvider>().getDueSrsQuestions();
    setState(() {
      _dueQuestionsFuture = future;
    });
  }

  Future<void> _refreshHome() async {
    final content = context.read<ContentProvider>();
    final auth = context.read<AuthProvider>();
    // Sequential (not Future.wait): avoid a burst of new connections on the
    // backend's flaky network path; keep-alive reuses one. See ApiClient._client.
    await content.loadHomeData(showLoading: false);
    await content.loadLessonProgress();
    await auth.refreshHearts();
    final dueQuestions = content.getDueSrsQuestions();
    await dueQuestions;
    if (!mounted) return;
    setState(() {
      _dueQuestionsFuture = dueQuestions;
    });
  }

  UnitModel? _unitForLesson(ContentProvider content, String lessonId) {
    for (final course in content.courses) {
      for (final unit in course.units) {
        if (unit.lessons.any((lesson) => lesson.id == lessonId)) return unit;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<AuthProvider, ContentProvider>(
        builder: (context, auth, content, _) {
          if (content.isLoading && content.courses.isEmpty) {
            return const _HomeSkeletonView();
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
                    LText(
                      content.error ?? 'Connection error',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 16,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => content.loadHomeData(),
                      child: const LText('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = auth.user;
          final stats = content.stats;
          final xp = stats?.totalXp ?? user?.xpTotal ?? 0;
          final streak = stats?.streakDays ?? user?.streakDays ?? 0;
          final hearts = auth.user?.hearts ?? stats?.hearts ?? 5;

          final xpForNextLevel = 500; // Simplified for MVP
          final xpProgress = xp % xpForNextLevel;
          final nextLessons = content.getIncompleteLessons(
            1,
            startingUnitNo: user?.startingUnitNo ?? 1,
          );
          final nextLesson = nextLessons.isEmpty ? null : nextLessons.first;
          final nextUnit = nextLesson == null
              ? null
              : _unitForLesson(content, nextLesson.id);
          // A lesson is designed as an approximately five-minute session.
          // Derive this challenge from the goal chosen during onboarding or
          // Settings instead of silently replacing it with three lessons.
          final dailyLessonGoal = lessonsForDailyGoalMinutes(
            user?.dailyGoalMinutes ?? 15,
          );
          final lessonsToday = content.lessonsCompletedToday.clamp(
            0,
            dailyLessonGoal,
          );
          final dailyChallengeComplete = lessonsToday >= dailyLessonGoal;

          return RefreshIndicator(
            onRefresh: _refreshHome,
            color: FluentianColors.primary,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHero(
                    greeting: user?.greeting ?? 'Hello',
                    displayName: user?.displayName ?? 'Learner',
                    avatarUrl: user?.avatarUrl,
                    streak: streak,
                    xp: xp,
                    xpProgress: xpProgress,
                    xpForNextLevel: xpForNextLevel,
                    hearts: hearts,
                    maxHearts: auth.maxHearts,
                    nextHeartRefillAt: auth.nextHeartRefillAt,
                    onHeartRefreshDue: () => auth.refreshHearts(),
                  ),
                  const _SyncStatusBanner(),
                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: content.courses.isEmpty
                        ? const _NoCoursesCard()
                        : nextLesson == null
                        ? _AllCaughtUpCard(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LessonListScreen(
                                  initialUnitId: nextUnit?.id,
                                ),
                              ),
                            ),
                          )
                        : _ContinueJourneyCard(
                            lesson: nextLesson,
                            chapterTitle:
                                nextUnit?.title ?? 'Your learning path',
                            chapterNumber: nextUnit?.unitNo,
                            onContinue: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    LessonDetailScreen(lessonId: nextLesson.id),
                              ),
                            ),
                          ),
                  ),

                  if (content.courses.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _HomeSectionLabel(text: 'YOUR LEARNING PATH'),
                    const SizedBox(height: 10),
                    LessonListScreen(
                      key: const ValueKey('home_roadmap'),
                      initialUnitId: nextUnit?.id,
                      embedded: true,
                    ),
                    const SizedBox(height: 24),
                    const _HomeSectionLabel(text: 'TODAY'),
                    const SizedBox(height: 10),

                    // SRS Daily Review Banner
                    FutureBuilder<List<QuestionModel>>(
                      future: _dueQuestionsFuture,
                      builder: (context, snapshot) {
                        final dueQuestions = snapshot.data;
                        if (dueQuestions != null && dueQuestions.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  color: FluentianColors.border,
                                ),
                                boxShadow: [FluentianShadows.subtle],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: FluentianColors.primaryTint,
                                      borderRadius: BorderRadius.circular(0),
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
                                        LText(
                                          'Daily Review Time!',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.ibmPlexSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: FluentianColors.textPrimary,
                                          ),
                                        ),
                                        LText(
                                          '${dueQuestions.length} questions ready for you',
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 13,
                                            color:
                                                FluentianColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    height: 42,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SrsReviewScreen(),
                                          ),
                                        );
                                        if (mounted) _refreshDueQuestions();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            FluentianColors.primary,
                                        minimumSize: const Size(84, 42),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const LText(
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
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Daily challenge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(0),
                          onTap: dailyChallengeComplete
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LessonListScreen(
                                      initialUnitId: nextUnit?.id,
                                    ),
                                  ),
                                ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(
                                color: dailyChallengeComplete
                                    ? FluentianColors.success.withValues(
                                        alpha: .35,
                                      )
                                    : FluentianColors.border,
                              ),
                              boxShadow: [FluentianShadows.subtle],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: dailyChallengeComplete
                                        ? FluentianColors.success.withValues(
                                            alpha: .12,
                                          )
                                        : FluentianColors.warningTint,
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Icon(
                                    dailyChallengeComplete
                                        ? Iconsax.tick_circle5
                                        : Iconsax.cup5,
                                    color: dailyChallengeComplete
                                        ? FluentianColors.success
                                        : FluentianColors.warning,
                                    size: 25,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr('DAILY CHALLENGE'),
                                        style: FluentianTheme.label(
                                          color: dailyChallengeComplete
                                              ? FluentianColors.success
                                              : FluentianColors.warning,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      LText(
                                        dailyChallengeComplete
                                            ? 'Daily challenge complete!'
                                            : 'Complete $dailyLessonGoal lessons today',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: FluentianColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CircularPercentIndicator(
                                  radius: 24,
                                  lineWidth: 5,
                                  percent: lessonsToday / dailyLessonGoal,
                                  center: Text(
                                    '$lessonsToday/$dailyLessonGoal',
                                    style: FluentianTheme.label(
                                      color: dailyChallengeComplete
                                          ? FluentianColors.success
                                          : FluentianColors.warning,
                                    ),
                                  ),
                                  progressColor: dailyChallengeComplete
                                      ? FluentianColors.success
                                      : FluentianColors.warning,
                                  backgroundColor: dailyChallengeComplete
                                      ? FluentianColors.successTint
                                      : FluentianColors.warningTint,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SyncStatusBanner extends StatefulWidget {
  const _SyncStatusBanner();
  @override
  State<_SyncStatusBanner> createState() => _SyncStatusBannerState();
}

class _SyncStatusBannerState extends State<_SyncStatusBanner> {
  Future<int> _failed() => AppDatabase.instance.getFailedOutboxCount();
  @override
  Widget build(BuildContext context) => FutureBuilder<int>(
    future: _failed(),
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;
      if (count == 0) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Card(
          color: FluentianColors.errorTint,
          child: ListTile(
            leading: const Icon(
              Icons.cloud_off_rounded,
              color: FluentianColors.error,
            ),
            title: const LText('Some progress could not sync'),
            subtitle: LText('$count item(s) need another try'),
            trailing: TextButton(
              onPressed: () async {
                await OutboxManager.instance.retryFailed();
                if (mounted) setState(() {});
              },
              child: const LText('Retry'),
            ),
          ),
        ),
      );
    },
  );
}

class _NoCoursesCard extends StatelessWidget {
  const _NoCoursesCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(0),
      border: Border.all(color: FluentianColors.border),
      boxShadow: [FluentianShadows.subtle],
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: FluentianColors.primaryTint,
            borderRadius: BorderRadius.circular(0),
          ),
          child: const Icon(
            Iconsax.book_1,
            color: FluentianColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(
                'Your journey is being prepared',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              LText(
                'Your first course will appear here as soon as it is ready.',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AllCaughtUpCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AllCaughtUpCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FluentianColors.successTint,
      borderRadius: BorderRadius.circular(0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: FluentianColors.success),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(color: FluentianColors.white),
                child: const Icon(
                  Iconsax.tick_circle5,
                  color: FluentianColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      'You’re all caught up',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    LText(
                      'Browse the roadmap and revisit any lesson.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: FluentianColors.success,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueJourneyCard extends StatelessWidget {
  final LessonModel lesson;
  final String chapterTitle;
  final int? chapterNumber;
  final VoidCallback onContinue;

  const _ContinueJourneyCard({
    required this.lesson,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final chapterLabel = chapterNumber == null
        ? 'CURRENT MISSION'
        : 'CHAPTER $chapterNumber · CURRENT MISSION';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: FluentianColors.primary,
      ),
      child: Stack(
        children: [
          // Was a 158px map glyph bled off the corner at 7% white -- the
          // faded-watermark-icon move, filling space with something nobody
          // can quite see. The band is the app's own mark and it means
          // something: it is the progress language.
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TibebBand(height: 10),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The French blue measured 2.17:1 against this navy card --
                // legible to nobody. Now the on-ink accent, at 8.59:1.
                Text(
                  context.tr(chapterLabel),
                  style: FluentianTheme.label(
                    color: FluentianColors.onInkAccent,
                  ),
                ),
                const SizedBox(height: 8),
                LText(
                  lesson.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 22,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: FluentianColors.onInk,
                  ),
                ),
                const SizedBox(height: 6),
                LText(
                  chapterTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 13.5,
                    height: 1.35,
                    color: FluentianColors.onInkMuted,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _MissionDetail(
                      icon: Iconsax.timer_1,
                      text: '${lesson.estimatedMinutes} min',
                    ),
                    const SizedBox(width: 14),
                    _MissionDetail(
                      icon: Iconsax.flash_15,
                      text: '${lesson.xpReward} XP',
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: onContinue,
                      icon: const Icon(Iconsax.play, size: 17),
                      label: const LText('Start'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: FluentianColors.primary,
                        minimumSize: const Size(102, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        textStyle: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
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

class _MissionDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MissionDetail({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: FluentianColors.onInkMuted),
      const SizedBox(width: 6),
      Text(
        text,
        style: FluentianTheme.label(color: FluentianColors.onInkMuted),
      ),
    ],
  );
}

class _HomeSectionLabel extends StatelessWidget {
  final String text;

  const _HomeSectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(context.tr(text), style: FluentianTheme.label()),
  );
}

class _HomeHero extends StatelessWidget {
  final String greeting;
  final String displayName;
  final String? avatarUrl;
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
    this.avatarUrl,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: FluentianColors.headerGradient,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Stack(
          children: [
            // Second 175px watermark glyph, gone for the same reason as the
            // first.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(greeting).toUpperCase(),
                              style: FluentianTheme.label(
                                color: FluentianColors.onInkAccent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LText(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.bricolageGrotesque(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: FluentianColors.onInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _NotificationButton(inverted: true),
                      const SizedBox(width: 10),
                      UserAvatar(
                        avatarUrl: avatarUrl,
                        name: displayName,
                        size: 44,
                        onTap: () => AvatarPickerSheet.show(
                          context,
                          currentAvatarUrl: avatarUrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LText(
                    streak > 0
                        ? 'Your $streak-day streak is waiting for today’s win.'
                        : 'One small lesson is all it takes to begin.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 13.5,
                      color: FluentianColors.onInkMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroPill(
                        icon: Iconsax.flash_15,
                        text: streak > 0
                            ? '$streak day streak'
                            : 'Start streak',
                      ),
                      HeartStatusChip(
                        hearts: hearts,
                        maxHearts: maxHearts,
                        nextRefillAt: nextHeartRefillAt,
                        compact: true,
                        onRefreshDue: onHeartRefreshDue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      // .7 white on this navy is 3.28:1 -- under the 4.5:1
                      // a label this small needs.
                      Text(
                        context.tr('LEVEL PROGRESS'),
                        style: FluentianTheme.label(
                          color: FluentianColors.onInkMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_compactNumber(xp)} XP',
                        style: FluentianTheme.label(
                          size: 12,
                          color: FluentianColors.onInk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Squared, and filled with the on-ink accent: the French
                  // blue was 2.17:1 here, below the 3:1 a UI component needs
                  // to be seen at all.
                  LinearProgressIndicator(
                    value: levelProgress,
                    minHeight: 7,
                    backgroundColor: FluentianColors.darkBorder,
                    valueColor: const AlwaysStoppedAnimation(
                      FluentianColors.onInkAccent,
                    ),
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

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: const BoxDecoration(
      color: FluentianColors.darkCard,
      border: Border.fromBorderSide(
        BorderSide(color: FluentianColors.darkBorder),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Was the warning brown (#7F5200) on a translucent navy pill --
        // effectively invisible.
        Icon(icon, color: FluentianColors.onInkAccent, size: 15),
        const SizedBox(width: 6),
        Text(
          text,
          style: FluentianTheme.label(color: FluentianColors.onInk),
        ),
      ],
    ),
  );
}

class _NotificationButton extends StatefulWidget {
  final bool inverted;

  const _NotificationButton({this.inverted = false});

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  late Future<int> _unreadFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _unreadFuture = _getUnreadCount();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _reload(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<int> _getUnreadCount() async {
    final results = await Future.wait([
      NotificationsApi.instance.getUnreadCount().catchError((_) => 0),
      InAppNotificationService.instance.getUnreadCount().catchError((_) => 0),
    ]);
    return results.fold<int>(0, (sum, count) => sum + count);
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _unreadFuture = _getUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _unreadFuture,
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: widget.inverted
                  ? Colors.white.withValues(alpha: .13)
                  : FluentianColors.pageBg,
              borderRadius: BorderRadius.circular(0),
              child: InkWell(
                borderRadius: BorderRadius.circular(0),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                  if (mounted) _reload();
                },
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Iconsax.notification,
                    color: widget.inverted
                        ? Colors.white
                        : FluentianColors.textPrimary,
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
                    child: LText(
                      unread > 9 ? '9+' : '$unread',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final opacity = 0.25 + (_ctrl.value * 0.35);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: FluentianColors.border.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class _HomeSkeletonView extends StatelessWidget {
  const _HomeSkeletonView();

  @override
  Widget build(BuildContext context) {
    return const FluentianShimmer(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonHeroCard(),
            SizedBox(height: 20),
            SkeletonMissionCard(),
            SizedBox(height: 16),
            SkeletonChallengeCard(),
            SizedBox(height: 24),
            _HomeSectionLabel(text: 'YOUR LEARNING PATH'),
            SizedBox(height: 10),
            SkeletonRoadmap(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

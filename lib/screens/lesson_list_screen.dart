import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
import '../providers/content_provider.dart';
import '../providers/auth_provider.dart';
import 'lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String? initialUnitId;
  const LessonListScreen({super.key, this.initialUnitId});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _unitKeys = {};
  final Set<String> _collapsedUnitIds = {};
  String? _pendingInitialUnitId;
  String? _focusedUnitId;
  bool _initialFocusQueued = false;

  @override
  void initState() {
    super.initState();
    _pendingInitialUnitId = widget.initialUnitId;
  }

  @override
  void didUpdateWidget(covariant LessonListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUnitId != widget.initialUnitId) {
      _pendingInitialUnitId = widget.initialUnitId;
      _focusedUnitId = null;
      if (widget.initialUnitId != null) {
        _collapsedUnitIds.remove(widget.initialUnitId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleInitialUnitFocus() {
    final unitId = _pendingInitialUnitId;
    if (unitId == null || _initialFocusQueued) return;

    _initialFocusQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialFocusQueued = false;
      if (!mounted || _pendingInitialUnitId != unitId) return;

      final unitContext = _unitKeys[unitId]?.currentContext;
      if (unitContext == null) return;

      setState(() {
        _collapsedUnitIds.remove(unitId);
        _focusedUnitId = unitId;
        _pendingInitialUnitId = null;
      });

      // The full route is deliberately built before this is called, so this
      // key is available even when the active chapter is deep in another
      // course. Waiting one more frame also lets an expanded unit lay out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final targetContext = _unitKeys[unitId]?.currentContext;
        if (targetContext == null) return;
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.08,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic,
        );
      });
    });
  }

  bool _isUnitExpanded(String unitId) => !_collapsedUnitIds.contains(unitId);

  void _toggleUnit(String unitId) {
    setState(() {
      if (_collapsedUnitIds.contains(unitId)) {
        _collapsedUnitIds.remove(unitId);
      } else {
        _collapsedUnitIds.add(unitId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: LText(
          'Learning Path',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FluentianColors.textPrimary,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: FluentianColors.textPrimary),
      ),
      body: Consumer<ContentProvider>(
        builder: (context, content, _) {
          if (content.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (content.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.book_1, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  LText(
                    'No courses loaded yet.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final allUnits = content.courses.expand((course) => course.units);
          final allLessons = allUnits.expand((unit) => unit.lessons).toList();
          final totalUnits = content.courses.fold<int>(
            0,
            (count, course) => count + course.units.length,
          );
          final totalLessons = allLessons.length;
          final completedLessons = allLessons
              .where((lesson) => content.isLessonCompleted(lesson.id))
              .length;
          final progressPercent = totalLessons > 0
              ? (completedLessons / totalLessons)
              : 0.0;
          final startingUnitNo =
              context.watch<AuthProvider>().user?.startingUnitNo ?? 1;
          final items = _buildPathItems(
            content.courses,
            content,
            startingUnitNo,
          );
          final requestedUnitId = _pendingInitialUnitId;
          final requestedUnitExists =
              requestedUnitId != null &&
              content.courses.any(
                (course) =>
                    course.units.any((unit) => unit.id == requestedUnitId),
              );
          if (requestedUnitExists) {
            // An explicit route should always reveal its destination, even if
            // this screen instance previously had that chapter collapsed.
            _collapsedUnitIds.remove(requestedUnitId);
            _scheduleInitialUnitFocus();
          } else if (requestedUnitId != null) {
            // Avoid retrying forever if a stale deep link points to content
            // that is no longer available to this learner.
            _pendingInitialUnitId = null;
          }

          return Column(
            children: [
              // Whole-journey progress keeps multiple courses from looking
              // like unrelated lists while the route below retains a clear
              // course boundary for each chapter set.
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [FluentianShadows.subtle],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: FluentianColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, 1),
                        child: const Icon(
                          Iconsax.award5,
                          color: FluentianColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LText(
                            'Your learning journey',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPercent,
                              backgroundColor: FluentianColors.primary
                                  .withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation(
                                FluentianColors.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LText(
                            '$completedLessons of $totalLessons lessons complete · ${content.courses.length} ${content.courses.length == 1 ? 'course' : 'courses'} · $totalUnits ${totalUnits == 1 ? 'chapter' : 'chapters'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: FluentianColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // This intentionally builds the complete path. Apart from
                    // being a more natural journey view, it guarantees that a
                    // deep-linked active chapter has a mounted key for
                    // Scrollable.ensureVisible (a lazy ListView does not).
                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 40),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: Column(
                          children: [
                            for (final item in items)
                              if (item is _CourseHeaderItem)
                                _buildCourseHeader(item, content)
                              else if (item is _UnitHeaderItem)
                                Container(
                                  key: _unitKeys.putIfAbsent(
                                    item.unit.id,
                                    () => GlobalKey(),
                                  ),
                                  child: _buildUnitHeader(
                                    context,
                                    item.unit,
                                    content,
                                    isExpanded: _isUnitExpanded(item.unit.id),
                                    isFocused: item.unit.id == _focusedUnitId,
                                  ),
                                )
                              else if (item is _LessonNodeItem)
                                constraints.maxWidth < 330
                                    ? _buildLessonNode(
                                        context,
                                        item,
                                        constraints,
                                      )
                                    : _buildJourneyNode(
                                        context,
                                        item,
                                        constraints,
                                      ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_PathItem> _buildPathItems(
    List<CourseModel> courses,
    ContentProvider content,
    int startingUnitNo,
  ) {
    final List<_PathItem> items = [];
    if (courses.isEmpty) return items;

    for (int courseIndex = 0; courseIndex < courses.length; courseIndex++) {
      final course = courses[courseIndex];
      final units = List<UnitModel>.of(course.units)
        ..sort((a, b) => a.unitNo.compareTo(b.unitNo));
      items.add(
        _CourseHeaderItem(
          course: course,
          courseIndex: courseIndex,
          courseCount: courses.length,
        ),
      );

      for (int unitIndex = 0; unitIndex < units.length; unitIndex++) {
        final unit = units[unitIndex];
        items.add(_UnitHeaderItem(unit));

        if (!_isUnitExpanded(unit.id)) continue;

        final lessons = List<LessonModel>.of(unit.lessons)
          ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
        final isPlacedBeforeStartingChapter = unit.unitNo < startingUnitNo;
        final previousUnitCompleted =
            unitIndex > 0 &&
            units[unitIndex - 1].lessons.every(
              (lesson) => content.isLessonCompleted(lesson.id),
            );
        // These mirror the learner-placement rules used on home: chapters
        // before the assigned starting point are available for review, while
        // later chapters wait for their immediate predecessor to be complete.
        final chapterUnlocked =
            unit.unitNo <= startingUnitNo || previousUnitCompleted;

        for (int i = 0; i < lessons.length; i++) {
          final lesson = lessons[i];
          final isCompleted = content.isLessonCompleted(lesson.id);
          final previousLessonCompleted =
              i == 0 || content.isLessonCompleted(lessons[i - 1].id);
          final isUnlocked =
              isPlacedBeforeStartingChapter ||
              (chapterUnlocked && previousLessonCompleted);
          final isActive =
              !isPlacedBeforeStartingChapter && !isCompleted && isUnlocked;

          items.add(
            _LessonNodeItem(
              lesson: lesson,
              lessonIndex: i,
              isCompleted: isCompleted,
              isUnlocked: isUnlocked,
              isActive: isActive,
              isLastInUnit: i == lessons.length - 1,
              unitNo: unit.unitNo,
            ),
          );
        }
      }
    }

    return items;
  }

  Widget _buildCourseHeader(_CourseHeaderItem item, ContentProvider content) {
    final lessons = item.course.units
        .expand((unit) => unit.lessons)
        .toList(growable: false);
    final completedLessons = lessons
        .where((lesson) => content.isLessonCompleted(lesson.id))
        .length;
    final isFocusedCourse = item.course.units.any(
      (unit) => unit.id == _focusedUnitId,
    );
    final level = item.course.levelMin == item.course.levelMax
        ? '${item.course.levelMin} level'
        : '${item.course.levelMin}–${item.course.levelMax}';

    return Container(
      margin: EdgeInsets.fromLTRB(16, item.courseIndex == 0 ? 14 : 30, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFocusedCourse
                  ? FluentianColors.primary
                  : FluentianColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: LText(
              '${item.courseIndex + 1}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isFocusedCourse ? Colors.white : FluentianColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  isFocusedCourse
                      ? 'YOUR ACTIVE COURSE'
                      : 'COURSE ${item.courseIndex + 1} OF ${item.courseCount}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isFocusedCourse
                        ? FluentianColors.primary
                        : FluentianColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                LText(
                  _courseTitle(item.course),
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: FluentianColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LText(
                level.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.primary,
                  letterSpacing: 0.55,
                ),
              ),
              const SizedBox(height: 3),
              LText(
                '$completedLessons/${lessons.length}',
                style: GoogleFonts.inter(
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

  String _courseTitle(CourseModel course) {
    if (course.code == 'FR_A1_BASICS') return 'French A1 Basics';

    return course.code
        .split('_')
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Widget _buildUnitHeader(
    BuildContext context,
    UnitModel unit,
    ContentProvider content, {
    required bool isExpanded,
    required bool isFocused,
  }) {
    final completed = unit.lessons
        .where((lesson) => content.isLessonCompleted(lesson.id))
        .length;
    final progress = unit.lessons.isEmpty
        ? 0.0
        : completed / unit.lessons.length;
    return GestureDetector(
      onTap: () => _toggleUnit(unit.id),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FluentianColors.primary, FluentianColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(24),
          border: isFocused
              ? Border.all(color: FluentianColors.accent, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: FluentianColors.primary.withValues(
                alpha: isFocused ? 0.28 : 0.15,
              ),
              blurRadius: isFocused ? 18 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: LText(
                '${unit.unitNo}',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    isFocused
                        ? 'CURRENT CHAPTER · ${unit.unitKind.toUpperCase()}'
                        : 'CHAPTER ${unit.unitNo} · ${unit.unitKind.toUpperCase()}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LText(
                    unit.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.16,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              FluentianColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      LText(
                        '$completed/${unit.lessons.length}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  LText(
                    progress == 1
                        ? 'Chapter mastered · replay any mission'
                        : 'Follow the route to reach the chapter summit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                IconButton(
                  onPressed: () => _showGuidebookDialog(context, unit),
                  tooltip: context.tr('Open guidebook'),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: FluentianColors.primary,
                  ),
                  icon: const Icon(Iconsax.book_1, size: 18),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyNode(
    BuildContext context,
    _LessonNodeItem item,
    BoxConstraints constraints,
  ) {
    final visuals = _lessonVisuals(item.lesson.lessonKind);
    final width = constraints.maxWidth;
    final stops = <double>[0.24, 0.5, 0.76, 0.5];
    final stopIndex = item.lessonIndex % stops.length;
    final nextStopIndex = (item.lessonIndex + 1) % stops.length;
    final centerX = width * stops[stopIndex];
    final nextCenterX = width * stops[nextStopIndex];
    final placeCalloutRight = centerX <= width * 0.52;
    final calloutWidth = (width * 0.39).clamp(126.0, 162.0);
    final calloutLeft = placeCalloutRight
        ? (centerX + 44).clamp(12.0, width - calloutWidth - 12)
        : (centerX - calloutWidth - 44).clamp(12.0, width - calloutWidth - 12);
    final nodeColor = item.isCompleted
        ? FluentianColors.secondary
        : item.isActive
        ? FluentianColors.primary
        : Colors.grey.shade300;

    return SizedBox(
      height: 142,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!item.isLastInUnit)
            Positioned.fill(
              child: CustomPaint(
                painter: _JourneyRoutePainter(
                  start: Offset(centerX, 72),
                  end: Offset(nextCenterX, 142),
                  reached: item.isCompleted,
                ),
              ),
            ),
          if (item.isActive)
            Positioned(
              left: centerX - 42,
              top: 29,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FluentianColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: FluentianColors.primary.withValues(alpha: 0.13),
                    width: 2,
                  ),
                ),
              ),
            ),
          Positioned(
            left: centerX - 34,
            top: 37,
            child: Semantics(
              button: item.isUnlocked,
              label:
                  '${item.lesson.title}, ${item.isCompleted
                      ? 'completed'
                      : item.isActive
                      ? 'current mission'
                      : 'locked'}',
              child: GestureDetector(
                onTap: item.isUnlocked
                    ? () => _showLessonStartSheet(
                        context,
                        item.lesson,
                        item.isCompleted,
                      )
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nodeColor,
                    border: Border.all(
                      color: item.isUnlocked
                          ? Colors.white
                          : Colors.grey.shade100,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: nodeColor.withValues(
                          alpha: item.isActive ? 0.38 : 0.18,
                        ),
                        blurRadius: item.isActive ? 18 : 8,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.isCompleted
                        ? Icons.check_rounded
                        : item.isUnlocked
                        ? visuals.icon
                        : Icons.lock_rounded,
                    color: item.isUnlocked
                        ? Colors.white
                        : Colors.grey.shade500,
                    size: item.isCompleted ? 30 : 27,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: calloutLeft,
            top: 28,
            width: calloutWidth,
            child: GestureDetector(
              onTap: item.isUnlocked
                  ? () => _showLessonStartSheet(
                      context,
                      item.lesson,
                      item.isCompleted,
                    )
                  : null,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
                decoration: BoxDecoration(
                  color: item.isUnlocked
                      ? Colors.white
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.isActive
                        ? FluentianColors.primary.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: item.isUnlocked ? [FluentianShadows.subtle] : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: item.isUnlocked
                                ? visuals.color
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: LText(
                            item.isActive
                                ? 'CURRENT MISSION'
                                : visuals.label.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.55,
                              color: item.isUnlocked
                                  ? visuals.color
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LText(
                      item.lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.18,
                        fontWeight: FontWeight.w700,
                        color: item.isUnlocked
                            ? FluentianColors.textPrimary
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: item.isUnlocked
                              ? FluentianColors.warning
                              : Colors.grey.shade400,
                        ),
                        LText(
                          '${item.lesson.xpReward} XP',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        LText(
                          '${item.lesson.estimatedMinutes}m',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _LessonVisuals _lessonVisuals(String kind) {
    switch (kind) {
      case 'dialogue':
        return const _LessonVisuals(
          Iconsax.message5,
          Color(0xFF06B6D4),
          'Dialogue',
        );
      case 'grammar':
      case 'grammar_explainer':
        return const _LessonVisuals(
          Iconsax.book_14,
          FluentianColors.primary,
          'Grammar',
        );
      case 'speaking':
      case 'pronunciation':
      case 'roleplay_simulation':
        return const _LessonVisuals(
          Iconsax.microphone_24,
          Color(0xFFEC4899),
          'Speaking',
        );
      case 'quiz':
      case 'review':
      case 'exam_drill':
        return const _LessonVisuals(
          Iconsax.cup,
          FluentianColors.warning,
          'Challenge',
        );
      case 'listening':
        return const _LessonVisuals(
          Iconsax.headphone,
          Color(0xFF8B5CF6),
          'Listening',
        );
      case 'reading':
      case 'writing':
        return const _LessonVisuals(
          Iconsax.document_text_14,
          Color(0xFF3B82F6),
          'Story',
        );
      default:
        return const _LessonVisuals(
          Iconsax.category_24,
          FluentianColors.success,
          'Vocabulary',
        );
    }
  }

  // Compact fallback keeps metadata readable on very narrow devices.
  Widget _buildLessonNode(
    BuildContext context,
    _LessonNodeItem item,
    BoxConstraints constraints,
  ) {
    Color kindColor;
    IconData kindIcon;
    String kindText;

    switch (item.lesson.lessonKind) {
      case 'dialogue':
        kindColor = const Color(0xFF06B6D4);
        kindIcon = Iconsax.message5;
        kindText = 'Dialogue';
        break;
      case 'grammar':
        kindColor = FluentianColors.primary;
        kindIcon = Iconsax.book_14;
        kindText = 'Grammar';
        break;
      case 'speaking':
        kindColor = const Color(0xFFEC4899);
        kindIcon = Iconsax.microphone_24;
        kindText = 'Speaking';
        break;
      case 'quiz':
      case 'review':
        kindColor = const Color(0xFFF59E0B);
        kindIcon = Iconsax.document_text_14;
        kindText = 'Quiz';
        break;
      default:
        kindColor = FluentianColors.success;
        kindIcon = Iconsax.category_24;
        kindText = 'Vocabulary';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: item.isUnlocked ? Colors.white : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isActive
              ? FluentianColors.primary.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.05),
          width: item.isActive ? 1.5 : 1,
        ),
        boxShadow: item.isActive
            ? [
                BoxShadow(
                  color: FluentianColors.primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [FluentianShadows.subtle],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: item.isUnlocked ? kindColor : Colors.grey.shade300,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: item.isUnlocked
                              ? kindColor.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          kindIcon,
                          color: item.isUnlocked
                              ? kindColor
                              : Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                LText(
                                  kindText.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: item.isUnlocked
                                        ? kindColor
                                        : Colors.grey.shade500,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                if (item.isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FluentianColors.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: LText(
                                      'ACTIVE',
                                      style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: FluentianColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            LText(
                              item.lesson.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: item.isUnlocked
                                    ? FluentianColors.textPrimary
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  size: 12,
                                  color: item.isUnlocked
                                      ? FluentianColors.primary
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 2),
                                LText(
                                  '+${item.lesson.xpReward} XP',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: item.isUnlocked
                                        ? FluentianColors.textPrimary
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: item.isUnlocked
                                      ? Colors.blue
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(width: 2),
                                LText(
                                  '${item.lesson.estimatedMinutes}m',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: item.isUnlocked
                                        ? FluentianColors.textPrimary
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(child: _buildRightAction(context, item)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightAction(BuildContext context, _LessonNodeItem item) {
    if (!item.isUnlocked) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.lock_rounded, size: 14, color: Colors.grey.shade400),
      );
    }

    if (item.isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: FluentianColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showLessonStartSheet(context, item.lesson, true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: FluentianColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: LText(
                'REVIEW',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Active lesson
    return ElevatedButton(
      onPressed: () => _showLessonStartSheet(context, item.lesson, false),
      style: ElevatedButton.styleFrom(
        backgroundColor: FluentianColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: LText(
        'START',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showLessonStartSheet(
    BuildContext context,
    LessonModel lesson,
    bool isCompleted,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Color kindColor;
        IconData kindIcon;
        String kindText;

        switch (lesson.lessonKind) {
          case 'dialogue':
            kindColor = const Color(0xFF06B6D4);
            kindIcon = Iconsax.message5;
            kindText = 'Dialogue Practice';
            break;
          case 'grammar':
            kindColor = FluentianColors.primary;
            kindIcon = Iconsax.book_14;
            kindText = 'Grammar Focus';
            break;
          case 'speaking':
            kindColor = const Color(0xFFEC4899);
            kindIcon = Iconsax.microphone_24;
            kindText = 'Speaking Lesson';
            break;
          case 'quiz':
          case 'review':
            kindColor = const Color(0xFFF59E0B);
            kindIcon = Iconsax.document_text_14;
            kindText = 'Quiz / Review';
            break;
          default:
            kindColor = FluentianColors.success;
            kindIcon = Iconsax.category_24;
            kindText = 'Vocabulary Lesson';
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kindColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Icon(kindIcon, color: kindColor, size: 14),
                        const SizedBox(width: 6),
                        LText(
                          kindText.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: kindColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FluentianColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: FluentianColors.success,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          LText(
                            'COMPLETED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              LText(
                lesson.title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              LText(
                'Practice key expressions and improve your fluency in this session.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FluentianColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: FluentianColors.primary,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          LText(
                            '+${lesson.xpReward} XP',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          LText(
                            'Base Reward',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: FluentianColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.blue,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          LText(
                            '${lesson.estimatedMinutes} mins',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          LText(
                            'Est. Duration',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: FluentianColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonDetailScreen(lessonId: lesson.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kindColor,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: LText(
                  isCompleted ? 'PRACTICE AGAIN' : 'START LESSON',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGuidebookDialog(BuildContext context, UnitModel unit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Iconsax.book_1, color: FluentianColors.primary),
              const SizedBox(width: 8),
              LText(
                'Unit ${unit.unitNo} Guidebook',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(
                'Key Vocabulary & Grammar:',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              LText(
                'In this unit, you will learn the fundamentals of conversation for this level. Practice daily to master pronoun conjugations, basic sentence structure, and core vocabulary lists.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: FluentianColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              LText(
                'Lessons in this unit:',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...unit.lessons.take(4).map((l) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: FluentianColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LText(
                          l.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (unit.lessons.length > 4)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 14),
                  child: LText(
                    '+ ${unit.lessons.length - 4} more lessons',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: LText(
                'Close',
                style: GoogleFonts.inter(
                  color: FluentianColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Data structures for path flat list
abstract class _PathItem {}

class _CourseHeaderItem extends _PathItem {
  final CourseModel course;
  final int courseIndex;
  final int courseCount;

  _CourseHeaderItem({
    required this.course,
    required this.courseIndex,
    required this.courseCount,
  });
}

class _UnitHeaderItem extends _PathItem {
  final UnitModel unit;
  _UnitHeaderItem(this.unit);
}

class _LessonNodeItem extends _PathItem {
  final LessonModel lesson;
  final int lessonIndex;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isActive;
  final bool isLastInUnit;
  final int unitNo;

  _LessonNodeItem({
    required this.lesson,
    required this.lessonIndex,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isActive,
    required this.isLastInUnit,
    required this.unitNo,
  });
}

class _LessonVisuals {
  final IconData icon;
  final Color color;
  final String label;

  const _LessonVisuals(this.icon, this.color, this.label);
}

class _JourneyRoutePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final bool reached;

  const _JourneyRoutePainter({
    required this.start,
    required this.end,
    required this.reached,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(start.dx, start.dy + 34, end.dx, end.dy - 34, end.dx, end.dy);
    final paint = Paint()
      ..color = reached
          ? FluentianColors.secondary.withValues(alpha: 0.7)
          : const Color(0xFFD7DEE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final metrics = route.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segmentEnd = (distance + 8).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, segmentEnd), paint);
        distance += 15;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyRoutePainter oldDelegate) {
    return start != oldDelegate.start ||
        end != oldDelegate.end ||
        reached != oldDelegate.reached;
  }
}

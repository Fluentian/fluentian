import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
import '../providers/content_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import 'lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String? initialUnitId;

  /// When true, renders just the progress card + path (no Scaffold/AppBar)
  /// so it can be embedded directly on another screen (e.g. Home) instead
  /// of being pushed as its own route.
  final bool embedded;
  const LessonListScreen({
    super.key,
    this.initialUnitId,
    this.embedded = false,
  });

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
    // When embedded on Home, the parent screen already triggers
    // loadLessonProgress() on init -- calling it again here would just
    // duplicate that network round-trip.
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<ContentProvider>().loadLessonProgress();
        }
      });
    }
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
    final body = Consumer<ContentProvider>(
      builder: (context, content, _) {
        if (content.isLoading) {
          return const FluentianShimmer(
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(top: 16),
                child: SkeletonRoadmap(),
              ),
            ),
          );
        }
        if (content.courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.book_1, size: 48, color: FluentianColors.textSecondary),
                const SizedBox(height: 16),
                LText(
                  'No courses loaded yet.',
                  style: GoogleFonts.ibmPlexSans(
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
        final items = _buildPathItems(content.courses, content, startingUnitNo);
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

        Widget buildPathList(BoxConstraints constraints) {
          return ListView.builder(
            controller: widget.embedded ? null : _scrollController,
            physics: widget.embedded
                ? const NeverScrollableScrollPhysics()
                : null,
            shrinkWrap: widget.embedded,
            padding: EdgeInsets.only(bottom: widget.embedded ? 16 : 40),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item is _CourseHeaderItem) {
                return _buildCourseHeader(item, content);
              } else if (item is _UnitHeaderItem) {
                return Container(
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
                );
              } else if (item is _LessonNodeItem) {
                return constraints.maxWidth < 330
                    ? _buildLessonNode(context, item, constraints)
                    : _buildJourneyNode(
                        context,
                        item,
                        constraints,
                      );
              }
              return const SizedBox.shrink();
            },
          );
        }

        if (widget.embedded) {
          return LayoutBuilder(
            builder: (context, constraints) => buildPathList(constraints),
          );
        }

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: FluentianColors.border),
                boxShadow: [FluentianShadows.subtle],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: FluentianColors.primaryTint,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Icon(
                      Iconsax.routing_2,
                      color: FluentianColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LText(
                              'French Fluency Path',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: FluentianColors.textPrimary,
                              ),
                            ),
                            LText(
                              '${(progressPercent * 100).toInt()}%',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: FluentianColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(0),
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
                          style: GoogleFonts.ibmPlexSans(
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
                builder: (context, constraints) => buildPathList(constraints),
              ),
            ),
          ],
        );
      },
    );
    if (widget.embedded) return body;
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: LText(
          'Learning Path',
          style: GoogleFonts.ibmPlexSans(
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
      body: body,
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
              style: GoogleFonts.ibmPlexSans(
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
                  style: GoogleFonts.ibmPlexSans(
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
                  style: GoogleFonts.ibmPlexSans(
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
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.primary,
                  letterSpacing: 0.55,
                ),
              ),
              const SizedBox(height: 3),
              LText(
                '$completedLessons/${lessons.length}',
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

  String _courseTitle(CourseModel course) {
    final normalized = course.code.trim().toLowerCase();
    if (normalized == 'fr-full' || normalized == 'fr_full' || normalized == 'frfull') {
      return 'French: Complete (${course.levelMin}–${course.levelMax})';
    }
    if (normalized == 'fr_a1_basics' || normalized == 'fr-a1-basics') {
      return 'French A1 Basics';
    }

    final cleaned = course.code.replaceAll('-', '_');
    return cleaned
        .split('_')
        .where((segment) => segment.isNotEmpty)
        .map((segment) {
          if (segment.toLowerCase() == 'fr') return 'French';
          return '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}';
        })
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
          color: FluentianColors.primary,
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
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: LText(
                '${unit.unitNo}',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
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
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LText(
                    unit.title,
                    style: GoogleFonts.ibmPlexSans(
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
                          borderRadius: BorderRadius.circular(0),
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
                        style: GoogleFonts.ibmPlexSans(
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
                    style: GoogleFonts.ibmPlexSans(
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
                  onPressed: () => showGuidebookDialog(context, unit),
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
        : FluentianColors.border;

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
                          : FluentianColors.divider,
                      width: 5,
                    ),
                    // Was a coloured glow -- 18px of blur behind the active
                    // node. A hard offset says "raised"; a glow says "this
                    // screen was made in a tool that had a glow slider".
                    boxShadow: item.isActive
                        ? const [
                            BoxShadow(
                              color: FluentianColors.primaryDark,
                              blurRadius: 0,
                              offset: Offset(3, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    item.isCompleted
                        ? Icons.check_rounded
                        : item.isUnlocked
                        ? visuals.icon
                        : Icons.lock_rounded,
                    color: item.isUnlocked
                        ? Colors.white
                        : FluentianColors.textSecondary,
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
                      : FluentianColors.divider,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: item.isActive
                        ? FluentianColors.primary
                        : FluentianColors.border,
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
                                ? FluentianColors.primary
                                : FluentianColors.textSecondary,
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
                            style: FluentianTheme.label(
                              size: 9.5,
                              color: item.isUnlocked
                                  ? FluentianColors.primary
                                  : FluentianColors.textSecondary,
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
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 13,
                        height: 1.18,
                        fontWeight: FontWeight.w700,
                        color: item.isUnlocked
                            ? FluentianColors.textPrimary
                            : FluentianColors.textSecondary,
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
                              : FluentianColors.border,
                        ),
                        LText(
                          '${item.lesson.xpReward} XP',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: FluentianColors.textSecondary,
                        ),
                        const SizedBox(width: 2),
                        LText(
                          '${item.lesson.estimatedMinutes}m',
                          style: GoogleFonts.ibmPlexSans(
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

  // Compact fallback keeps metadata readable on very narrow devices.
  Widget _buildLessonNode(
    BuildContext context,
    _LessonNodeItem item,
    BoxConstraints constraints,
  ) {
    final visuals = _lessonVisuals(item.lesson.lessonKind);
    final kindIcon = visuals.icon;
    final kindText = visuals.label;
    const kindColor = FluentianColors.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: item.isUnlocked
            ? FluentianColors.cardBg
            : FluentianColors.pageBg,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: item.isActive
              ? FluentianColors.primary
              : FluentianColors.border,
          width: item.isActive ? 1.5 : 1,
        ),
        boxShadow: const [FluentianShadows.subtle],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: item.isUnlocked ? kindColor : FluentianColors.border,
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
                              : FluentianColors.divider,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          kindIcon,
                          color: item.isUnlocked
                              ? kindColor
                              : FluentianColors.border,
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
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: item.isUnlocked
                                        ? kindColor
                                        : FluentianColors.textSecondary,
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
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    child: LText(
                                      'ACTIVE',
                                      style: GoogleFonts.ibmPlexSans(
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
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: item.isUnlocked
                                    ? FluentianColors.textPrimary
                                    : FluentianColors.textSecondary,
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
                                      : FluentianColors.border,
                                ),
                                const SizedBox(width: 2),
                                LText(
                                  '+${item.lesson.xpReward} XP',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: item.isUnlocked
                                        ? FluentianColors.textPrimary
                                        : FluentianColors.border,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color: item.isUnlocked
                                      ? Colors.blue
                                      : FluentianColors.border,
                                ),
                                const SizedBox(width: 2),
                                LText(
                                  '${item.lesson.estimatedMinutes}m',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: item.isUnlocked
                                        ? FluentianColors.textPrimary
                                        : FluentianColors.border,
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
          color: FluentianColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.lock_rounded, size: 14, color: FluentianColors.border),
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
                borderRadius: BorderRadius.circular(0),
              ),
              child: LText(
                'REVIEW',
                style: GoogleFonts.ibmPlexSans(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        elevation: 0,
      ),
      child: LText(
        'START',
        style: GoogleFonts.ibmPlexSans(
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) {
        final visuals = _lessonVisuals(lesson.lessonKind);
        final kindIcon = visuals.icon;
        final kindText = visuals.label;
        const kindColor = FluentianColors.primary;

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
                    color: FluentianColors.border,
                    borderRadius: BorderRadius.circular(0),
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
                      color: FluentianColors.primaryTint,
                    ),
                    child: Row(
                      children: [
                        Icon(kindIcon, color: kindColor, size: 14),
                        const SizedBox(width: 6),
                        LText(
                          kindText.toUpperCase(),
                          style: GoogleFonts.ibmPlexSans(
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
                            style: GoogleFonts.ibmPlexSans(
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
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              LText(
                'Practice key expressions and improve your fluency in this session.',
                style: GoogleFonts.ibmPlexSans(
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
                        color: FluentianColors.pageBg,
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(color: FluentianColors.border),
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
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          LText(
                            'Base Reward',
                            style: GoogleFonts.ibmPlexSans(
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
                        color: FluentianColors.pageBg,
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(color: FluentianColors.border),
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
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          LText(
                            'Est. Duration',
                            style: GoogleFonts.ibmPlexSans(
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
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: LText(
                  isCompleted ? 'PRACTICE AGAIN' : 'START LESSON',
                  style: GoogleFonts.ibmPlexSans(
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

/// Icon and name for a lesson kind.
///
/// This existed three times over in this file, and the three copies disagreed
/// -- a quiz was a trophy in one and a document in another, warning-brown in
/// one and #F59E0B in another. Each copy also gave every kind its own
/// tailwind hue: cyan for dialogue, pink for speaking, purple for listening,
/// blue for reading. Seven unrelated colours for seven categories is a legend
/// nobody learns, and it spent all the colour on *what* a lesson is, leaving
/// none for the thing a learner actually scans a path for: what is locked,
/// what is next, what is done. Kind is now carried by the icon and the name;
/// colour belongs to state.
class _LessonVisuals {
  final IconData icon;
  final String label;

  const _LessonVisuals(this.icon, this.label);
}

_LessonVisuals _lessonVisuals(String kind) {
  switch (kind) {
    case 'dialogue':
      return const _LessonVisuals(Iconsax.message5, 'Dialogue');
    case 'grammar':
    case 'grammar_explainer':
      return const _LessonVisuals(Iconsax.book_14, 'Grammar');
    case 'speaking':
    case 'pronunciation':
    case 'roleplay_simulation':
      return const _LessonVisuals(Iconsax.microphone_24, 'Speaking');
    case 'quiz':
    case 'review':
    case 'exam_drill':
      return const _LessonVisuals(Iconsax.cup, 'Challenge');
    case 'listening':
      return const _LessonVisuals(Iconsax.headphone, 'Listening');
    case 'reading':
    case 'writing':
      return const _LessonVisuals(Iconsax.document_text_14, 'Story');
    default:
      return const _LessonVisuals(Iconsax.category_24, 'Vocabulary');
  }
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
          : FluentianColors.border
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

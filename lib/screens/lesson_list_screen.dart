import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
import '../providers/content_provider.dart';
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

  @override
  void initState() {
    super.initState();
    // After build, if we have an initial unit, scroll to it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialUnitId != null) {
        _scrollToUnit(widget.initialUnitId!);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToUnit(String unitId) {
    _collapsedUnitIds.remove(unitId);
    final key = _unitKeys[unitId];
    if (key == null) return;
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
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
        title: Text(
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
                  Text(
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

          final course = content.courses.first;
          int totalLessons = 0;
          int completedLessons = 0;
          for (final unit in course.units) {
            totalLessons += unit.lessons.length;
            for (final lesson in unit.lessons) {
              if (content.isLessonCompleted(lesson.id)) {
                completedLessons++;
              }
            }
          }
          final progressPercent = totalLessons > 0
              ? (completedLessons / totalLessons)
              : 0.0;
          final items = _buildPathItems(content.courses, content);

          return Column(
            children: [
              // Course Progress Card
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
                          Text(
                            course.code == 'FR_A1_BASICS'
                                ? 'French A1 Basics'
                                : course.code.replaceAll('_', ' '),
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
                          Text(
                            '$completedLessons of $totalLessons lessons completed (${(progressPercent * 100).toInt()}%)',
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
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 40),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        if (item is _UnitHeaderItem) {
                          final key = _unitKeys.putIfAbsent(
                            item.unit.id,
                            () => GlobalKey(),
                          );
                          return Container(
                            key: key,
                            child: _buildUnitHeader(
                              context,
                              item.unit,
                              isExpanded: _isUnitExpanded(item.unit.id),
                            ),
                          );
                        } else if (item is _LessonNodeItem) {
                          return _buildLessonNode(context, item, constraints);
                        }
                        return const SizedBox.shrink();
                      },
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
  ) {
    final List<_PathItem> items = [];
    if (courses.isEmpty) return items;

    final course = courses.first;

    for (final unit in course.units) {
      items.add(_UnitHeaderItem(unit));

      if (!_isUnitExpanded(unit.id)) continue;

      final lessons = unit.lessons;
      for (int i = 0; i < lessons.length; i++) {
        final lesson = lessons[i];
        final isCompleted = content.isLessonCompleted(lesson.id);
        final isUnlocked = content.isLessonUnlocked(lessons, i);
        final isActive = !isCompleted && isUnlocked;

        items.add(
          _LessonNodeItem(
            lesson: lesson,
            lessonIndex: i,
            isCompleted: isCompleted,
            isUnlocked: isUnlocked,
            isActive: isActive,
            unitNo: unit.unitNo,
          ),
        );
      }
    }

    return items;
  }

  Widget _buildUnitHeader(
    BuildContext context,
    UnitModel unit, {
    required bool isExpanded,
  }) {
    return GestureDetector(
      onTap: () => _toggleUnit(unit.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [FluentianColors.primary, Color(0xFF4E22D4)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: FluentianColors.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: isExpanded ? 0.0 : -0.25,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UNIT ${unit.unitNo}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unit.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isExpanded
                        ? 'Master ${unit.lessons.length} steps to unlock the next unit'
                        : '${unit.lessons.length} lessons hidden',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                _showGuidebookDialog(context, unit);
              },
              icon: const Icon(
                Iconsax.book_1,
                size: 16,
                color: FluentianColors.primary,
              ),
              label: Text(
                'GUIDE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.primary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FluentianColors.primary,
                elevation: 0,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                                Text(
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
                                    child: Text(
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
                            Text(
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
                                Text(
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
                                Text(
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
              child: Text(
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
      child: Text(
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
                        Text(
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
                          Text(
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
              Text(
                lesson.title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
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
                          Text(
                            '+${lesson.xpReward} XP',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          Text(
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
                          Text(
                            '${lesson.estimatedMinutes} mins',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          Text(
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
                child: Text(
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
              Text(
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
              Text(
                'Key Vocabulary & Grammar:',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'In this unit, you will learn the fundamentals of conversation for this level. Practice daily to master pronoun conjugations, basic sentence structure, and core vocabulary lists.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: FluentianColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
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
                        child: Text(
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
                  child: Text(
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
              child: Text(
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
  final int unitNo;

  _LessonNodeItem({
    required this.lesson,
    required this.lessonIndex,
    required this.isCompleted,
    required this.isUnlocked,
    required this.isActive,
    required this.unitNo,
  });
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import '../models/course_model.dart';
import '../providers/content_provider.dart';
import 'lesson_detail_screen.dart';

class UnitDetailScreen extends StatelessWidget {
  final UnitModel unit;
  const UnitDetailScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: Column(
        children: [
          // Violet gradient header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: FluentianColors.headerGradient,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz_rounded, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Unit ${unit.unitNo} — ${unit.title}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Lessons: ${unit.lessons.length}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                Consumer<ContentProvider>(
                  builder: (context, content, _) {
                    final completedCount = unit.lessons
                        .where((l) => content.isLessonCompleted(l.id))
                        .length;
                    final totalCount = unit.lessons.length;
                    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
                    
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$completedCount of $totalCount lessons complete',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Lesson path
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Consumer<ContentProvider>(
                builder: (context, content, _) {
                  return Column(children: _buildLessonPath(context, content));
                },
              ),
            ),
          ),

          // Guidebook FAB area
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.book_1),
                label: Text(
                  'Guidebook',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  foregroundColor: FluentianColors.primary,
                  side: const BorderSide(
                    color: FluentianColors.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLessonPath(BuildContext context, ContentProvider content) {
    if (unit.lessons.isEmpty) {
      return [
        Center(
          child: Text(
            'No lessons available yet.',
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        )
      ];
    }

    final nodes = <_LessonNode>[];
    for (int i = 0; i < unit.lessons.length; i++) {
      final l = unit.lessons[i];
      final isCompleted = content.isLessonCompleted(l.id);
      final isUnlocked = content.isLessonUnlocked(unit.lessons, i);
      
      _NodeState state;
      if (isCompleted) {
        state = _NodeState.completed;
      } else if (isUnlocked) {
        state = _NodeState.active;
      } else {
        state = _NodeState.locked;
      }

      IconData icon;
      switch (l.lessonKind) {
        case 'dialogue': icon = Iconsax.message5; break;
        case 'grammar': icon = Iconsax.book_14; break;
        case 'speaking': icon = Iconsax.microphone_24; break;
        case 'quiz':
        case 'review': icon = Iconsax.document_text_14; break;
        default: icon = Iconsax.category_24;
      }

      nodes.add(_LessonNode(
        id: l.id,
        name: l.title,
        iconData: icon,
        type: l.lessonKind,
        xp: '${l.xpReward} XP',
        state: state,
        offset: i % 2 == 0 ? 0 : 1,
      ));
    }

    final widgets = <Widget>[];
    for (int i = 0; i < nodes.length; i++) {
      final l = nodes[i];
      final isLast = i == nodes.length - 1;
      final leftPad = l.offset == 0 ? 60.0 : 140.0;

      widgets.add(
        SizedBox(
          height:
              l.state == _NodeState.checkpoint ||
                  l.state == _NodeState.lockedCheckpoint
              ? 70
              : 100,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Dashed line
              if (!isLast)
                Positioned(
                  left: leftPad + 20,
                  top: l.state == _NodeState.active ? 64 : 56,
                  child: CustomPaint(
                    size: const Size(2, 44),
                    painter: _DashPainter(
                      l.state == _NodeState.locked ||
                          l.state == _NodeState.lockedCheckpoint,
                    ),
                  ),
                ),
              // Node
              Positioned(
                left: leftPad,
                child: GestureDetector(
                  onTap: l.state == _NodeState.active
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LessonDetailScreen(lessonId: l.id),
                          ),
                        )
                      : null,
                  child: _buildNode(l),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildNode(_LessonNode l) {
    if (l.state == _NodeState.checkpoint ||
        l.state == _NodeState.lockedCheckpoint) {
      final locked = l.state == _NodeState.lockedCheckpoint;
      return Column(
        children: [
          Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: locked ? Colors.grey.shade300 : FluentianColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.785,
                  child: Icon(
                    locked ? Icons.lock_rounded : Icons.diamond_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Checkpoint',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: locked ? Colors.grey : FluentianColors.primary,
            ),
          ),
        ],
      );
    }

    final size = l.state == _NodeState.active ? 64.0 : 56.0;
    Color bg, borderColor;
    Widget icon;

    switch (l.state) {
      case _NodeState.completed:
        bg = FluentianColors.primary;
        borderColor = FluentianColors.primary;
        icon = const Icon(Icons.check_rounded, color: Colors.white, size: 24);
        break;
      case _NodeState.active:
        bg = Colors.white;
        borderColor = FluentianColors.primary;
        icon = Icon(l.iconData, size: 24, color: FluentianColors.primary);
        break;
      default:
        bg = Colors.grey.shade200;
        borderColor = Colors.grey.shade300;
        icon = const Icon(Icons.lock_rounded, size: 20, color: Colors.grey);
    }

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: l.state == _NodeState.active ? 3 : 2,
            ),
            boxShadow: l.state == _NodeState.active
                ? [
                    BoxShadow(
                      color: FluentianColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 4),
        Text(
          l.name,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: l.state == _NodeState.locked
                ? Colors.grey
                : FluentianColors.textPrimary,
          ),
        ),
        if (l.state == _NodeState.active)
          Text(
            'Start →',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: FluentianColors.primary,
            ),
          ),
        if (l.xp.isNotEmpty && l.state != _NodeState.locked)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: XpChip(value: l.xp),
          ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  final bool isGrey;
  _DashPainter(this.isGrey);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isGrey
          ? Colors.grey.shade300
          : FluentianColors.primary.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, (y + 6).clamp(0, size.height)),
        paint,
      );
      y += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _NodeState { completed, active, locked, checkpoint, lockedCheckpoint }

class _LessonNode {
  final String id, name, type, xp;
  final IconData iconData;
  final _NodeState state;
  final int offset;
  const _LessonNode({
    this.id = '',
    required this.name,
    required this.iconData,
    required this.type,
    required this.xp,
    required this.state,
    required this.offset,
  });
}

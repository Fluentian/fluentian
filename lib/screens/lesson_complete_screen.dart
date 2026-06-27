import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/learning_api.dart';
import '../widgets/common_widgets.dart';

class LessonCompleteScreen extends StatefulWidget {
  final String lessonId;
  final int xpEarned;
  final int newXpTotal;
  final double accuracy;
  final int timeSeconds;
  final int correctCount;
  final int totalQuestions;

  const LessonCompleteScreen({
    super.key,
    required this.lessonId,
    required this.xpEarned,
    required this.newXpTotal,
    required this.accuracy,
    required this.timeSeconds,
    required this.correctCount,
    required this.totalQuestions,
  });

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  bool _feedbackSent = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final previousXp = (widget.newXpTotal - widget.xpEarned).clamp(0, 1 << 31);
    final accuracyPercent = (widget.accuracy * 100).round();

    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: FluentianColors.successTint,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: FluentianColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Lesson complete',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user == null ? 'Nice work.' : 'Nice work, ${user.displayName}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: FluentianColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: FluentianColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '+${widget.xpEarned} XP',
                      style: GoogleFonts.inter(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$previousXp -> ${widget.newXpTotal} total XP',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn('$accuracyPercent%', 'Accuracy'),
                  _StatColumn(_formatTime(widget.timeSeconds), 'Time'),
                  _StatColumn(
                    '${widget.correctCount}/${widget.totalQuestions}',
                    'Correct',
                  ),
                ],
              ),
              const Spacer(),
              if (!_feedbackSent)
                TextButton.icon(
                  onPressed: _showFeedbackSheet,
                  icon: const Icon(Icons.rate_review_rounded),
                  label: const Text('Leave lesson feedback'),
                )
              else
                Text(
                  'Feedback sent. Thank you.',
                  style: GoogleFonts.inter(
                    color: FluentianColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 12),
              FluentianButton(
                text: 'Continue',
                onPressed: () =>
                    Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFeedbackSheet() async {
    int rating = 5;
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                    'How was this lesson?',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) {
                      final value = index + 1;
                      return IconButton(
                        onPressed: () => setSheetState(() => rating = value),
                        icon: Icon(
                          value <= rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: FluentianColors.accent,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'What should we improve?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await LearningApi.instance.submitLessonFeedback(
                          lessonId: widget.lessonId,
                          rating: rating,
                          category: 'lesson',
                          comment: controller.text.trim().isEmpty
                              ? null
                              : controller.text.trim(),
                        );
                        if (!context.mounted) return;
                        setState(() => _feedbackSent = true);
                        Navigator.pop(context);
                      },
                      child: const Text('Send feedback'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    controller.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: FluentianColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: FluentianColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

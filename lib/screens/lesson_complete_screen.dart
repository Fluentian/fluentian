import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/learning_api.dart';
import '../services/sound_effect_service.dart';
import '../widgets/common_widgets.dart';
import 'streak_celebration_screen.dart';

class LessonCompleteScreen extends StatefulWidget {
  final String lessonId;
  final int xpEarned;
  final int newXpTotal;
  final double accuracy;
  final int timeSeconds;
  final int correctCount;
  final int totalQuestions;
  final int? streakDays;
  final bool streakFreezeEarned;

  const LessonCompleteScreen({
    super.key,
    required this.lessonId,
    required this.xpEarned,
    required this.newXpTotal,
    required this.accuracy,
    required this.timeSeconds,
    required this.correctCount,
    required this.totalQuestions,
    this.streakDays,
    this.streakFreezeEarned = false,
  });

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  bool _feedbackSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      if (context.read<AuthProvider>().user?.soundEnabled ?? true) {
        SoundEffectService.instance.play(SoundEffect.result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final xpEarned = widget.xpEarned < 0 ? 0 : widget.xpEarned;
    final newXpTotal = widget.newXpTotal < 0 ? 0 : widget.newXpTotal;
    final previousXp = (newXpTotal - xpEarned).clamp(0, 1 << 31).toInt();
    final accuracy = widget.accuracy.isFinite
        ? widget.accuracy.clamp(0.0, 1.0)
        : 0.0;
    final accuracyPercent = (accuracy * 100).round();
    final totalQuestions = widget.totalQuestions < 1
        ? 1
        : widget.totalQuestions;
    final correctCount = widget.correctCount.clamp(0, totalQuestions).toInt();

    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: FluentianColors.successTint,
                      ),
                      child: const Icon(
                        Iconsax.tick_circle,
                        size: 42,
                        color: FluentianColors.success,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LText(
                      'Lesson complete',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LText(
                      user == null
                          ? 'Nice work.'
                          : 'Nice work, ${user.displayName}.',
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
                          const Icon(
                            Iconsax.flash_15,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          LText(
                            '+$xpEarned XP',
                            style: GoogleFonts.inter(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LText(
                            '$previousXp -> $newXpTotal total XP',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final streak = widget.streakDays ?? user?.streakDays ?? 1;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.flash_15, color: Colors.white, size: 24),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LText(
                                    'STREAK INCREASED! 🔥',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  LText(
                                    '$streak Day Streak Active',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (widget.streakFreezeEarned) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: FluentianColors.infoTint,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: FluentianColors.info.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.shield_tick, color: FluentianColors.info, size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LText(
                                  'PERFECT TRIAL BONUS! 🛡️',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: FluentianColors.info,
                                  ),
                                ),
                                LText(
                                  '+1 Streak Freeze Earned (Max 3)',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: FluentianColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn('$accuracyPercent%', 'Accuracy'),
                        _StatColumn(_formatTime(widget.timeSeconds), 'Time'),
                        _StatColumn('$correctCount/$totalQuestions', 'Correct'),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (!_feedbackSent)
                      TextButton.icon(
                        onPressed: _showFeedbackSheet,
                        icon: const Icon(Iconsax.message_edit),
                        label: const LText('Leave lesson feedback'),
                      )
                    else
                      LText(
                        'Feedback sent. Thank you.',
                        style: GoogleFonts.inter(
                          color: FluentianColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 12),
                    FluentianButton(
                      text: 'Continue',
                      icon: Iconsax.arrow_right_3,
                      onPressed: () {
                        final streak = widget.streakDays ?? user?.streakDays ?? 1;
                        if (streak > 0) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => StreakCelebrationScreen(
                                streakDays: streak,
                                streakFreezeEarned: widget.streakFreezeEarned,
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
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
                  LText(
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
                          value <= rating ? Iconsax.star5 : Iconsax.star,
                          color: FluentianColors.accent,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'Tell us what felt unclear or difficult',
                      ),
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
                      child: const LText('Send feedback'),
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
        LText(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: FluentianColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        LText(
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

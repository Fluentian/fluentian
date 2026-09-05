import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/learning_api.dart';
import '../services/sound_effect_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/tibeb_band.dart';
import 'lesson_detail_screen.dart';
import 'streak_celebration_screen.dart';
import '../services/haptics.dart';

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
  final bool isPassed;
  final bool completionPendingSync;

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
    this.isPassed = true,
    this.completionPendingSync = false,
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
      Haptics.heavy(context);
      if (context.read<AuthProvider>().user?.soundEnabled ?? true) {
        SoundEffectService.instance.play(
          widget.isPassed ? SoundEffect.result : SoundEffect.wrong,
        );
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
    final isPassed = widget.isPassed;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Was an 80px tinted circle over centred type -- the
                    // congratulations screen every app ships. The band is
                    // this app's own completion mark, and the page reads
                    // down one left edge like the rest of the flow.
                    const TibebBand(height: 16),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Icon(
                          isPassed
                              ? Icons.check_circle_rounded
                              : Icons.refresh_rounded,
                          size: 24,
                          color: isPassed
                              ? FluentianColors.success
                              : FluentianColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LText(
                            isPassed ? 'Lesson complete' : 'Keep practicing',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LText(
                      isPassed
                          ? (user == null
                              ? 'Nice work.'
                              : 'Nice work, ${user.displayName}.')
                          : 'You scored $accuracyPercent%. Score at least 60% to pass and unlock the next lesson.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      // The one gradient that survived the flattening pass,
                      // plus a second hand-rolled one for the failed state.
                      // Flat ink now; the score is the thing to look at, so
                      // it is set big in the display face and nothing else
                      // competes with it.
                      decoration: const BoxDecoration(
                        color: FluentianColors.primary,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(isPassed ? 'XP EARNED' : 'YOUR SCORE'),
                            style: FluentianTheme.label(
                              color: FluentianColors.onInkAccent,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isPassed ? '+$xpEarned' : '$accuracyPercent%',
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 52,
                              height: 1.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                              color: FluentianColors.onInk,
                            ),
                          ),
                          const SizedBox(height: 10),
                          LText(
                            isPassed && widget.completionPendingSync
                                ? 'Saved offline — XP will update after sync'
                                : isPassed
                                ? '$previousXp -> $newXpTotal total XP'
                                : '60% required to earn XP & advance',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13,
                              height: 1.4,
                              color: FluentianColors.onInkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final streak = widget.streakDays ?? user?.streakDays ?? 1;
                        if (streak <= 0) return const SizedBox.shrink();
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          // White on #F59E0B measured 2.15:1. The system's
                          // warning brown carries white at 6.75:1, and it is
                          // one colour rather than an amber ramp.
                          decoration: const BoxDecoration(
                            color: FluentianColors.warning,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Iconsax.flash_15,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LText(
                                    isPassed
                                        ? 'STREAK INCREASED'
                                        : 'DAILY PRACTICE RECORDED',
                                    style: FluentianTheme.label(
                                      color: Colors.white,
                                    ),
                                  ),
                                  LText(
                                    '$streak Day Streak Active',
                                    style: GoogleFonts.ibmPlexSans(
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
                    if (isPassed && widget.streakFreezeEarned) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: FluentianColors.infoTint,
                          borderRadius: BorderRadius.circular(0),
                          border: Border.all(
                            color: FluentianColors.info.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.shield_tick,
                              color: FluentianColors.info,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LText(
                                  'PERFECT TRIAL BONUS',
                                  style: FluentianTheme.label(color: FluentianColors.info),
                                ),
                                LText(
                                  '+1 Streak Freeze Earned (Max 3)',
                                  style: GoogleFonts.ibmPlexSans(
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
                        style: GoogleFonts.ibmPlexSans(
                          color: FluentianColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (isPassed)
                      FluentianButton(
                        text: 'Continue',
                        icon: Iconsax.arrow_right_3,
                        onPressed: () {
                          final streak =
                              widget.streakDays ?? user?.streakDays ?? 1;
                          if (streak > 0) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => StreakCelebrationScreen(
                                  streakDays: streak,
                                  streakFreezeEarned:
                                      widget.streakFreezeEarned,
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      )
                    else ...[
                      FluentianButton(
                        text: 'Try Again',
                        icon: Iconsax.refresh,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => LessonDetailScreen(
                                lessonId: widget.lessonId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          context.tr('Back to Roadmap'),
                          style: GoogleFonts.ibmPlexSans(
                            color: FluentianColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
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
                    style: GoogleFonts.ibmPlexSans(
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
          style: GoogleFonts.ibmPlexSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: FluentianColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        LText(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 13,
            color: FluentianColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

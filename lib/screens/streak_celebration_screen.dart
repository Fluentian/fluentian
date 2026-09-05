import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import '../providers/content_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/tibeb_band.dart';
import '../services/haptics.dart';

class StreakCelebrationScreen extends StatefulWidget {
  final int streakDays;
  final bool streakFreezeEarned;

  const StreakCelebrationScreen({
    super.key,
    required this.streakDays,
    this.streakFreezeEarned = false,
  });

  @override
  State<StreakCelebrationScreen> createState() =>
      _StreakCelebrationScreenState();
}

class _StreakCelebrationScreenState extends State<StreakCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _count;
  late Animation<double> _fade;
  late Animation<double> _weave;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // The number counting up is the whole celebration: it is the one thing
    // on screen the learner earned, and watching it land is more satisfying
    // than any amount of decoration around it.
    _count = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.62, curve: Curves.easeOutCubic),
    );
    _weave = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.1, 0.85, curve: Curves.easeInOutCubic),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Haptics.heavy(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honor reduced-motion: land on the final frame without the count-up.
    if (MediaQuery.of(context).disableAnimations) {
      _ctrl.value = 1.0;
    } else if (_ctrl.status == AnimationStatus.dismissed) {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysActive = context.watch<ContentProvider>().weeklyActiveDays;
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = DateTime.now().weekday - 1;
    final days = widget.streakDays;

    return Scaffold(
      backgroundColor: FluentianColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Was three looping pulse rings behind a 128px amber-to-red
              // gradient circle, a spread glow, an elastic bounce and a
              // floating "+1 STREAK!" badge -- five effects competing to say
              // one thing. The number says it.
              Text(
                context.tr('DAY STREAK').toUpperCase(),
                style: FluentianTheme.label(
                  color: FluentianColors.onInkAccent,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _count,
                builder: (context, _) {
                  final shown = (days * _count.value).round().clamp(
                    days > 0 ? 1 : 0,
                    days,
                  );
                  return Text(
                    '$shown',
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 116,
                      height: 0.86,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -5,
                      color: FluentianColors.onInk,
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              AnimatedBuilder(
                animation: _weave,
                builder: (context, _) =>
                    TibebBand(height: 16, progress: _weave.value),
              ),
              const SizedBox(height: 22),

              FadeTransition(
                opacity: _fade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      days <= 1
                          ? 'You started a streak today. Come back tomorrow to make it two.'
                          : 'You kept it alive today. Practice tomorrow to make it ${days + 1}.',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 15,
                        height: 1.45,
                        color: FluentianColors.onInkMuted,
                      ),
                    ),
                    const SizedBox(height: 26),

                    // The week, as squares on a rule. Circles-in-a-row is the
                    // habit-tracker default; this reads as a printed week.
                    Text(
                      context.tr('THIS WEEK'),
                      style: FluentianTheme.label(
                        color: FluentianColors.onInkMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(7, (i) {
                        final isActive = daysActive[i] || i == todayIndex;
                        final isToday = i == todayIndex;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i == 6 ? 0 : 6),
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    // White on the warning brown is 6.75:1.
                                    color: isActive
                                        ? FluentianColors.warning
                                        : FluentianColors.darkCard,
                                    border: Border.all(
                                      color: isToday
                                          ? FluentianColors.onInk
                                          : FluentianColors.darkBorder,
                                      width: isToday ? 2 : 1,
                                    ),
                                  ),
                                  child: isActive
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dayLabels[i],
                                  style: FluentianTheme.label(
                                    color: isToday
                                        ? FluentianColors.onInk
                                        : FluentianColors.onInkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    if (widget.streakFreezeEarned) ...[
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: FluentianColors.darkCard,
                          border: Border(
                            left: BorderSide(
                              color: FluentianColors.onInkAccent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Was FluentianColors.accent on this navy: 2.17:1.
                            const Icon(
                              Iconsax.shield_tick,
                              color: FluentianColors.onInkAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LText(
                                '1 streak freeze active, protecting missed days',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: FluentianColors.onInk,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(flex: 2),

              FluentianButton(
                text: 'Continue',
                icon: Iconsax.arrow_right_3,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

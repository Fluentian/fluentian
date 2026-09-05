import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import '../providers/content_provider.dart';
import '../widgets/common_widgets.dart';
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
  late AnimationController _flameCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _flameScale;
  late Animation<double> _textOpacity;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();

    _flameCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _flameScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _flameCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flameCtrl,
        curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
      ),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flameCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Haptics.heavy(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Honor reduced-motion: show the final celebratory frame without the
    // elastic entrance or the looping pulse rings.
    if (MediaQuery.of(context).disableAnimations) {
      _flameCtrl.value = 1.0;
      _pulseCtrl.stop();
    } else {
      if (_flameCtrl.status == AnimationStatus.dismissed) {
        _flameCtrl.forward();
      }
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _flameCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysActive = context.watch<ContentProvider>().weeklyActiveDays;
    final dayLabels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = DateTime.now().weekday - 1;

    return Scaffold(
      backgroundColor: FluentianColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              // 1. Central Animated Flame & Pulse Rings
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Concentric Expanding Pulse Rings
                    ...List.generate(3, (index) {
                      return AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (context, child) {
                          final delay = index * 0.33;
                          final progress = (_pulseCtrl.value + delay) % 1.0;
                          final size = 110.0 + (progress * 140.0);
                          final opacity = (1.0 - progress) * 0.35;

                          return Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: FluentianColors.warning.withValues(
                                alpha: opacity.clamp(0.0, 1.0),
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    // Main Flame Icon Card
                    AnimatedBuilder(
                      animation: _flameCtrl,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _flameScale.value,
                          child: Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF59E0B), Color(0xFFDC2626)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: FluentianColors.warning
                                      .withValues(alpha: 0.5),
                                  blurRadius: 0,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Iconsax.flash_15,
                                size: 72,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Floating "+1" Badge Overlay
                    Positioned(
                      top: 20,
                      right: 35,
                      child: AnimatedBuilder(
                        animation: _flameCtrl,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _badgeScale.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: FluentianColors.success,
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [
                                  BoxShadow(
                                    color: FluentianColors.success.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: LText(
                                '+1 STREAK!',
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Animated Counter & Text Title
              AnimatedBuilder(
                animation: _flameCtrl,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        LText(
                          '${widget.streakDays} DAY STREAK',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        LText(
                          'You completed a lesson today and kept your streak alive. Practice tomorrow to make it ${widget.streakDays + 1} days!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // 3. Weekly Heatmap Days Row (M T W T F S S)
              AnimatedBuilder(
                animation: _flameCtrl,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final isActive = daysActive[index] || index == todayIndex;
                          final isToday = index == todayIndex;

                          return Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? FluentianColors.warning
                                      : Colors.white.withValues(alpha: 0.1),
                                  border: isToday
                                      ? Border.all(color: Colors.white, width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: isActive
                                      ? const Icon(
                                          Iconsax.flash_15,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : LText(
                                          dayLabels[index],
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              LText(
                                dayLabels[index],
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 11,
                                  fontWeight: isToday
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isToday
                                      ? FluentianColors.warning
                                      : Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),

              if (widget.streakFreezeEarned) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: FluentianColors.infoTint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: FluentianColors.accent.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.shield_tick,
                        color: FluentianColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      LText(
                        '1 streak freeze active, protecting missed days',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // 4. Continue Button
              FluentianButton(
                text: 'CONTINUE TO ROADMAP',
                icon: Iconsax.arrow_right_3,
                onPressed: () => Navigator.of(context).pop(),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

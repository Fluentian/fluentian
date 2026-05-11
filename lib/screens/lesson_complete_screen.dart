import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';

class LessonCompleteScreen extends StatefulWidget {
  const LessonCompleteScreen({super.key});
  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _xpCtrl;
  late AnimationController _checkCtrl;
  late Animation<int> _xpCounter;
  late Animation<double> _checkScale;
  bool _showMilestone = false;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3))
      ..play();

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _checkScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
    _checkCtrl.forward();

    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _xpCounter = IntTween(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _xpCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showMilestone = true);
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _xpCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: Stack(
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              colors: const [
                FluentianColors.primary,
                FluentianColors.accent,
                FluentianColors.primaryLight,
                FluentianColors.success,
                Colors.white,
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Milestone banner
                AnimatedOpacity(
                  opacity: _showMilestone ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedSlide(
                    offset: Offset(0, _showMilestone ? 0 : -1),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: FluentianColors.accentTint,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FluentianColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.cup,
                            color: FluentianColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'New badge earned! — First Dialogue',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FluentianColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Checkmark animation
                AnimatedBuilder(
                  animation: _checkCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: _checkScale.value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FluentianColors.successTint,
                        boxShadow: [
                          BoxShadow(
                            color: FluentianColors.success.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 40,
                        color: FluentianColors.success,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Lesson complete! 🎉',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You're on fire, Sara!",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: FluentianColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // XP reward card
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: FluentianColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: FluentianColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _xpCtrl,
                        builder: (_, __) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            Text(
                              '+${_xpCounter.value} XP',
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 360 / 500,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: AlwaysStoppedAnimation(
                              Colors.white.withValues(alpha: 0.8),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '340 → 360 XP',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatColumn('92%', 'Accuracy'),
                    _StatColumn('4:32', 'Time'),
                    _StatColumn('11/12', 'Correct'),
                  ],
                ),

                const Spacer(),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FluentianButton(
                    text: 'Continue →',
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Review 1 mistake',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: FluentianColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value, label;
  const _StatColumn(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
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

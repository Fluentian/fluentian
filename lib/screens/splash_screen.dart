import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _badgeScale;
  late Animation<double> _badgeOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _orbitOpacity;

  int _tipIndex = 0;
  final List<String> _proTips = const [
    'French is spoken across 5 continents 🌐',
    'Just 10 minutes a day builds fluency fast 🔥',
    'Tu is informal; Vous shows professional respect 🤝',
    'Practice daily to keep your streak glowing ✨',
  ];

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _badgeScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _badgeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _orbitOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _entranceCtrl.forward();

    // Rotate tips every 3 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return false;
      setState(() {
        _tipIndex = (_tipIndex + 1) % _proTips.length;
      });
      return true;
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isTablet = media.size.shortestSide >= 600;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;
          final centerSize = math.min(maxW * 0.85, isTablet ? 420.0 : 340.0);
          final badgeSize = isTablet ? 104.0 : 84.0;

          return Container(
            width: maxW,
            height: maxH,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF030F1E),
                  Color(0xFF072D52),
                  Color(0xFF0B4674),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Ambient Background Glow Orbs
                Positioned(
                  top: -maxH * 0.1,
                  left: -maxW * 0.2,
                  child: Container(
                    width: maxW * 0.7,
                    height: maxW * 0.7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF259291,
                          ).withValues(alpha: 0.18),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -maxH * 0.1,
                  right: -maxW * 0.2,
                  child: Container(
                    width: maxW * 0.75,
                    height: maxW * 0.75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF33C8C0,
                          ).withValues(alpha: 0.12),
                          blurRadius: 120,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Centerpiece: Pulsing Waves + Orbiting Words + Glass Badge
                SizedBox(
                  width: centerSize,
                  height: centerSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Concentric Pulse Rings
                      ...List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (context, child) {
                            final delay = index * 0.33;
                            final progress = (_pulseCtrl.value + delay) % 1.0;
                            final size =
                                badgeSize +
                                (progress * (centerSize - badgeSize));
                            final opacity = (1.0 - progress) * 0.35;

                            return Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFF4CB8B3,
                                  ).withValues(alpha: opacity.clamp(0.0, 1.0)),
                                  width: 1.5,
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      // Orbiting Floating Vocabulary Particles ("Bonjour", "Merci", "Bienvenue")
                      AnimatedBuilder(
                        animation: _orbitCtrl,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _orbitOpacity.value,
                            child: CustomPaint(
                              size: Size(centerSize, centerSize),
                              painter: _OrbitingWordsPainter(
                                angle: _orbitCtrl.value * math.pi * 2,
                                badgeRadius: centerSize * 0.38,
                              ),
                            ),
                          );
                        },
                      ),

                      // 3D glass badge with the real Fluentian app mark.
                      AnimatedBuilder(
                        animation: _entranceCtrl,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _badgeOpacity.value,
                            child: Transform.scale(
                              scale: _badgeScale.value,
                              child: Container(
                                width: badgeSize,
                                height: badgeSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    badgeSize * 0.32,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 32,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 14),
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFF33C8C0,
                                      ).withValues(alpha: 0.35),
                                      blurRadius: 28,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(badgeSize * 0.09),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      badgeSize * 0.24,
                                    ),
                                    child: Image.asset(
                                      'assets/icon.jpg',
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 3. Staggered Responsive Title & Tagline
                Positioned(
                  top: (maxH / 2) + (centerSize / 2) - 20,
                  child: AnimatedBuilder(
                    animation: _entranceCtrl,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LText(
                              'Fluentian',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: isTablet ? 38 : 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            LText(
                              'French made for you',
                              style: GoogleFonts.inter(
                                fontSize: isTablet ? 17 : 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 4. Responsive Bottom Progress Bar & Pro-Tip Carousel
                Positioned(
                  bottom: math.max(28.0, maxH * 0.05),
                  left: 24,
                  right: 24,
                  child: AnimatedBuilder(
                    animation: _entranceCtrl,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 480.0 : 360.0,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Smooth Progress Shimmer Track
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  height: 4,
                                  width: double.infinity,
                                  color: Colors.white.withValues(alpha: 0.12),
                                  child: AnimatedBuilder(
                                    animation: _shimmerCtrl,
                                    builder: (context, child) {
                                      return FractionalTranslation(
                                        translation: Offset(
                                          (_shimmerCtrl.value * 2.0) - 1.0,
                                          0,
                                        ),
                                        child: Container(
                                          width: 120,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                FluentianColors.accent,
                                                Colors.white,
                                                FluentianColors.accent,
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Rotating Tip Animation
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                      opacity: anim,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.2),
                                          end: Offset.zero,
                                        ).animate(anim),
                                        child: child,
                                      ),
                                    ),
                                child: LText(
                                  _proTips[_tipIndex],
                                  key: ValueKey<int>(_tipIndex),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom Painter to draw floating orbit vocabulary chips around the logo badge.
class _OrbitingWordsPainter extends CustomPainter {
  final double angle;
  final double badgeRadius;

  _OrbitingWordsPainter({required this.angle, required this.badgeRadius});

  final List<String> words = const [
    'Bonjour ☀️',
    'Bienvenue 🇫🇷',
    'Merci 🙏',
    'Salut 👋',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final count = words.length;

    for (int i = 0; i < count; i++) {
      final currentAngle = angle + (i * (2 * math.pi / count));
      final x = center.dx + (badgeRadius * math.cos(currentAngle));
      final y = center.dy + (badgeRadius * math.sin(currentAngle));

      final tp = TextPainter(
        text: TextSpan(
          text: words[i],
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      final chipRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, y),
          width: tp.width + 16,
          height: tp.height + 10,
        ),
        const Radius.circular(12),
      );

      final bgPaint = Paint()
        ..color = FluentianColors.primaryDark.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = FluentianColors.accent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(chipRect, bgPaint);
      canvas.drawRRect(chipRect, borderPaint);
      tp.paint(canvas, Offset(x - (tp.width / 2), y - (tp.height / 2)));
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitingWordsPainter oldDelegate) =>
      oldDelegate.angle != angle;
}

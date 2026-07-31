import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: FluentianColors.splashGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse rings
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final delay = index * 0.33;
                  final progress = (_pulseController.value + delay) % 1.0;
                  return Opacity(
                    opacity: (1.0 - progress) * 0.2,
                    child: Container(
                      width: 72 + (progress * 180),
                      height: 72 + (progress * 180),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: FluentianColors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Logo + text
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: FluentianColors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: CustomPaint(painter: _FLogoPainter()),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // App name
                    Opacity(
                      opacity: _textOpacity.value,
                      child: Text(
                        'Fluentian',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: FluentianColors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Opacity(
                      opacity: _textOpacity.value,
                      child: Text(
                        'French made for you',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: FluentianColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the "F" logo with wave cutout
class _FLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'F',
        style: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0A3B6A),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2 - 2,
      ),
    );

    // Draw wave/arc across the middle
    final wavePaint = Paint()
      ..color = const Color(0xFF0A3B6A).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final wavePath = Path();
    wavePath.moveTo(8, size.height * 0.55);
    wavePath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.55,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.7,
      size.width - 8,
      size.height * 0.55,
    );
    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

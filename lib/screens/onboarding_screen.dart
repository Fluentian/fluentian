import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import 'level_setup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _go();
    }
  }

  void _go() => Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const LevelSetupScreen()),
  );

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: _go,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: FluentianColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pc,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _Slide(
                    heading: 'Learn French your way',
                    sub:
                        'Structured lessons, AI conversation practice, and real cultural context — all in Amharic or English.',
                    child: _CafeIllustration(),
                  ),
                  _Slide(
                    heading: 'Your AI tutor, always on',
                    sub:
                        'Practice speaking French 24/7. Get instant feedback on grammar, pronunciation, and fluency.',
                    child: _AiOrbIllustration(),
                  ),
                  _Slide(
                    heading: 'Built for Ethiopian learners',
                    sub:
                        'Explanations in Amharic, Afaan Oromo, or English. Cultural bridges between Ethiopian and French life.',
                    child: _MapIllustration(),
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _pc,
              count: 3,
              effect: ExpandingDotsEffect(
                activeDotColor: FluentianColors.primary,
                dotColor: FluentianColors.primary.withValues(alpha: 0.2),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FluentianButton(
                text: _page == 2 ? 'Get started' : 'Continue',
                onPressed: _next,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String heading, sub;
  final Widget child;
  const _Slide({required this.heading, required this.sub, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(height: 260, child: child),
          const SizedBox(height: 40),
          Text(
            heading,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 280,
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: FluentianColors.textSecondary,
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _CafeIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: 30,
            child: Icon(
              Icons.location_city_rounded,
              size: 80,
              color: FluentianColors.primary.withValues(alpha: 0.15),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC68642),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FluentianColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 24,
                  height: 36,
                  decoration: BoxDecoration(
                    color: FluentianColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'F',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 50,
            child: const Icon(Iconsax.coffee, color: Colors.brown, size: 28),
          ),
          Positioned(
            top: 60,
            left: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: FluentianColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [FluentianShadows.subtle],
              ),
              child: Text(
                'Bonjour!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiOrbIllustration extends StatefulWidget {
  @override
  State<_AiOrbIllustration> createState() => _AiOrbState();
}

class _AiOrbState extends State<_AiOrbIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Transform.rotate(
              angle: _c.value * 6.283,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FluentianColors.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Transform.rotate(
              angle: -_c.value * 6.283 + 0.5,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: FluentianColors.primaryLight.withValues(alpha: 0.15),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [FluentianColors.primaryLight, FluentianColors.primary],
              ),
              boxShadow: [
                BoxShadow(
                  color: FluentianColors.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.waves_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [FluentianShadows.subtle],
              ),
              child: Text(
                'Bonjour!',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: FluentianColors.primaryTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ሰላም!',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomPaint(
        painter: _MapPainter(),
        child: Stack(
          children: [
            Positioned(
              bottom: 80,
              left: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009639).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🇪🇹', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ethiopia',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002395).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🇫🇷', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'France',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 95,
              right: 30,
              child: Text(
                'Paris · Lyon · Marseille',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: FluentianColors.primary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF6C3BF5).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width * 0.7,
        size.height * 0.3,
      );
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(
          m.extractPath(d, (d + 8).clamp(0, m.length).toDouble()),
          p,
        );
        d += 14;
      }
    }
    final dot = Paint()..color = const Color(0xFFF97316);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.27), 3, dot);
    canvas.drawCircle(Offset(size.width * 0.73, size.height * 0.32), 3, dot);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.35), 3, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

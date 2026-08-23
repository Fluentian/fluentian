import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

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

  void _go() =>
      Provider.of<AuthProvider>(context, listen: false).setIntroSeen(true);

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
                  child: LText(
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
                        'Structured lessons and real cultural context — all in Amharic or English.',
                    child: const _OnboardingIllustration(
                      asset: 'assets/onboarding/learn-french.png',
                    ),
                  ),
                  _Slide(
                    heading: 'Your personalized tutor, always on',
                    sub:
                        'Practice speaking French 24/7. Get instant feedback on pronunciation and fluency.',
                    child: const _OnboardingIllustration(
                      asset: 'assets/onboarding/ai-speaking-tutor.png',
                    ),
                  ),
                  _Slide(
                    heading: 'Built for Ethiopian learners',
                    sub:
                        'Explanations in Amharic, Afaan Oromo, or English. Cultural bridges between Ethiopian and French life.',
                    child: const _OnboardingIllustration(
                      asset: 'assets/onboarding/ethiopia-france-bridge.png',
                    ),
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
          LText(
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
            child: LText(
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

class _OnboardingIllustration extends StatelessWidget {
  final String asset;

  const _OnboardingIllustration({required this.asset});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        asset,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

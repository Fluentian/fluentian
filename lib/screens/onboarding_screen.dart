import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/tibeb_band.dart';

/// Three-panel intro.
///
/// Was a centre-stacked image / heading / subtitle with dot pagination — the
/// exact arrangement every onboarding flow ships. Two changes carry the
/// redesign:
///
///  1. Everything is left-aligned to a single edge, so the eye tracks one
///     line down the page instead of bouncing off a centre axis.
///  2. The artwork is framed as a *plate*: hairline border, numbered, with a
///     mono caption under it. These illustrations are stock-feeling, and the
///     honest move is to present them as figures in a book rather than pass
///     them off as the brand. When real commissioned art lands, the frame
///     still works.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _panels = <_Panel>[
    _Panel(
      plate: 'assets/onboarding/learn-french.png',
      caption: 'Plate I · Le parcours',
      heading: 'Learn French\nyour way',
      body:
          'Structured lessons and real cultural context — all in Amharic or English.',
    ),
    _Panel(
      plate: 'assets/onboarding/ai-speaking-tutor.png',
      caption: 'Plate II · La tutrice',
      heading: 'A tutor that\nnever sleeps',
      body:
          'Practice speaking French at any hour. Instant feedback on pronunciation and fluency.',
    ),
    _Panel(
      plate: 'assets/onboarding/ethiopia-france-bridge.png',
      caption: 'Plate III · Le pont',
      heading: 'Built for\nEthiopian learners',
      body:
          'Explanations in Amharic, Afaan Oromo or English, and cultural bridges between Ethiopian and French life.',
    ),
  ];

  void _next() {
    if (_page < _panels.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
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
    final last = _page == _panels.length - 1;

    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_page + 1} / ${_panels.length}',
                    style: FluentianTheme.label(),
                  ),
                  TextButton(
                    onPressed: _go,
                    child: const LText('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _panels.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _PanelView(panel: _panels[i]),
              ),
            ),
            // The band carries pagination, so there is one progress language
            // in the app rather than dots here and bars elsewhere.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: (_page + 1) / _panels.length),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => TibebBand(height: 16, progress: v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: ElevatedButton(
                onPressed: _next,
                child: LText(last ? 'Get started' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel {
  const _Panel({
    required this.plate,
    required this.caption,
    required this.heading,
    required this.body,
  });
  final String plate, caption, heading, body;
}

class _PanelView extends StatelessWidget {
  const _PanelView({required this.panel});
  final _Panel panel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The plate: bordered, square-cornered, sitting on paper.
          Container(
            decoration: const BoxDecoration(
              color: FluentianColors.cardBg,
              border: Border.fromBorderSide(FluentianBorders.hairline),
            ),
            padding: const EdgeInsets.all(10),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Image.asset(
                panel.plate,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(panel.caption, style: FluentianTheme.label()),
          const SizedBox(height: 26),
          LText(
            panel.heading,
            style: text.displayMedium?.copyWith(height: 1.0),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: LText(panel.body, style: text.bodyLarge),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

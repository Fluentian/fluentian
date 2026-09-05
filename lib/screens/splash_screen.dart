import 'package:flutter/material.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../widgets/tibeb_band.dart';

/// First frame of the app.
///
/// The previous version stacked a three-stop gradient, two ambient glow orbs,
/// three pulsing rings, four orbiting emoji chips, a glass badge and a shimmer
/// bar across four animation controllers. Every one of those is a generic
/// effect that any generated interface reaches for, and together they said
/// nothing about this product.
///
/// This says one thing instead: a wordmark on ink, and the tibeb band drawing
/// itself across. One idea, one motion, held for as long as the app takes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _weave;
  late final Animation<double> _type;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _type = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _weave = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 1.0, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: FluentianColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) =>
                    Opacity(opacity: _type.value, child: child),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Fluentian',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: wide ? 76 : 58,
                        color: Colors.white,
                        height: 0.92,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Both scripts, because both are the point. Noto Sans
                    // Ethiopic is registered as a fallback on every text style,
                    // so the Amharic renders rather than boxing.
                    Text(
                      'ከአዲስ እስከ ፓሪስ',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: wide ? 20 : 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LText(
                      'French, from Addis to Paris',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF9AA3B4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // The band is the loading indicator. No second progress language.
              AnimatedBuilder(
                animation: _weave,
                builder: (context, _) => TibebBand(
                  height: wide ? 22 : 18,
                  progress: _weave.value,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';

/// Truthful placeholder while purchasing and entitlement restoration are
/// being implemented. Paid claims stay hidden until checkout is functional.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.darkNav,
      appBar: AppBar(
        backgroundColor: FluentianColors.darkNav,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 64,
                  color: FluentianColors.primaryLight,
                ),
                const SizedBox(height: 24),
                LText(
                  'Fluentian Pro is coming soon',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                LText(
                  'Purchases are not available yet. You can keep learning with the free plan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const LText('Continue with free plan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

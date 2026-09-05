import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/theme.dart';
import 'call_screen.dart';
import '../services/haptics.dart';

/// Shown before entering the random-partner match queue. Lets the learner
/// choose audio-only or video before searching begins -- previously this
/// was hardcoded to audio-only with no way to request video at all.
class FindSpeakingPartnerScreen extends StatefulWidget {
  final String topic;

  const FindSpeakingPartnerScreen({super.key, required this.topic});

  @override
  State<FindSpeakingPartnerScreen> createState() =>
      _FindSpeakingPartnerScreenState();
}

class _FindSpeakingPartnerScreenState extends State<FindSpeakingPartnerScreen> {
  bool _cameraOn = false;

  void _startSearch() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CallScreen(
          topic: widget.topic,
          isVideo: _cameraOn,
          smartMatch: true,
          liveRoomId: 'match',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  tooltip: context.tr('Close'),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FluentianColors.secondary.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Iconsax.people,
                  color: FluentianColors.accent,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              LText(
                'Practice with someone new',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              LText(
                'Meet another learner and practice French naturally.',
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSans(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 40),
              LText(
                'HOW DO YOU WANT TO CONNECT?',
                style: GoogleFonts.ibmPlexSans(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      icon: Iconsax.microphone_2,
                      label: 'Audio',
                      subtitle: 'Voice only',
                      selected: !_cameraOn,
                      onTap: () => setState(() {
                        Haptics.selection(context);
                        _cameraOn = false;
                      }),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ModeCard(
                      icon: Iconsax.video,
                      label: 'Video',
                      subtitle: 'Face to face',
                      selected: _cameraOn,
                      onTap: () => setState(() {
                        Haptics.selection(context);
                        _cameraOn = true;
                      }),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _startSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FluentianColors.accent,
                    foregroundColor: FluentianColors.darkNav,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: LText(
                    'Find someone',
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A deliberate, two-card choice between audio-only and video -- each
/// option gets its own icon, label, and short description, with the
/// selected card lifted (scaled up, accent border + glow, checkmark badge).
/// Reads as "pick one" rather than a settings-style on/off switch.
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        scale: selected ? 1.0 : 0.96,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? FluentianColors.accent.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: selected
                  ? FluentianColors.accent
                  : Colors.white.withValues(alpha: 0.1),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    FluentianShadows.subtle,
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? FluentianColors.accent
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? FluentianColors.darkNav
                          : Colors.white60,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LText(
                    label,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  LText(
                    subtitle,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
              if (selected)
                Positioned(
                  top: -8,
                  right: -4,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: FluentianColors.accent,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: FluentianColors.darkNav,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

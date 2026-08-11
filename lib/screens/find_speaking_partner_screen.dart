import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/theme.dart';
import 'call_screen.dart';

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

class _FindSpeakingPartnerScreenState
    extends State<FindSpeakingPartnerScreen> {
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
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              LText(
                'Meet another learner and practice French naturally.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 36),
              _CameraToggle(
                cameraOn: _cameraOn,
                onChanged: (value) => setState(() => _cameraOn = value),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: LText(
                    'Find someone',
                    style: GoogleFonts.inter(
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

/// A sliding left/right toggle: left = camera off (audio only), right =
/// camera on (video). Reads more like a single physical switch than two
/// separate "Audio" / "Video" buttons.
class _CameraToggle extends StatelessWidget {
  final bool cameraOn;
  final ValueChanged<bool> onChanged;

  const _CameraToggle({required this.cameraOn, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: cameraOn
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 116,
              height: 48,
              decoration: BoxDecoration(
                color: FluentianColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ToggleOption(
                  icon: Iconsax.microphone_2,
                  label: 'Audio',
                  selected: !cameraOn,
                  onTap: () => onChanged(false),
                ),
              ),
              Expanded(
                child: _ToggleOption(
                  icon: Iconsax.video,
                  label: 'Video',
                  selected: cameraOn,
                  onTap: () => onChanged(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? FluentianColors.darkNav : Colors.white70,
          ),
          const SizedBox(width: 6),
          LText(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? FluentianColors.darkNav : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

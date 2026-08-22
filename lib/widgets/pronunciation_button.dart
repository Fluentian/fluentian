import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../services/tts_service.dart';

/// Compact "Listen" / "Slow" pill pair for hearing how a French word or
/// phrase is pronounced, at normal and slow (0.65x) speed.
class PronunciationButton extends StatefulWidget {
  final String text;
  final String language;

  const PronunciationButton({super.key, required this.text, this.language = 'fr-FR'});

  @override
  State<PronunciationButton> createState() => _PronunciationButtonState();
}

class _PronunciationButtonState extends State<PronunciationButton> {
  final TtsService _ttsService = TtsService.instance;
  bool _loading = false;
  double? _activeSpeed;

  Future<void> _speak(double speed) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _activeSpeed = speed;
    });
    try {
      await _ttsService.speak(widget.text, language: widget.language, speed: speed);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: LText('Failed to load audio.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _activeSpeed = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: 'Listen to "${widget.text}"',
          excludeSemantics: true,
          child: GestureDetector(
          onTap: () => _speak(1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: FluentianColors.primaryTint,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: FluentianColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _loading && _activeSpeed == 1.0
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: FluentianColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Iconsax.volume_high, color: FluentianColors.primary, size: 16),
                const SizedBox(width: 6),
                LText(
                  'Listen',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: FluentianColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: 'Listen slowly to "${widget.text}"',
          excludeSemantics: true,
          child: GestureDetector(
          onTap: () => _speak(0.65),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _loading && _activeSpeed == 0.65
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: FluentianColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.speed_rounded, color: FluentianColors.primary, size: 16),
                const SizedBox(width: 6),
                LText(
                  'Slow',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: FluentianColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ],
    );
  }
}

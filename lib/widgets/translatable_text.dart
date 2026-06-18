import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';

class SentencePair {
  final String original;
  final String translated;

  const SentencePair({required this.original, required this.translated});
}

class TranslatableParagraph extends StatefulWidget {
  final List<SentencePair> sentences;
  final String translationLabel;

  const TranslatableParagraph({
    super.key,
    required this.sentences,
    this.translationLabel = 'Base language',
  });

  @override
  State<TranslatableParagraph> createState() => _TranslatableParagraphState();
}

class _TranslatableParagraphState extends State<TranslatableParagraph> {
  final Set<int> _translatedSentences = {};
  bool _showParagraphTranslation = false;

  String get _paragraphTranslation =>
      widget.sentences.map((sentence) => sentence.translated).join(' ');

  void _toggleSentence(int index) {
    setState(() {
      _showParagraphTranslation = false;
      if (_translatedSentences.contains(index)) {
        _translatedSentences.remove(index);
      } else {
        _translatedSentences.add(index);
      }
    });
  }

  void _toggleParagraph() {
    setState(() {
      _translatedSentences.clear();
      _showParagraphTranslation = !_showParagraphTranslation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _toggleParagraph,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _showParagraphTranslation
              ? FluentianColors.primaryTint
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _showParagraphTranslation
                ? FluentianColors.primary.withValues(alpha: 0.22)
                : FluentianColors.border,
          ),
          boxShadow: [FluentianShadows.subtle],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.sentences.asMap().entries.map((entry) {
              final index = entry.key;
              final pair = entry.value;
              final isTranslated = _translatedSentences.contains(index);
              return _TranslatableSentence(
                pair: pair,
                isTranslated: isTranslated,
                onTap: () => _toggleSentence(index),
              );
            }),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _showParagraphTranslation
                  ? Padding(
                      key: const ValueKey('paragraph-translation'),
                      padding: const EdgeInsets.only(top: 12),
                      child: _TranslationPanel(
                        label: widget.translationLabel,
                        text: _paragraphTranslation,
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('paragraph-translation-empty'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslatableSentence extends StatelessWidget {
  final SentencePair pair;
  final bool isTranslated;
  final VoidCallback onTap;

  const _TranslatableSentence({
    required this.pair,
    required this.isTranslated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pair.original,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.48,
                  fontWeight: FontWeight.w500,
                  color: FluentianColors.textPrimary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isTranslated
                    ? Padding(
                        key: const ValueKey('sentence-translation'),
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          pair.translated,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.45,
                            color: FluentianColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('sentence-translation-empty'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranslationPanel extends StatelessWidget {
  final String label;
  final String text;

  const _TranslationPanel({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FluentianColors.primary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Iconsax.translate,
                size: 15,
                color: FluentianColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: FluentianColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

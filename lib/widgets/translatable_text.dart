import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';

class SentencePair {
  final String original;
  final String translated;

  const SentencePair({required this.original, required this.translated});
}

class TranslatableParagraph extends StatefulWidget {
  final List<SentencePair> sentences;
  final String translationLabel;
  final void Function(String word, SentencePair sentence)? onWordTap;

  const TranslatableParagraph({
    super.key,
    required this.sentences,
    this.translationLabel = 'Base language',
    this.onWordTap,
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
    if (context.read<AuthProvider>().user?.hapticFeedbackEnabled ?? true) {
      HapticFeedback.selectionClick();
    }
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
    if (context.read<AuthProvider>().user?.hapticFeedbackEnabled ?? true) {
      HapticFeedback.mediumImpact();
    }
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
          borderRadius: BorderRadius.circular(0),
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
                onWordTap: widget.onWordTap == null
                    ? null
                    : (word) => widget.onWordTap!(word, pair),
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

class _TranslatableSentence extends StatefulWidget {
  final SentencePair pair;
  final bool isTranslated;
  final VoidCallback onTap;
  final ValueChanged<String>? onWordTap;

  const _TranslatableSentence({
    required this.pair,
    required this.isTranslated,
    required this.onTap,
    this.onWordTap,
  });

  @override
  State<_TranslatableSentence> createState() => _TranslatableSentenceState();
}

class _TranslatableSentenceState extends State<_TranslatableSentence> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: _pressed ? 0.985 : 1,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          borderRadius: BorderRadius.circular(0),
          splashColor: FluentianColors.primary.withValues(alpha: 0.08),
          highlightColor: FluentianColors.primary.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: widget.isTranslated
                  ? FluentianColors.primaryTint
                  : FluentianColors.pageBg,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(
                color: widget.isTranslated
                    ? FluentianColors.primary.withValues(alpha: 0.26)
                    : FluentianColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _WordWrappedText(
                        text: widget.pair.original,
                        onWordTap: widget.onWordTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: widget.isTranslated ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Icon(
                        Iconsax.arrow_down_1,
                        size: 16,
                        color: widget.isTranslated
                            ? FluentianColors.primary
                            : FluentianColors.textSecondary.withValues(
                                alpha: 0.65,
                              ),
                      ),
                    ),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      alignment: Alignment.topCenter,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: widget.isTranslated
                      ? Padding(
                          key: const ValueKey('sentence-translation'),
                          padding: const EdgeInsets.only(top: 9),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(0),
                              border: Border.all(
                                color: FluentianColors.primary.withValues(
                                  alpha: 0.14,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Iconsax.message_text,
                                  size: 16,
                                  color: FluentianColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.pair.translated,
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 14,
                                      height: 1.45,
                                      color: FluentianColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}

class _WordWrappedText extends StatelessWidget {
  final String text;
  final ValueChanged<String>? onWordTap;

  const _WordWrappedText({required this.text, this.onWordTap});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.ibmPlexSans(
      fontSize: 16,
      height: 1.45,
      fontWeight: FontWeight.w600,
      color: FluentianColors.textPrimary,
    );
    if (onWordTap == null) return Text(text, style: style);
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: text.split(RegExp(r'\s+')).map((word) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onWordTap!(word),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(word, style: style),
          ),
        );
      }).toList(),
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
        borderRadius: BorderRadius.circular(0),
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
                style: GoogleFonts.ibmPlexSans(
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
            style: GoogleFonts.ibmPlexSans(
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

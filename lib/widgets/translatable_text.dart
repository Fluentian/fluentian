import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class TranslatableText extends StatefulWidget {
  final String text;
  final String baseLanguageText;

  const TranslatableText({
    super.key,
    required this.text,
    required this.baseLanguageText,
  });

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  // We'll split the text into sentences by looking for punctuation.
  // For MVP, we provide a structured object for sentences if we want perfect matching,
  // or we can just toggle the entire paragraph. The requirements say:
  // "clicking or long-pressing sentence by sentence or paragraph at once".
  // Let's implement paragraph toggle for simplicity first, then sentence-level.
  
  // Since parsing aligned sentences from two distinct strings (French and base)
  // accurately is hard without pre-aligned data, we will assume the data 
  // passed is a list of Sentence pair objects for the actual implementation.
  // Wait, let's make the widget accept a list of sentence pairs.

  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showTranslation = !_showTranslation;
        });
      },
      onLongPress: () {
        setState(() {
          _showTranslation = !_showTranslation;
        });
      },
      child: AnimatedCrossFade(
        firstChild: Text(
          widget.text,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.6,
            color: FluentianColors.textPrimary,
          ),
        ),
        secondChild: Text(
          widget.baseLanguageText,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.6,
            color: FluentianColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        crossFadeState: _showTranslation
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class TranslatableParagraph extends StatelessWidget {
  final List<SentencePair> sentences;

  const TranslatableParagraph({super.key, required this.sentences});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: sentences.map((pair) {
        return TranslatableText(
          text: pair.original,
          baseLanguageText: pair.translated,
        );
      }).toList(),
    );
  }
}

class SentencePair {
  final String original;
  final String translated;

  const SentencePair({required this.original, required this.translated});
}

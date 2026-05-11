import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import 'lesson_complete_screen.dart';

class McqScreen extends StatefulWidget {
  const McqScreen({super.key});
  @override
  State<McqScreen> createState() => _McqScreenState();
}

class _McqScreenState extends State<McqScreen> {
  int? _selected;
  _AnswerState _state = _AnswerState.unanswered;
  final int _correctIndex = 1;
  int _hearts = 3;

  final _options = const [
    _Option('A', "Quel est ton nom ?", 'Informal form'),
    _Option('B', "Comment vous appelez-vous ?", 'Formal form'),
    _Option('C', "Où habites-tu ?", 'Where do you live?'),
    _Option('D', "Comment allez-vous ?", 'How are you?'),
  ];

  void _check() {
    if (_selected == null) return;
    setState(() {
      _state = _selected == _correctIndex
          ? _AnswerState.correct
          : _AnswerState.wrong;
      if (_state == _AnswerState.wrong && _hearts > 0) _hearts--;
    });
    _showResultSheet();
  }

  void _showResultSheet() {
    final correct = _state == _AnswerState.correct;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: correct
              ? FluentianColors.successTint
              : FluentianColors.errorTint,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct ? 'Correct! 🎉' : 'Not quite 💪',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: correct
                    ? FluentianColors.success
                    : FluentianColors.error,
              ),
            ),
            const SizedBox(height: 8),
            if (correct)
              Text(
                '"Comment vous appelez-vous?" is the formal way to ask someone\'s name.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FluentianColors.textSecondary,
                ),
              )
            else ...[
              if (!correct)
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: FluentianColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '-1',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.error,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FluentianColors.successTint,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: FluentianColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: FluentianColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Comment vous appelez-vous ?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (correct) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LessonCompleteScreen(),
                      ),
                    );
                  } else {
                    setState(() {
                      _selected = null;
                      _state = _AnswerState.unanswered;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: correct
                      ? FluentianColors.success
                      : Colors.grey.shade300,
                  foregroundColor: correct
                      ? Colors.white
                      : FluentianColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(correct ? 'Continue' : 'Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade500,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(
                          FluentianColors.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.only(left: 1),
                        child: Icon(
                          i < _hearts
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: i < _hearts
                              ? FluentianColors.error
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'TRANSLATE TO FRENCH',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'What is your name?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    ...List.generate(_options.length, (i) {
                      final o = _options[i];
                      final isSelected = _selected == i;
                      final isCorrect =
                          _state != _AnswerState.unanswered &&
                          i == _correctIndex;
                      final isWrong =
                          _state == _AnswerState.wrong && isSelected;

                      Color bg = FluentianColors.white;
                      Color border = FluentianColors.border;
                      if (isSelected && _state == _AnswerState.unanswered) {
                        bg = FluentianColors.primaryTint;
                        border = FluentianColors.primary;
                      }
                      if (isCorrect && _state != _AnswerState.unanswered) {
                        bg = FluentianColors.successTint;
                        border = FluentianColors.success;
                      }
                      if (isWrong) {
                        bg = FluentianColors.errorTint;
                        border = FluentianColors.error;
                      }

                      return GestureDetector(
                        onTap: _state == _AnswerState.unanswered
                            ? () => setState(() => _selected = i)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: border,
                              width: isSelected || isCorrect || isWrong ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                ),
                                child: Center(
                                  child: Text(
                                    o.letter,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: FluentianColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.text,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: FluentianColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      o.hint,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: FluentianColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Check button
            Padding(
              padding: const EdgeInsets.all(16),
              child: FluentianButton(
                text: 'Check ✓',
                onPressed:
                    _selected != null && _state == _AnswerState.unanswered
                    ? _check
                    : null,
                backgroundColor: _selected != null
                    ? FluentianColors.primary
                    : Colors.grey.shade300,
                textColor: _selected != null ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AnswerState { unanswered, correct, wrong }

class _Option {
  final String letter, text, hint;
  const _Option(this.letter, this.text, this.hint);
}

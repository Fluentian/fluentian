import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import '../models/course_model.dart';
import '../models/progress_model.dart';
import '../providers/content_provider.dart';
import 'lesson_complete_screen.dart';

class McqScreen extends StatefulWidget {
  final String lessonId;
  final List<QuestionModel> questions;

  const McqScreen({
    super.key,
    required this.lessonId,
    required this.questions,
  });

  @override
  State<McqScreen> createState() => _McqScreenState();
}

class _McqScreenState extends State<McqScreen> {
  int _currentIndex = 0;
  int? _selected;
  _AnswerState _state = _AnswerState.unanswered;
  int _hearts = 5;
  int _correctCount = 0;
  
  final List<AnswerPayload> _answers = [];
  final DateTime _startTime = DateTime.now();
  bool _isSubmitting = false;

  QuestionModel get _currentQ => widget.questions[_currentIndex];

  void _check() {
    if (_selected == null) return;
    
    final selectedAnswer = _currentQ.mcqOptions[_selected!];
    final isCorrect = selectedAnswer == _currentQ.mcqCorrectAnswer;

    _answers.add(AnswerPayload(
      questionId: _currentQ.id,
      answer: selectedAnswer,
      isCorrect: isCorrect,
    ));

    setState(() {
      _state = isCorrect ? _AnswerState.correct : _AnswerState.wrong;
      if (isCorrect) {
        _correctCount++;
      } else if (_hearts > 0) {
        _hearts--;
      }
    });
    
    _showResultSheet(isCorrect, _currentQ.mcqCorrectAnswer);
  }

  void _showResultSheet(bool correct, String correctAnswer) {
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
            if (!correct) ...[
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
                    Expanded(
                      child: Text(
                        correctAnswer,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FluentianColors.success,
                        ),
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
                onPressed: _isSubmitting ? null : () => _onNext(correct),
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
                child: _isSubmitting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(correct ? 'Continue' : 'Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onNext(bool correct) async {
    if (_currentIndex < widget.questions.length - 1) {
      Navigator.pop(context); // close sheet
      setState(() {
        _currentIndex++;
        _selected = null;
        _state = _AnswerState.unanswered;
      });
    } else {
      // Finished all questions!
      setState(() => _isSubmitting = true);
      
      final score = widget.questions.isEmpty 
          ? 1.0 
          : _correctCount / widget.questions.length;
      final timeSeconds = DateTime.now().difference(_startTime).inSeconds;

      await context.read<ContentProvider>().completeLesson(
        lessonId: widget.lessonId,
        score: score,
        answers: _answers,
        timeSeconds: timeSeconds,
      );

      if (!mounted) return;
      Navigator.pop(context); // close sheet
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LessonCompleteScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No questions found.")),
      );
    }

    final options = _currentQ.mcqOptions;
    final progress = (_currentIndex) / widget.questions.length;

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
                        value: progress,
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
                      'QUESTION',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentQ.promptText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    ...List.generate(options.length, (i) {
                      final optionText = options[i];
                      final isSelected = _selected == i;
                      
                      // For MVP we just show selected or unselected while unanswered.
                      // Correct/Wrong visual logic on options only matters if not immediately obscured by bottom sheet,
                      // but bottom sheet pops up instantly. Still, keeping the UI states:
                      final isCorrect = _state != _AnswerState.unanswered && isSelected && _state == _AnswerState.correct;
                      final isWrong = _state == _AnswerState.wrong && isSelected;

                      Color bg = FluentianColors.white;
                      Color border = FluentianColors.border;
                      if (isSelected && _state == _AnswerState.unanswered) {
                        bg = FluentianColors.primaryTint;
                        border = FluentianColors.primary;
                      }
                      if (isCorrect) {
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
                                    String.fromCharCode(65 + i), // A, B, C, D
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
                                child: Text(
                                  optionText,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: FluentianColors.textPrimary,
                                  ),
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

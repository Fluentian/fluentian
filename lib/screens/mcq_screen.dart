import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import '../models/course_model.dart';
import '../models/progress_model.dart';
import '../providers/content_provider.dart';
import '../services/tts_service.dart';
import 'lesson_complete_screen.dart';

enum _RecordState { idle, recording, analyzing, result }

class McqScreen extends StatefulWidget {
  final String lessonId;
  final List<QuestionModel> questions;

  const McqScreen({super.key, required this.lessonId, required this.questions});

  @override
  State<McqScreen> createState() => _McqScreenState();
}

class _McqScreenState extends State<McqScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selected;
  _AnswerState _state = _AnswerState.unanswered;
  int _hearts = 5;
  int _correctCount = 0;

  final List<AnswerPayload> _answers = [];
  final DateTime _startTime = DateTime.now();
  bool _isSubmitting = false;

  late final AudioPlayer _audioPlayer;
  final TtsService _ttsService = TtsService.instance;

  // Controllers
  final TextEditingController _textController = TextEditingController();

  // Dynamic question variables
  Set<int> _selectedMulti = {};
  List<String> _assembledWords = [];
  List<String> _remainingScrambled = [];

  // Matching variables
  List<String> _leftItems = [];
  List<String> _rightItems = [];
  String? _selectedLeft;
  String? _selectedRight;
  Map<String, String> _matches = {}; // left -> right

  // Speaking variables
  _RecordState _recordState = _RecordState.idle;
  late AnimationController _pulseCtrl;
  double _pronunciationScore = 0.0;

  // Audio state variables
  bool _audioLoading = false;
  bool _audioPlaying = false;
  String? _loadedAudioUrl;

  QuestionModel get _currentQ => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Listen to player state streams
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlaying =
              state.playing &&
              state.processingState != ProcessingState.completed;
          _audioLoading =
              state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });

    _initQuestion();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _ttsService.stop();
    _pulseCtrl.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _initQuestion() {
    try {
      _audioPlayer.stop();
    } catch (_) {}

    _selected = null;
    _selectedMulti.clear();
    _textController.clear();
    _assembledWords.clear();
    _remainingScrambled.clear();
    _leftItems.clear();
    _rightItems.clear();
    _selectedLeft = null;
    _selectedRight = null;
    _matches.clear();
    _recordState = _RecordState.idle;
    _pronunciationScore = 0.0;

    final q = _currentQ;

    // Prepare for Reorder or Translation (chips)
    if (q.questionKind == 'reorder' || q.questionKind == 'translation') {
      final opts = q.mcqOptions;
      if (opts.isNotEmpty) {
        _remainingScrambled = List<String>.from(opts)..shuffle();
      }
    }

    // Prepare for Match Pairs
    if (q.questionKind == 'match_pairs') {
      final pairs = q.matchPairs;
      _leftItems = pairs.map((e) => e['left']!).toList()..shuffle();
      _rightItems = pairs.map((e) => e['right']!).toList()..shuffle();
    }

    // Play audio automatically if autoplay is appropriate (dictation / listening)
    if (q.audioUrl != null && q.audioUrl!.isNotEmpty) {
      _playQuestionAudio();
    } else if (q.ttsEnabled &&
        q.textToSpeak.trim().isNotEmpty &&
        q.questionKind != 'speech_record') {
      _speakCurrentQuestion();
    }
  }

  Future<void> _playQuestionAudio() async {
    final url = _currentQ.audioUrl;
    if (url != null && url.isNotEmpty) {
      try {
        if (_loadedAudioUrl != url) {
          setState(() {
            _audioLoading = true;
          });
          _loadedAudioUrl = url;
          await _audioPlayer.setUrl(url);
        }
        await _audioPlayer.play();
      } catch (e) {
        debugPrint('Audio playback error: $url $e');
        if (mounted) {
          setState(() {
            _audioLoading = false;
          });
        }
      }
    }
  }

  Future<void> _toggleAudio() async {
    if (_audioLoading) return; // Prevent double taps while loading/buffering

    final url = _currentQ.audioUrl;
    if (url == null || url.isEmpty) {
      await _speakCurrentQuestion();
      return;
    }

    try {
      if (_loadedAudioUrl != url) {
        setState(() {
          _audioLoading = true;
        });
        _loadedAudioUrl = url;
        await _audioPlayer.setUrl(url);
      }

      if (_audioPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint('Audio player error: $url $e');
      if (mounted) {
        setState(() {
          _audioLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load audio.')));
      }
    }
  }

  void _startRecording() {
    setState(() {
      _recordState = _RecordState.recording;
    });
    _pulseCtrl.repeat(reverse: true);

    // Auto stop after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _recordState == _RecordState.recording) {
        _stopRecording();
      }
    });
  }

  Future<void> _speakCurrentQuestion() async {
    try {
      await _audioPlayer.stop();
      await _ttsService.speak(
        _currentQ.textToSpeak,
        language: _currentQ.ttsLanguage,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load audio.')));
      }
    }
  }

  void _stopRecording() {
    _pulseCtrl.stop();
    setState(() {
      _recordState = _RecordState.analyzing;
    });

    // Simulate analyzing for 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _recordState = _RecordState.result;
          _pronunciationScore = 88.0 + (DateTime.now().millisecond % 10);
        });
      }
    });
  }

  void _checkMatchTrigger() {
    if (_selectedLeft != null && _selectedRight != null) {
      setState(() {
        _matches.remove(_selectedLeft);
        _matches.removeWhere((key, value) => value == _selectedRight);
        _matches[_selectedLeft!] = _selectedRight!;
        _selectedLeft = null;
        _selectedRight = null;
      });
    }
  }

  static final List<_PairColorStyle> _pairColors = [
    const _PairColorStyle(
      bg: Color(0xFFF0E5FF),
      border: Color(0xFF9F7AEA),
      text: Color(0xFF553C9A),
      badge: '①',
    ),
    const _PairColorStyle(
      bg: Color(0xFFEBF8FF),
      border: Color(0xFF63B3ED),
      text: Color(0xFF2B6CB0),
      badge: '②',
    ),
    const _PairColorStyle(
      bg: Color(0xFFE6FFFA),
      border: Color(0xFF4FD1C5),
      text: Color(0xFF2C7A7B),
      badge: '③',
    ),
    const _PairColorStyle(
      bg: Color(0xFFFEFCBF),
      border: Color(0xFFF6E05E),
      text: Color(0xFFB7791F),
      badge: '④',
    ),
    const _PairColorStyle(
      bg: Color(0xFFFFF5F5),
      border: Color(0xFFFEB2B2),
      text: Color(0xFF9B2C2C),
      badge: '⑤',
    ),
  ];

  _PairColorStyle? _getMatchStyle(String leftOrRight, bool isLeft) {
    String? left;
    String? right;
    if (isLeft) {
      left = leftOrRight;
      right = _matches[left];
    } else {
      right = leftOrRight;
      for (final entry in _matches.entries) {
        if (entry.value == right) {
          left = entry.key;
          break;
        }
      }
    }

    if (left == null || right == null) return null;

    final keys = _matches.keys.toList();
    final idx = keys.indexOf(left);
    if (idx != -1) {
      return _pairColors[idx % _pairColors.length];
    }
    return null;
  }

  bool _isPairCorrect(String left, String right) {
    for (final p in _currentQ.matchPairs) {
      if (p['left'] == left && p['right'] == right) {
        return true;
      }
    }
    return false;
  }

  bool _isCheckEnabled() {
    final q = _currentQ;
    if (q.questionKind == 'mcq_single' ||
        q.questionKind == 'fill_blank' && q.mcqOptions.isNotEmpty ||
        q.questionKind == 'translation' &&
            q.mcqOptions.isNotEmpty &&
            _assembledWords.isEmpty &&
            _selected != null ||
        q.questionKind == 'listening_comprehension') {
      return _selected != null;
    }
    if (q.questionKind == 'mcq_multi') {
      return _selectedMulti.isNotEmpty;
    }
    if (q.questionKind == 'fill_blank' && q.mcqOptions.isEmpty ||
        q.questionKind == 'short_text' ||
        q.questionKind == 'dictation') {
      return _textController.text.trim().isNotEmpty;
    }
    if (q.questionKind == 'reorder' ||
        q.questionKind == 'translation' && _assembledWords.isNotEmpty) {
      return _assembledWords.isNotEmpty;
    }
    if (q.questionKind == 'match_pairs') {
      return _matches.length == _leftItems.length;
    }
    if (q.questionKind == 'speech_record') {
      return _recordState == _RecordState.result;
    }
    return false;
  }

  void _check() {
    final q = _currentQ;
    bool isCorrect = false;
    String correctAnswerText = '';
    String userAnswerText = '';

    if (q.questionKind == 'mcq_single' ||
        q.questionKind == 'fill_blank' && q.mcqOptions.isNotEmpty ||
        q.questionKind == 'translation' &&
            q.mcqOptions.isNotEmpty &&
            _assembledWords.isEmpty &&
            _selected != null ||
        q.questionKind == 'listening_comprehension') {
      if (_selected == null) return;
      final selectedAnswer = q.mcqOptions[_selected!];
      isCorrect = selectedAnswer == q.mcqCorrectAnswer;
      correctAnswerText = q.mcqCorrectAnswer;
      userAnswerText = selectedAnswer;
    } else if (q.questionKind == 'mcq_multi') {
      final selectedAnswers = _selectedMulti
          .map((idx) => q.mcqOptions[idx])
          .toSet();
      final correctAnswers = q.mcqMultiCorrectAnswers.toSet();
      isCorrect =
          selectedAnswers.length == correctAnswers.length &&
          selectedAnswers.every((e) => correctAnswers.contains(e));
      correctAnswerText = q.mcqMultiCorrectAnswers.join(', ');
      userAnswerText = selectedAnswers.join(', ');
    } else if (q.questionKind == 'fill_blank' && q.mcqOptions.isEmpty ||
        q.questionKind == 'short_text' ||
        q.questionKind == 'dictation') {
      final typed = _textController.text.trim();
      final correct = q.mcqCorrectAnswer.trim();

      String clean(String s) =>
          s.toLowerCase().replaceAll(RegExp(r'[.,!?]'), '').trim();
      isCorrect = clean(typed) == clean(correct);
      correctAnswerText = correct;
      userAnswerText = typed;
    } else if (q.questionKind == 'reorder' ||
        q.questionKind == 'translation' && _assembledWords.isNotEmpty) {
      final assembled = _assembledWords.join(' ').trim();
      final correct = q.mcqCorrectAnswer.trim();

      String clean(String s) =>
          s.toLowerCase().replaceAll(RegExp(r'[.,!?]'), '').trim();
      isCorrect = clean(assembled) == clean(correct);
      correctAnswerText = correct;
      userAnswerText = assembled;
    } else if (q.questionKind == 'match_pairs') {
      final pairs = q.matchPairs;
      isCorrect = true;
      for (final p in pairs) {
        if (_matches[p['left']] != p['right']) {
          isCorrect = false;
          break;
        }
      }
      correctAnswerText = pairs
          .map((e) => "${e['left']} -> ${e['right']}")
          .join('\n');
      userAnswerText = _matches.entries
          .map((e) => "${e.key} -> ${e.value}")
          .join('\n');
    } else if (q.questionKind == 'speech_record') {
      isCorrect = _pronunciationScore >= 80.0;
      correctAnswerText = q.mcqCorrectAnswer;
      userAnswerText = 'Pronunciation Score: ${_pronunciationScore.toInt()}%';
    }

    _answers.add(
      AnswerPayload(
        questionId: q.id,
        answer: userAnswerText,
        isCorrect: isCorrect,
      ),
    );

    setState(() {
      _state = isCorrect ? _AnswerState.correct : _AnswerState.wrong;
      if (isCorrect) {
        _correctCount++;
      } else if (_hearts > 0) {
        _hearts--;
      }
    });

    _showResultSheet(isCorrect, correctAnswerText);
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
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
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
        _state = _AnswerState.unanswered;
      });
      _initQuestion();
    } else {
      setState(() => _isSubmitting = true);

      final score = widget.questions.isEmpty
          ? 1.0
          : _correctCount / widget.questions.length;
      final timeSeconds = DateTime.now().difference(_startTime).inSeconds;

      final result = await context.read<ContentProvider>().completeLesson(
        lessonId: widget.lessonId,
        score: score,
        answers: _answers,
        timeSeconds: timeSeconds,
      );

      if (!mounted) return;
      Navigator.pop(context); // close sheet
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonCompleteScreen(
            lessonId: widget.lessonId,
            xpEarned: result?.xpEarned ?? 0,
            newXpTotal: result?.newXpTotal ?? 0,
            accuracy: score,
            timeSeconds: timeSeconds,
            correctCount: _correctCount,
            totalQuestions: widget.questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("No questions found.")));
    }

    final progress = (_currentIndex) / widget.questions.length;
    final q = _currentQ;

    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar progress indicators
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

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      q.questionKind.replaceAll('_', ' ').toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: FluentianColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q.promptText.isNotEmpty
                          ? q.promptText
                          : 'Follow the prompt below:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Render dynamic image if present
                    if (q.imageUrl != null && q.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          q.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.broken_image_rounded,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Render dynamic audio if present
                    if (((q.audioUrl != null && q.audioUrl!.isNotEmpty) ||
                            (q.ttsEnabled &&
                                q.textToSpeak.trim().isNotEmpty)) &&
                        q.questionKind != 'speech_record') ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: FluentianColors.primaryTint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: FluentianColors.primary.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleAudio,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: FluentianColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: _audioLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _audioPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _audioLoading
                                  ? 'Loading audio...'
                                  : _audioPlaying
                                  ? 'Playing...'
                                  : 'Tap to listen to clip',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FluentianColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Render interactive layout by question kind
                    _buildQuestionContent(),
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
                    _isCheckEnabled() && _state == _AnswerState.unanswered
                    ? _check
                    : null,
                backgroundColor: _isCheckEnabled()
                    ? FluentianColors.primary
                    : Colors.grey.shade300,
                textColor: _isCheckEnabled() ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    final q = _currentQ;
    switch (q.questionKind) {
      case 'mcq_single':
      case 'listening_comprehension':
        return _buildMcqSingle();
      case 'mcq_multi':
        return _buildMcqMulti();
      case 'fill_blank':
        return _buildFillBlank();
      case 'reorder':
      case 'translation':
        return _buildWordAssembly();
      case 'match_pairs':
        return _buildMatchPairs();
      case 'short_text':
      case 'dictation':
        return _buildTextInput();
      case 'speech_record':
        return _buildSpeechRecord();
      default:
        return _buildMcqSingle();
    }
  }

  Widget _buildMcqSingle() {
    final options = _currentQ.mcqOptions;
    return Column(
      children: List.generate(options.length, (i) {
        final optionText = options[i];
        final isSelected = _selected == i;
        final isCorrect =
            _state != _AnswerState.unanswered &&
            isSelected &&
            _state == _AnswerState.correct;
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
                      String.fromCharCode(65 + i),
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
    );
  }

  Widget _buildMcqMulti() {
    final options = _currentQ.mcqOptions;
    return Column(
      children: List.generate(options.length, (i) {
        final optionText = options[i];
        final isSelected = _selectedMulti.contains(i);
        final isCorrect =
            _state != _AnswerState.unanswered &&
            isSelected &&
            _currentQ.mcqMultiCorrectAnswers.contains(optionText);
        final isWrong =
            _state == _AnswerState.wrong &&
            isSelected &&
            !_currentQ.mcqMultiCorrectAnswers.contains(optionText);

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
              ? () {
                  setState(() {
                    if (isSelected) {
                      _selectedMulti.remove(i);
                    } else {
                      _selectedMulti.add(i);
                    }
                  });
                }
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
                Icon(
                  isSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: isSelected
                      ? FluentianColors.primary
                      : FluentianColors.textSecondary,
                  size: 24,
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
    );
  }

  Widget _buildFillBlank() {
    final options = _currentQ.mcqOptions;
    if (options.isEmpty) {
      return _buildTextInput();
    }

    final sentence = _currentQ.promptText;
    final displaySentence = sentence.replaceAll(
      '___',
      _selected != null ? ' [ ${options[_selected!]} ] ' : ' _______ ',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            displaySentence,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: List.generate(options.length, (i) {
            final optionText = options[i];
            final isSelected = _selected == i;
            return ChoiceChip(
              label: Text(
                optionText,
                style: GoogleFonts.inter(
                  color: isSelected
                      ? Colors.white
                      : FluentianColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: _state == _AnswerState.unanswered
                  ? (val) => setState(() => _selected = val ? i : null)
                  : null,
              selectedColor: FluentianColors.primary,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWordAssembly() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _assembledWords.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to translate',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_assembledWords.length, (idx) {
                    final word = _assembledWords[idx];
                    return GestureDetector(
                      onTap: _state == _AnswerState.unanswered
                          ? () {
                              setState(() {
                                _assembledWords.removeAt(idx);
                                _remainingScrambled.add(word);
                              });
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: FluentianColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [FluentianShadows.subtle],
                        ),
                        child: Text(
                          word,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_remainingScrambled.length, (idx) {
            final word = _remainingScrambled[idx];
            return GestureDetector(
              onTap: _state == _AnswerState.unanswered
                  ? () {
                      setState(() {
                        _remainingScrambled.removeAt(idx);
                        _assembledWords.add(word);
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  word,
                  style: GoogleFonts.inter(
                    color: FluentianColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          enabled: _state == _AnswerState.unanswered,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: FluentianColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Type translation here...',
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: FluentianColors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildMatchPairs() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (French)
        Expanded(
          child: Column(
            children: _leftItems.map((left) {
              final isMatched = _matches.containsKey(left);
              final rightMatched = _matches[left];
              final isSelected = _selectedLeft == left;

              Color bgCol = Colors.white;
              Color borderCol = Colors.grey.shade200;
              Color textCol = FluentianColors.textPrimary;
              String badge = '';

              if (_state != _AnswerState.unanswered) {
                // Graded state
                if (isMatched && rightMatched != null) {
                  final correct = _isPairCorrect(left, rightMatched);
                  bgCol = correct
                      ? FluentianColors.successTint
                      : FluentianColors.errorTint;
                  borderCol = correct
                      ? FluentianColors.success
                      : FluentianColors.error;
                  textCol = correct
                      ? FluentianColors.success
                      : FluentianColors.error;
                }
              } else {
                // Unanswered state
                if (isSelected) {
                  bgCol = FluentianColors.primaryTint;
                  borderCol = FluentianColors.primary;
                  textCol = FluentianColors.primary;
                } else if (isMatched) {
                  final style = _getMatchStyle(left, true);
                  if (style != null) {
                    bgCol = style.bg;
                    borderCol = style.border;
                    textCol = style.text;
                    badge = style.badge;
                  }
                }
              }

              return GestureDetector(
                onTap: _state == _AnswerState.unanswered
                    ? () {
                        setState(() {
                          if (isMatched) {
                            _matches.remove(left);
                          } else {
                            if (_selectedLeft == left) {
                              _selectedLeft = null;
                            } else {
                              _selectedLeft = left;
                              _checkMatchTrigger();
                            }
                          }
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bgCol,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderCol,
                      width: isSelected || isMatched ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: FluentianColors.primary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (badge.isNotEmpty) ...[
                          Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            left,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textCol,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        // Right Column (English)
        Expanded(
          child: Column(
            children: _rightItems.map((right) {
              String? leftMatched;
              for (final entry in _matches.entries) {
                if (entry.value == right) {
                  leftMatched = entry.key;
                  break;
                }
              }
              final isMatched = leftMatched != null;
              final isSelected = _selectedRight == right;

              Color bgCol = Colors.white;
              Color borderCol = Colors.grey.shade200;
              Color textCol = FluentianColors.textPrimary;
              String badge = '';

              if (_state != _AnswerState.unanswered) {
                // Graded state
                if (isMatched && leftMatched != null) {
                  final correct = _isPairCorrect(leftMatched, right);
                  bgCol = correct
                      ? FluentianColors.successTint
                      : FluentianColors.errorTint;
                  borderCol = correct
                      ? FluentianColors.success
                      : FluentianColors.error;
                  textCol = correct
                      ? FluentianColors.success
                      : FluentianColors.error;
                }
              } else {
                // Unanswered state
                if (isSelected) {
                  bgCol = FluentianColors.primaryTint;
                  borderCol = FluentianColors.primary;
                  textCol = FluentianColors.primary;
                } else if (isMatched) {
                  final style = _getMatchStyle(right, false);
                  if (style != null) {
                    bgCol = style.bg;
                    borderCol = style.border;
                    textCol = style.text;
                    badge = style.badge;
                  }
                }
              }

              return GestureDetector(
                onTap: _state == _AnswerState.unanswered
                    ? () {
                        setState(() {
                          if (isMatched) {
                            _matches.removeWhere((key, val) => val == right);
                          } else {
                            if (_selectedRight == right) {
                              _selectedRight = null;
                            } else {
                              _selectedRight = right;
                              _checkMatchTrigger();
                            }
                          }
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: bgCol,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderCol,
                      width: isSelected || isMatched ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: FluentianColors.primary.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (badge.isNotEmpty) ...[
                          Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textCol,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            right,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textCol,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechRecord() {
    final phrase = _currentQ.promptPayload['text']?.toString() ?? '';
    final isRecording = _recordState == _RecordState.recording;
    final isAnalyzing = _recordState == _RecordState.analyzing;
    final isResult = _recordState == _RecordState.result;

    return Column(
      children: [
        Text(
          phrase,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: FluentianColors.primary,
          ),
        ),
        const SizedBox(height: 24),

        // Native speaking audio player card
        if ((_currentQ.audioUrl != null && _currentQ.audioUrl!.isNotEmpty) ||
            _currentQ.textToSpeak.trim().isNotEmpty)
          GestureDetector(
            onTap: _toggleAudio,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: FluentianColors.primaryTint,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: FluentianColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _audioLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: FluentianColors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _audioPlaying
                              ? Icons.pause_rounded
                              : Icons.volume_up_rounded,
                          color: FluentianColors.primary,
                          size: 20,
                        ),
                  const SizedBox(width: 8),
                  Text(
                    _audioLoading
                        ? 'Loading...'
                        : _audioPlaying
                        ? 'Playing...'
                        : 'Listen to speaker',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: FluentianColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 40),

        // Recorder Microphone
        Column(
          children: [
            GestureDetector(
              onTap:
                  isAnalyzing || isResult || _state != _AnswerState.unanswered
                  ? null
                  : () {
                      if (isRecording) {
                        _stopRecording();
                      } else {
                        _startRecording();
                      }
                    },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isRecording)
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Container(
                        width: 90 + _pulseCtrl.value * 25,
                        height: 90 + _pulseCtrl.value * 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: FluentianColors.error.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? FluentianColors.error
                          : isAnalyzing
                          ? FluentianColors.primary
                          : Colors.white,
                      border: Border.all(
                        color: isRecording
                            ? FluentianColors.error
                            : FluentianColors.primary,
                        width: 3,
                      ),
                    ),
                    child: isAnalyzing
                        ? const Padding(
                            padding: EdgeInsets.all(22.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isRecording
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            size: 30,
                            color: isRecording
                                ? Colors.white
                                : FluentianColors.primary,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isRecording
                  ? 'Recording... Tap to stop'
                  : isAnalyzing
                  ? 'Analyzing voice pronunciation...'
                  : isResult
                  ? 'Voice Analyzed'
                  : 'Tap to speak',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: FluentianColors.textSecondary,
              ),
            ),
          ],
        ),

        if (isResult) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FluentianColors.border),
              boxShadow: [FluentianShadows.subtle],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: FluentianColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Result: ${_pronunciationScore.toInt()}% Match',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MetricRow(
                  'Pronunciation',
                  _pronunciationScore / 100,
                  FluentianColors.info,
                ),
                _MetricRow('Fluency', 0.90, FluentianColors.success),
                _MetricRow('Accuracy', 0.84, FluentianColors.accent),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MetricRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: FluentianColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(value * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

enum _AnswerState { unanswered, correct, wrong }

class _PairColorStyle {
  final Color bg;
  final Color border;
  final Color text;
  final String badge;
  const _PairColorStyle({
    required this.bg,
    required this.border,
    required this.text,
    required this.badge,
  });
}

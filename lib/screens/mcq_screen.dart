import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import '../models/course_model.dart';
import '../models/progress_model.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../services/media_cache_manager.dart';
import '../services/sound_effect_service.dart';
import '../services/tts_service.dart';
import '../services/api_client.dart';
import '../widgets/ai_tutor_sheet.dart';
import 'lesson_complete_screen.dart';

enum _RecordState { idle, recording, analyzing, result }

class McqScreen extends StatefulWidget {
  final String lessonId;
  final List<QuestionModel> questions;
  final int xpReward;
  final bool isSrsReview;

  const McqScreen({
    super.key,
    required this.lessonId,
    required this.questions,
    required this.xpReward,
    this.isSrsReview = false,
  });

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
  final List<Future<void>> _pendingHeartWrites = [];
  final DateTime _startTime = DateTime.now();
  bool _isSubmitting = false;
  int _persistedHeartSpends = 0;
  // Tracks whether the result bottom sheet is actually still on the
  // Navigator stack. It can close itself via the Android back button even
  // with isDismissible: false (that only blocks tap-outside), so by the
  // time _onNext's several awaits finish, it may already be gone -- popping
  // it unconditionally then pops something else (or nothing), corrupting
  // the stack for the pushReplacement right after and crashing with
  // "Navigator has no active routes to replace".
  bool _resultSheetOpen = false;

  late final AudioPlayer _audioPlayer;
  final TtsService _ttsService = TtsService.instance;

  // Controllers
  final TextEditingController _textController = TextEditingController();

  // Dynamic question variables
  final Set<int> _selectedMulti = {};
  final List<String> _assembledWords = [];
  List<String> _remainingScrambled = [];

  // Matching variables
  List<String> _leftItems = [];
  List<String> _rightItems = [];
  String? _selectedLeft;
  String? _selectedRight;
  final Map<String, String> _matches = {}; // left -> right

  // Speaking variables
  _RecordState _recordState = _RecordState.idle;
  late AnimationController _pulseCtrl;
  double _pronunciationScore = 0.0;

  // Audio state variables
  bool _audioLoading = false;
  bool _audioPlaying = false;
  String? _loadedAudioUrl;

  List<QuestionModel> get _activeQuestions {
    final speakingEnabled =
        context.read<AuthProvider>().user?.speakingExercisesEnabled ?? true;
    if (speakingEnabled) return widget.questions;
    return widget.questions
        .where((question) => question.questionKind != 'speech_record')
        .toList(growable: false);
  }

  QuestionModel get _currentQ => _activeQuestions[_currentIndex];

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

    final cachedHearts = context.read<AuthProvider>().user?.hearts;
    final statsHearts = context.read<ContentProvider>().stats?.hearts;
    _hearts = statsHearts ?? cachedHearts ?? _hearts;
    _initQuestion();
    _loadPersistentHearts();
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
    final autoplay = context.read<AuthProvider>().user?.autoplayAudio ?? true;
    if (autoplay && q.audioUrl != null && q.audioUrl!.isNotEmpty) {
      _playQuestionAudio();
    } else if (autoplay &&
        q.ttsEnabled &&
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
          await MediaCacheManager.instance.loadIntoPlayer(_audioPlayer, url);
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
        ).showSnackBar(const SnackBar(content: LText('Failed to load audio.')));
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
      final ttsSpeed = context.read<AuthProvider>().user?.ttsSpeed ?? 1.0;
      await _audioPlayer.stop();
      await _ttsService.speak(
        _currentQ.textToSpeak,
        language: _currentQ.ttsLanguage,
        speed: ttsSpeed,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: LText('Failed to load audio.')));
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
      bg: Color(0xFFEAF2F8),
      border: Color(0xFF2C5E90),
      text: Color(0xFF072D52),
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
    if (_hearts <= 0) return false;
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

  Future<void> _loadPersistentHearts() async {
    final hearts = await context.read<AuthProvider>().refreshHearts();
    if (!mounted || hearts == null) return;
    setState(() {
      _hearts = hearts;
    });
  }

  Future<int?> _refreshPersistentHearts() async {
    final hearts = await context.read<AuthProvider>().refreshHearts();
    if (!mounted || hearts == null) return hearts;
    setState(() {
      _hearts = hearts;
    });
    return hearts;
  }

  Future<void> _syncWrongAnswerHeart() async {
    final hearts = await context.read<AuthProvider>().spendHeart();
    if (!mounted || hearts == null) return;
    _persistedHeartSpends++;
    setState(() {
      _hearts = hearts;
    });
  }

  Future<void> _showOutOfHeartsSheet() async {
    final refreshedHearts = await _refreshPersistentHearts();
    if (!mounted) return;
    if ((refreshedHearts ?? _hearts) > 0) {
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: FluentianColors.errorTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.heart5,
                color: FluentianColors.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            LText(
              'Hearts are refilling',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            LText(
              'Take a quick break, review a lesson, or come back when the next heart is ready.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: FluentianColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final hearts = auth.user?.hearts ?? _hearts;
                return HeartStatusChip(
                  hearts: hearts,
                  maxHearts: auth.maxHearts,
                  nextRefillAt: auth.nextHeartRefillAt,
                  onRefreshDue: () {
                    _refreshPersistentHearts();
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.clock),
                label: const LText('Got it'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const LText('Stay here'),
            ),
          ],
        ),
      ),
    );
  }

  String _cleanTextForGrading(String s) {
    final noAccents = s
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ÉÈÊË]'), 'e')
        .replaceAll(RegExp(r'[ÀÂÄ]'), 'a')
        .replaceAll(RegExp(r'[ÔÖ]'), 'o')
        .replaceAll(RegExp(r'[ÎÏ]'), 'i')
        .replaceAll(RegExp(r'[ÙÛÜ]'), 'u')
        .replaceAll(RegExp(r'[Ç]'), 'c');
    return noAccents
        .toLowerCase()
        .replaceAll(RegExp(r"[.,!?;:'\x22\-’«»]"), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _check() {
    final q = _currentQ;
    bool isCorrect = false;
    String correctAnswerText = '';
    String userAnswerText = '';
    dynamic submittedAnswer;

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
      submittedAnswer = selectedAnswer;
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
      submittedAnswer = selectedAnswers.toList();
    } else if (q.questionKind == 'fill_blank' && q.mcqOptions.isEmpty ||
        q.questionKind == 'short_text' ||
        q.questionKind == 'dictation') {
      final typed = _textController.text.trim();
      final correct = q.mcqCorrectAnswer.trim();

      isCorrect = q.acceptedAnswers.any((accepted) =>
          _cleanTextForGrading(typed) == _cleanTextForGrading(accepted));
      correctAnswerText = correct;
      userAnswerText = typed;
      submittedAnswer = typed;
    } else if (q.questionKind == 'reorder' ||
        q.questionKind == 'translation' && _assembledWords.isNotEmpty) {
      final assembled = _assembledWords.join(' ').trim();
      final correct = q.mcqCorrectAnswer.trim();

      isCorrect = q.acceptedAnswers.any((accepted) =>
          _cleanTextForGrading(assembled) == _cleanTextForGrading(accepted));
      correctAnswerText = correct;
      userAnswerText = assembled;
      submittedAnswer = assembled;
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
      submittedAnswer = Map<String, String>.from(_matches);
    } else if (q.questionKind == 'speech_record') {
      isCorrect = _pronunciationScore >= 80.0;
      correctAnswerText = q.mcqCorrectAnswer;
      userAnswerText = 'Pronunciation Score: ${_pronunciationScore.toInt()}%';
      submittedAnswer = _pronunciationScore;
    }

    _answers.add(
      AnswerPayload(
        questionId: q.id,
        answer: submittedAnswer ?? userAnswerText,
        isCorrect: isCorrect,
      ),
    );

    var shouldSpendHeart = false;
    setState(() {
      _state = isCorrect ? _AnswerState.correct : _AnswerState.wrong;
      if (isCorrect) {
        _correctCount++;
      } else if (_hearts > 0) {
        _hearts--;
        shouldSpendHeart = true;
      }
    });

    if (shouldSpendHeart) {
      final write = _syncWrongAnswerHeart();
      _pendingHeartWrites.add(write);
      write.whenComplete(() => _pendingHeartWrites.remove(write));
    }

    if (context.read<AuthProvider>().user?.soundEnabled ?? true) {
      SoundEffectService.instance.play(
        isCorrect ? SoundEffect.correct : SoundEffect.wrong,
      );
    }
    _showResultSheet(isCorrect, correctAnswerText, userAnswerText);
  }

  void _showResultSheet(
    bool correct,
    String correctAnswer,
    String userAnswerText,
  ) {
    _resultSheetOpen = true;

    final String cleanUser = _cleanTextForGrading(userAnswerText);
    final String cleanCorrect = _cleanTextForGrading(correctAnswer);
    final bool exactMatch =
        userAnswerText.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    final bool hasMissingAccents =
        correct && !exactMatch && cleanUser == cleanCorrect && userAnswerText.trim().isNotEmpty;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        var sheetSubmitting = false;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: correct
                  ? FluentianColors.successTint
                  : FluentianColors.errorTint,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
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
                if (correct && hasMissingAccents) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.info_circle5,
                          color: Color(0xFFD97706),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LText(
                            'Pay attention to the accents:\n$correctAnswer',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (!correct) ...[
                  Row(
                    children: [
                      const Icon(
                        Iconsax.heart5,
                        color: FluentianColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      LText(
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
                          Iconsax.tick_circle,
                          color: FluentianColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LText(
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
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        final q = _activeQuestions[_currentIndex];
                        AiTutorSheet.show(
                          context,
                          systemContext:
                              'Target language: French. The learner explanation language is ${AppLocaleController.activeLanguageName}. You are a helpful French tutor. The user answered a French lesson question incorrectly. Question: "${q.promptPayload['question'] ?? q.promptPayload['text']}". Learner answer: "$userAnswerText". Correct answer: "$correctAnswer". Explain the specific difference simply in ${AppLocaleController.activeLanguageName}, using French examples when useful.',
                          initialPrompt:
                              'Why was my answer "$userAnswerText" incorrect? Please explain how it differs from "$correctAnswer".',
                        );
                      },
                      icon: const Icon(
                        Iconsax.message5,
                        color: FluentianColors.primary,
                      ),
                      label: const LText(
                        'Ask AI why',
                        style: TextStyle(
                          color: FluentianColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: FluentianColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: sheetSubmitting
                        ? null
                        : () {
                            // Local sheet state so the button visually disables
                            // immediately -- this route doesn't repaint just
                            // because _McqScreenState rebuilds. The actual
                            // double-submit guard lives in _onNext itself.
                            setSheetState(() => sheetSubmitting = true);
                            _onNext(correct);
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
                    child: sheetSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : LText(correct ? 'Continue' : 'Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() => _resultSheetOpen = false);
  }

  Future<void> _onNext(bool correct) async {
    // Guards the actual double-submission bug: the result sheet below is a
    // disconnected subtree from this State's build (it's a separate
    // ModalBottomSheetRoute), so its Continue button's disabled/spinner look
    // doesn't reliably repaint the instant _isSubmitting flips. A fast
    // double-tap can invoke this twice concurrently before either paints --
    // each call would hit the backend with its own idempotency key, so the
    // server can't dedupe it either, resulting in double XP/heart writes.
    if (_isSubmitting) return;
    final questions = _activeQuestions;
    if (_currentIndex < questions.length - 1) {
      if (_resultSheetOpen)
        Navigator.pop(context); // close sheet, if still open
      setState(() {
        _currentIndex++;
        _state = _AnswerState.unanswered;
      });
      _initQuestion();
    } else {
      setState(() => _isSubmitting = true);

      final contentProvider = context.read<ContentProvider>();
      final authProvider = context.read<AuthProvider>();
      final navigator = Navigator.of(context);
      final score = questions.isEmpty ? 1.0 : _correctCount / questions.length;
      final timeSeconds = DateTime.now().difference(_startTime).inSeconds;
      await Future.wait(List<Future<void>>.from(_pendingHeartWrites));

      int finalXpEarned = widget.xpReward;
      int? finalNewXpTotal;
      int? finalHeartsRemaining;
      int? finalStreakDays;
      bool streakFreezeEarned = false;

      try {
        if (widget.isSrsReview) {
          final result = await contentProvider.completeSrsReview(
            answers: _answers,
            timeSeconds: timeSeconds,
          );
          if (result != null) {
            finalXpEarned = result['xp_earned'] as int? ?? 0;
            finalNewXpTotal = result['new_xp_total'] as int? ?? 0;
            finalHeartsRemaining = result['hearts_remaining'] as int?;
            finalStreakDays = result['streak_days'] as int?;
          }
        } else {
          final result = await contentProvider.completeLesson(
            lessonId: widget.lessonId,
            score: score,
            answers: _answers,
            timeSeconds: timeSeconds,
            heartsSpent: _persistedHeartSpends,
          );
          if (result != null) {
            finalXpEarned = result.xpEarned;
            finalNewXpTotal = result.newXpTotal;
            finalHeartsRemaining = result.heartsRemaining;
            finalStreakDays = result.streakDays;
            streakFreezeEarned = result.streakFreezeEarned;
          }
        }
      } on ApiException catch (e) {
        // The server actually rejected the completion (not just offline) --
        // don't celebrate a completion that didn't happen. Let the learner
        // retry instead of silently reverting the next time they open the app.
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.userMessage)));
        return;
      } on NetworkException catch (e) {
        // Lesson completion is queued offline by OutboxManager (safe to
        // proceed to the completion screen), but SRS review has no offline
        // queue -- a network failure there means the review truly wasn't
        // recorded, so don't celebrate it either.
        if (widget.isSrsReview) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
          return;
        }
      }

      if (!mounted) return;
      authProvider.updateUserStats(
        hearts: finalHeartsRemaining,
        xpTotal: finalNewXpTotal,
        streakDays: finalStreakDays,
      );
      await authProvider.refreshHearts();
      if (_resultSheetOpen) navigator.pop(); // close sheet, if still open
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonCompleteScreen(
            lessonId: widget.lessonId,
            xpEarned: finalXpEarned,
            newXpTotal: finalNewXpTotal ?? 0,
            accuracy: score,
            timeSeconds: timeSeconds,
            correctCount: _correctCount,
            totalQuestions: questions.length,
            streakDays: finalStreakDays,
            streakFreezeEarned: streakFreezeEarned,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = _activeQuestions;
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: LText("No questions found.")));
    }

    final progress = (_currentIndex) / questions.length;
    final q = _currentQ;
    final auth = context.watch<AuthProvider>();

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
                      Iconsax.close_circle,
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
                  HeartStatusChip(
                    hearts: _hearts,
                    maxHearts: auth.maxHearts,
                    nextRefillAt: auth.nextHeartRefillAt,
                    compact: true,
                    onRefreshDue: () {
                      _refreshPersistentHearts();
                    },
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
                    if (_isWordAssembly(q))
                      _buildWordAssemblyHeader(q)
                    else ...[
                      LText(
                        q.questionKind.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LText(
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
                    ],
                    const SizedBox(height: 16),
                    _buildQuizHud(),
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
                              Iconsax.gallery_slash,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Render dynamic audio if present -- word-assembly
                    // exercises get a compact inline speaker icon next to
                    // the sentence instead (see _buildWordAssemblyHeader),
                    // so this full-width block is skipped for that kind.
                    if (!_isWordAssembly(q) &&
                        ((q.audioUrl != null && q.audioUrl!.isNotEmpty) ||
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
                                            ? Iconsax.pause
                                            : Iconsax.play,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            LText(
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
                text: _hearts <= 0 ? 'Hearts refilling' : 'Check',
                onPressed: _hearts <= 0
                    ? () => _showOutOfHeartsSheet()
                    : _isCheckEnabled() && _state == _AnswerState.unanswered
                    ? _check
                    : null,
                backgroundColor: _hearts <= 0 || _isCheckEnabled()
                    ? FluentianColors.primary
                    : Colors.grey.shade300,
                textColor: _hearts <= 0 || _isCheckEnabled()
                    ? Colors.white
                    : Colors.grey,
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

  Widget _buildQuizHud() {
    final current = _currentIndex + 1;
    final total = _activeQuestions.length;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _QuizHudChip(
          icon: Iconsax.task_square,
          label: '$current of $total',
          color: FluentianColors.primary,
          bgColor: FluentianColors.primaryTint,
        ),
        _QuizHudChip(
          icon: Iconsax.flash_15,
          label: '${widget.xpReward} XP',
          color: FluentianColors.success,
          bgColor: FluentianColors.successTint,
        ),
        _QuizHudChip(
          icon: Iconsax.teacher,
          label: widget.isSrsReview ? 'Review' : 'Lesson quiz',
          color: FluentianColors.textSecondary,
          bgColor: FluentianColors.infoTint,
        ),
      ],
    );
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

        return FluentianPressable(
          onTap: _state == _AnswerState.unanswered
              ? () => setState(() => _selected = i)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? FluentianColors.primary
                        : Colors.grey.shade100,
                  ),
                  child: Center(
                    child: LText(
                      String.fromCharCode(65 + i),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : FluentianColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LText(
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

        return FluentianPressable(
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
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
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
                  isSelected ? Iconsax.tick_square : Iconsax.tick_square,
                  color: isSelected
                      ? FluentianColors.primary
                      : FluentianColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LText(
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
          child: LText(
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
              label: LText(
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

  /// Reorder/translation questions ("assemble the words into a sentence")
  /// get a compact custom header (static "Translate this sentence" title +
  /// inline audio icon) instead of the generic kicker+title+audio block
  /// shared by other question kinds.
  bool _isWordAssembly(QuestionModel q) =>
      q.questionKind == 'reorder' || q.questionKind == 'translation';

  Widget _buildWordAssemblyHeader(QuestionModel q) {
    final hasAudio =
        (q.audioUrl != null && q.audioUrl!.isNotEmpty) ||
        (q.ttsEnabled && q.textToSpeak.trim().isNotEmpty);
    return Column(
      children: [
        LText(
          'Translate this sentence',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: FluentianColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasAudio) ...[
              GestureDetector(
                onTap: _toggleAudio,
                child: Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: FluentianColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _audioLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _audioPlaying ? Iconsax.pause : Iconsax.play,
                          color: Colors.white,
                          size: 16,
                        ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: LText(
                q.promptText.isNotEmpty
                    ? q.promptText
                    : 'Follow the prompt below:',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWordAssembly() {
    // Word bank starts as a shuffle of every word the correct answer needs
    // (see _initQuestion), so its size never changes -- assembled + bank
    // is always the total number of word positions in the sentence. That
    // lets the answer area render one slot per position up front (filled
    // ones show the placed word, the rest are empty placeholders) instead
    // of only appearing once a word lands in them.
    final totalSlots = _assembledWords.length + _remainingScrambled.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FluentianColors.pageBg,
            borderRadius: BorderRadius.circular(FluentianRadius.large),
            border: Border.all(color: FluentianColors.border),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(totalSlots, (idx) {
              if (idx < _assembledWords.length) {
                final word = _assembledWords[idx];
                return _WordTile(
                  key: ValueKey('placed-$idx-$word'),
                  word: word,
                  placed: true,
                  onTap: _state == _AnswerState.unanswered
                      ? () {
                          setState(() {
                            _assembledWords.removeAt(idx);
                            _remainingScrambled.add(word);
                          });
                        }
                      : null,
                );
              }
              return const _EmptyWordSlot();
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
            return _WordTile(
              key: ValueKey('bank-$idx-$word'),
              word: word,
              placed: false,
              onTap: _state == _AnswerState.unanswered
                  ? () {
                      setState(() {
                        _remainingScrambled.removeAt(idx);
                        _assembledWords.add(word);
                      });
                    }
                  : null,
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
            hintText: context.tr('Write your answer in French'),
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
                          color: FluentianColors.primary.withValues(alpha: 0.1),
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
                          LText(
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
                          child: LText(
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
                if (isMatched) {
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
                          color: FluentianColors.primary.withValues(alpha: 0.1),
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
                          LText(
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
                          child: LText(
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
        LText(
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
                          _audioPlaying ? Iconsax.pause : Iconsax.volume_high,
                          color: FluentianColors.primary,
                          size: 20,
                        ),
                  const SizedBox(width: 8),
                  LText(
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
                            isRecording ? Iconsax.stop : Iconsax.microphone_2,
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
            LText(
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
                      Iconsax.star5,
                      color: FluentianColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    LText(
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
            child: LText(
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
          LText(
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

/// A single word-bank/answer-area tile for the word-assembly exercise.
/// `placed` switches between the two visual states (in the answer area
/// vs. still in the word bank); a light scale-down on press gives the
/// tactile "liftable tile" feel the interaction calls for even though the
/// actual move happens on tap release, not a drag gesture.
class _WordTile extends StatefulWidget {
  final String word;
  final bool placed;
  final VoidCallback? onTap;

  const _WordTile({
    super.key,
    required this.word,
    required this.placed,
    required this.onTap,
  });

  @override
  State<_WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<_WordTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: widget.placed
                ? FluentianColors.primary
                : FluentianColors.white,
            borderRadius: BorderRadius.circular(FluentianRadius.medium),
            border: Border.all(
              color: widget.placed
                  ? FluentianColors.primary
                  : FluentianColors.border,
              width: 1.3,
            ),
            boxShadow: [
              widget.placed ? FluentianShadows.subtle : FluentianShadows.card,
            ],
          ),
          child: LText(
            widget.word,
            style: GoogleFonts.inter(
              color: widget.placed ? Colors.white : FluentianColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// An unfilled position in the answer-construction area -- deliberately
/// text-less and understated so it reads as "a slot waiting for a word",
/// not as a text input field.
class _EmptyWordSlot extends StatelessWidget {
  const _EmptyWordSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 40,
      decoration: BoxDecoration(
        color: FluentianColors.white,
        borderRadius: BorderRadius.circular(FluentianRadius.medium),
        border: Border.all(color: FluentianColors.border, width: 1.3),
      ),
    );
  }
}

class _QuizHudChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _QuizHudChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          LText(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
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

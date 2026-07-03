import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../services/tts_service.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/ai_tutor_sheet.dart';
import 'mcq_screen.dart';
import 'lesson_complete_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final String lessonId;

  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  bool _isLoading = true;
  LessonDetailModel? _lesson;
  late final AudioPlayer _audioPlayer;
  final ScrollController _scrollController = ScrollController();
  final TtsService _ttsService = TtsService.instance;
  double _readProgress = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _scrollController.addListener(_updateReadProgress);
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    final detail = await context.read<ContentProvider>().getLessonDetail(
      widget.lessonId,
    );
    if (mounted) {
      setState(() {
        _lesson = detail;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _updateReadProgress() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final next = max <= 0
        ? 1.0
        : (_scrollController.offset / max).clamp(0.0, 1.0);
    if ((next - _readProgress).abs() > 0.01) {
      setState(() => _readProgress = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: FluentianColors.pageBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_lesson == null) {
      return Scaffold(
        backgroundColor: FluentianColors.pageBg,
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load lesson.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadLesson();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Sort blocks by sequence_no
    final blocks = List<BlockModel>.from(_lesson!.blocks)
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));

    final speakingEnabled =
        context.watch<AuthProvider>().user?.speakingExercisesEnabled ?? true;
    final quizQuestions = speakingEnabled
        ? _lesson!.questions
        : _lesson!.questions
              .where((q) => q.questionKind != 'speech_record')
              .toList();
    final estimatedMinutes = (blocks.length * 1.4 + quizQuestions.length * 0.5)
        .ceil()
        .clamp(2, 18);

    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: FluentianColors.textPrimary),
        title: Text(
          _lesson!.title,
          style: GoogleFonts.inter(
            color: FluentianColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: blocks.isEmpty ? 1 : _readProgress,
            minHeight: 3,
            backgroundColor: FluentianColors.primaryTint,
            valueColor: const AlwaysStoppedAnimation(FluentianColors.primary),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: blocks.isEmpty
                      ? Center(child: _buildQuizOnlyCard())
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                          itemCount: blocks.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildLessonHero(
                                blockCount: blocks.length,
                                questionCount: quizQuestions.length,
                                estimatedMinutes: estimatedMinutes,
                              );
                            }
                            return _buildBlock(blocks[index - 1]);
                          },
                        ),
                ),
                _buildBottomActionBar(quizQuestions),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 88,
              child: FloatingActionButton(
                backgroundColor: FluentianColors.primary,
                onPressed: () {
                  AiTutorSheet.show(
                    context,
                    systemContext: _aiLessonContext(),
                    initialPrompt:
                        'Summarize this French lesson and tell me what I will learn.',
                  );
                },
                child: const Icon(Iconsax.message5, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonHero({
    required int blockCount,
    required int questionCount,
    required int estimatedMinutes,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A2E), Color(0xFF4E22D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [FluentianShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Iconsax.book_1,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lesson path',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _lesson!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroMetric(
                icon: Iconsax.flash_15,
                label: '${_lesson!.xpReward} XP',
              ),
              const SizedBox(width: 8),
              _HeroMetric(icon: Iconsax.clock, label: '$estimatedMinutes min'),
              const SizedBox(width: 8),
              _HeroMetric(
                icon: Iconsax.task_square,
                label: '$questionCount quiz',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: blockCount == 0 ? 0 : 0.18,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Read, listen, ask AI, then prove it in the quiz.',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizOnlyCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: FluentianColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.book_1,
              color: FluentianColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Quiz-Only Session',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This lesson is an assessment designed to test your skills directly without preparatory reading material.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: FluentianColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(List<QuestionModel> quizQuestions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () async {
            if (quizQuestions.isEmpty) {
              setState(() => _isLoading = true);
              final result = await context
                  .read<ContentProvider>()
                  .completeLesson(
                    lessonId: _lesson!.id,
                    score: 1.0,
                    answers: [],
                    timeSeconds: 5,
                  );
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LessonCompleteScreen(
                    lessonId: _lesson!.id,
                    xpEarned: result?.xpEarned ?? _lesson!.xpReward,
                    newXpTotal: result?.newXpTotal ?? 0,
                    accuracy: 1.0,
                    timeSeconds: 5,
                    correctCount: 0,
                    totalQuestions: 0,
                  ),
                ),
              );
              return;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => McqScreen(
                  lessonId: _lesson!.id,
                  questions: quizQuestions,
                  xpReward: _lesson!.xpReward,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: FluentianColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                quizQuestions.isEmpty
                    ? Iconsax.tick_circle
                    : Iconsax.arrow_right_3,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                quizQuestions.isEmpty ? 'Complete Lesson' : 'Continue to Quiz',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _aiLessonContext({String? focus}) {
    final lesson = _lesson;
    if (lesson == null) {
      return [
        'Target language: French.',
        'Base explanation language: English.',
        if (focus != null) 'Current focus: $focus',
      ].join('\n');
    }

    final blockSummaries = lesson.blocks.take(8).map((block) {
      final payload = block.blockPayload;
      final text = payload['text'] ??
          payload['word'] ??
          payload['target'] ??
          payload['base'] ??
          payload['meaning'] ??
          payload['source'] ??
          payload['en'] ??
          '';
      return '- ${block.blockKind}: ${text.toString()}';
    }).where((line) => line.trim().length > 3);

    final questionSummaries = lesson.questions.take(5).map((q) {
      final prompt = q.promptPayload['question'] ??
          q.promptPayload['text'] ??
          q.promptPayload['prompt'] ??
          '';
      return '- ${prompt.toString()}';
    }).where((line) => line.trim().length > 2);

    return [
      'Target language: French.',
      'Base explanation language: English.',
      'Lesson title: ${lesson.title}',
      'Lesson kind: ${lesson.lessonKind}',
      'Lesson XP: ${lesson.xpReward}',
      if (focus != null) 'Current focus: $focus',
      if (blockSummaries.isNotEmpty) 'Lesson content:\n${blockSummaries.join('\n')}',
      if (questionSummaries.isNotEmpty)
        'Existing lesson questions:\n${questionSummaries.join('\n')}',
      'Tutor behavior: explain French clearly, use lesson vocabulary, and make quizzes about this French lesson only.',
    ].join('\n');
  }

  Widget _buildBlock(BlockModel block) {
    switch (block.blockKind) {
      case 'explanation':
      case 'text':
      case 'rich_text':
        final text =
            block.blockPayload['content']?.toString() ??
            block.blockPayload['text']?.toString() ??
            '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [FluentianShadows.subtle],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: FluentianColors.textPrimary,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (block.ttsEnabled &&
                    block.textToSpeak.trim().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        tooltip: 'Listen',
                        icon: const Icon(
                          Iconsax.volume_high,
                          color: FluentianColors.primary,
                        ),
                        onPressed: () => _speakBlock(block),
                      ),
                      IconButton(
                        tooltip: 'Ask AI',
                        icon: const Icon(
                          Iconsax.message5,
                          color: FluentianColors.primary,
                        ),
                        onPressed: () {
                          AiTutorSheet.show(
                            context,
                            systemContext: _aiLessonContext(
                              focus:
                                  'Explain this French lesson text or phrase clearly: "$text"',
                            ),
                            initialPrompt:
                                'Can you explain this French phrase to me: "$text"?',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      case 'vocabulary':
        final word = block.blockPayload['word']?.toString() ?? '';
        final meaning = block.blockPayload['meaning']?.toString() ?? '';
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [FluentianShadows.subtle],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meaning,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: FluentianColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Iconsax.volume_high,
                      color: FluentianColors.primary,
                    ),
                    onPressed: () => _playBlockAudioOrTts(block),
                  ),
                  IconButton(
                    icon: const Icon(
                      Iconsax.message5,
                      color: FluentianColors.primary,
                    ),
                    onPressed: () {
                      AiTutorSheet.show(
                        context,
                        systemContext: _aiLessonContext(
                          focus:
                              'Explain the French vocabulary word "$word" which means "$meaning". Give a French example sentence with an English explanation.',
                        ),
                        initialPrompt:
                            'Can you give me a French example sentence for the word "$word"?',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      case 'sentence_pair':
        final base =
            block.blockPayload['base']?.toString() ??
            block.blockPayload['source']?.toString() ??
            block.blockPayload['en']?.toString() ??
            '';
        final target = block.blockPayload['target']?.toString() ?? '';
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFFAF9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FluentianColors.primary.withValues(alpha: 0.1),
            ),
            boxShadow: [FluentianShadows.subtle],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 2,
                      color: FluentianColors.primary.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      base,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: FluentianColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (block.ttsEnabled && block.textToSpeak.trim().isNotEmpty)
                IconButton(
                  tooltip: 'Listen',
                  icon: const Icon(
                    Iconsax.volume_high,
                    color: FluentianColors.primary,
                  ),
                  onPressed: () => _speakBlock(block),
                )
              else
                const Icon(
                  Iconsax.translate,
                  color: FluentianColors.primary,
                  size: 22,
                ),
            ],
          ),
        );
      case 'grammar_note':
        final rule =
            block.blockPayload['rule']?.toString() ??
            block.blockPayload['content']?.toString() ??
            block.blockPayload['text']?.toString() ??
            '';
        final example =
            block.blockPayload['example']?.toString() ??
            _firstGrammarExample(block) ??
            '';
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FluentianColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Iconsax.book_1,
                    color: FluentianColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GRAMMAR RULE',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: FluentianColors.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                rule,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.textPrimary,
                  height: 1.4,
                ),
              ),
              if (block.ttsEnabled && block.textToSpeak.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _speakBlock(block),
                    icon: const Icon(Iconsax.volume_high, size: 18),
                    label: const Text('Listen'),
                    style: TextButton.styleFrom(
                      foregroundColor: FluentianColors.primary,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
              if (example.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXAMPLE',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        example,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      case 'ai_hint':
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _playBlockAudioOrTts(BlockModel block) async {
    final audioUrl = block.audioUrl;
    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        await _ttsService.stop();
        await _audioPlayer.setUrl(audioUrl);
        _audioPlayer.play();
        return;
      } catch (e) {
        debugPrint('Lesson audio playback error: $audioUrl $e');
      }
    }

    await _speakBlock(block);
  }

  Future<void> _speakBlock(BlockModel block) async {
    try {
      final ttsSpeed = context.read<AuthProvider>().user?.ttsSpeed ?? 1.0;
      await _audioPlayer.stop();
      await _ttsService.speak(
        block.textToSpeak,
        language: block.ttsLanguage,
        speed: ttsSpeed,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not play audio')));
      }
    }
  }

  String? _firstGrammarExample(BlockModel block) {
    final examples = block.blockPayload['examples'];
    if (examples is List && examples.isNotEmpty) {
      final first = examples.first;
      if (first is Map) {
        final fr = first['fr']?.toString();
        final en = first['en']?.toString();
        if (fr != null && fr.trim().isNotEmpty) {
          return en != null && en.trim().isNotEmpty ? '$fr\n$en' : fr;
        }
      }
      return first.toString();
    }
    return null;
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

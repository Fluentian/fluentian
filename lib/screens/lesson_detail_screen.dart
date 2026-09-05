import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../services/media_cache_manager.dart';
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
  String? _loadError;
  late final AudioPlayer _audioPlayer;
  final TtsService _ttsService = TtsService.instance;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    final contentProvider = context.read<ContentProvider>();
    final detail = await contentProvider.getLessonDetail(widget.lessonId);
    if (mounted) {
      setState(() {
        _lesson = detail;
        _loadError = detail == null ? contentProvider.lastLessonLoadError : null;
        _isLoading = false;
      });

      if (detail != null && detail.blocks.isNotEmpty) {
        final textsToWarm = detail.blocks
            .take(5)
            .map((b) => b.textToSpeak.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        _ttsService.prefetch(textsToWarm);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _ttsService.stop();
    super.dispose();
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
        appBar: AppBar(title: const LText('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_loadError ?? context.tr('Failed to load lesson.')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadLesson();
                },
                child: const LText('Retry'),
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
        title: LText(
          _lesson!.title,
          style: GoogleFonts.ibmPlexSans(
            color: FluentianColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: blocks.isEmpty
                ? 1
                : ((_currentStep + 1) / (blocks.length + 1)).clamp(0, 1),
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
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final horizontalPadding = constraints.maxWidth > 700
                                ? (constraints.maxWidth - 640) / 2
                                : 16.0;
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position:
                                          Tween<Offset>(
                                            begin: const Offset(0.04, 0),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          ),
                                      child: child,
                                    ),
                                  ),
                              child: SingleChildScrollView(
                                key: ValueKey(_currentStep),
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  20,
                                  horizontalPadding,
                                  108,
                                ),
                                child: _currentStep == 0
                                    ? _buildLessonHero(
                                        blockCount: blocks.length,
                                        questionCount: quizQuestions.length,
                                        estimatedMinutes: estimatedMinutes,
                                      )
                                    : _buildFocusedStep(
                                        blocks[_currentStep - 1],
                                        step: _currentStep,
                                        total: blocks.length,
                                      ),
                              ),
                            );
                          },
                        ),
                ),
                _buildBottomActionBar(quizQuestions, blocks.length),
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
      decoration: const BoxDecoration(
        color: FluentianColors.primary,
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
                  borderRadius: BorderRadius.circular(0),
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
                    LText(
                      'Lesson path',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 2),
                    LText(
                      _lesson!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ibmPlexSans(
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
            borderRadius: BorderRadius.circular(0),
            child: LinearProgressIndicator(
              value: blockCount == 0 ? 0 : 0.18,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          LText(
            'Read, listen, ask AI, then prove it in the quiz.',
            style: GoogleFonts.ibmPlexSans(
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
        borderRadius: BorderRadius.circular(0),
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
          LText(
            'Quiz-Only Session',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          LText(
            'This lesson is an assessment designed to test your skills directly without preparatory reading material.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 14,
              color: FluentianColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    List<QuestionModel> quizQuestions,
    int blockCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          FluentianShadows.subtle,
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            SizedBox(
              width: 54,
              height: 54,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  side: const BorderSide(color: FluentianColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Icon(
                  Iconsax.arrow_left_2,
                  color: FluentianColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentStep < blockCount) {
                    setState(() => _currentStep++);
                    return;
                  }
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
                          completionPendingSync: result == null,
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
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _currentStep < blockCount
                          ? Iconsax.arrow_right_3
                          : quizQuestions.isEmpty
                          ? Iconsax.tick_circle
                          : Iconsax.arrow_right_3,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    LText(
                      _currentStep < blockCount
                          ? (_currentStep == 0 ? 'Start Lesson' : 'Next Lesson')
                          : quizQuestions.isEmpty
                          ? 'Complete Lesson'
                          : 'Continue to Quiz',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusedStep(
    BlockModel block, {
    required int step,
    required int total,
  }) {
    final presentation = _blockPresentation(block.blockKind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: FluentianColors.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: LText(
                'STEP $step OF $total',
                style: FluentianTheme.label(size: 10, color: FluentianColors.primary),
              ),
            ),
            const Spacer(),
            LText(
              '${((step / total) * 100).round()}%',
              style: GoogleFonts.ibmPlexSans(
                color: FluentianColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: presentation.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Icon(
                presentation.icon,
                color: presentation.color,
                size: 23,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LText(
                    presentation.title,
                    style: GoogleFonts.ibmPlexSans(
                      color: FluentianColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  LText(
                    presentation.instruction,
                    style: GoogleFonts.ibmPlexSans(
                      color: FluentianColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildBlock(block),
        const SizedBox(height: 6),
        LText(
          step == total
              ? 'Great work — the quiz is next.'
              : 'Take your time. Continue when this feels clear.',
          textAlign: TextAlign.center,
          style: GoogleFonts.ibmPlexSans(
            color: FluentianColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  _BlockPresentation _blockPresentation(String kind) {
    switch (kind) {
      case 'vocabulary':
        return const _BlockPresentation(
          title: 'Build your vocabulary',
          instruction: 'Listen, repeat, and connect the word to its meaning.',
          icon: Iconsax.translate,
          color: FluentianColors.primary,
        );
      case 'sentence_pair':
        return const _BlockPresentation(
          title: 'Learn the phrase',
          instruction: 'Read the French first, then compare the meaning.',
          icon: Iconsax.message_text,
          color: FluentianColors.info,
        );
      case 'grammar_note':
        return const _BlockPresentation(
          title: 'Understand the pattern',
          instruction: 'Focus on the rule and see how it works in context.',
          icon: Iconsax.book_1,
          color: FluentianColors.accent,
        );
      default:
        return const _BlockPresentation(
          title: 'Explore the concept',
          instruction: 'Read this idea carefully before moving forward.',
          icon: Iconsax.note_1,
          color: FluentianColors.primary,
        );
    }
  }

  String _aiLessonContext({String? focus}) {
    final lesson = _lesson;
    if (lesson == null) {
      return [
        'Target language: French.',
        'Base explanation language: ${AppLocaleController.activeLanguageName}.',
        if (focus != null) 'Current focus: $focus',
      ].join('\n');
    }

    final blockSummaries = lesson.blocks
        .take(8)
        .map((block) {
          final payload = block.blockPayload;
          final text =
              payload['text'] ??
              payload['word'] ??
              payload['target'] ??
              payload['base'] ??
              payload['meaning'] ??
              payload['source'] ??
              payload['en'] ??
              '';
          return '- ${block.blockKind}: ${text.toString()}';
        })
        .where((line) => line.trim().length > 3);

    final questionSummaries = lesson.questions
        .take(5)
        .map((q) {
          final prompt =
              q.promptPayload['question'] ??
              q.promptPayload['text'] ??
              q.promptPayload['prompt'] ??
              '';
          return '- ${prompt.toString()}';
        })
        .where((line) => line.trim().length > 2);

    return [
      'Target language: French.',
      'Base explanation language: ${AppLocaleController.activeLanguageName}.',
      'Lesson title: ${lesson.title}',
      'Lesson kind: ${lesson.lessonKind}',
      'Lesson XP: ${lesson.xpReward}',
      if (focus != null) 'Current focus: $focus',
      if (blockSummaries.isNotEmpty)
        'Lesson content:\n${blockSummaries.join('\n')}',
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
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [FluentianShadows.subtle],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LText(
                    text,
                    style: GoogleFonts.ibmPlexSans(
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
                        tooltip: context.tr('Listen'),
                        icon: const Icon(
                          Iconsax.volume_high,
                          color: FluentianColors.primary,
                        ),
                        onPressed: () => _speakBlock(block),
                      ),
                      IconButton(
                        tooltip: context.tr('Ask AI'),
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
        final phonetic =
            block.blockPayload['phonetic']?.toString() ??
            block.blockPayload['ipa']?.toString() ??
            block.blockPayload['pronunciation']?.toString() ??
            '';
        final showPhonetic =
            context.watch<AuthProvider>().user?.phoneticHintsEnabled ?? true;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [FluentianShadows.subtle],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      word,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    if (showPhonetic && phonetic.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      LText(
                        phonetic,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: FluentianColors.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    LText(
                      meaning,
                      style: GoogleFonts.ibmPlexSans(
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
                              'Explain the French vocabulary word "$word" which means "$meaning". Give a French example sentence with an explanation in ${AppLocaleController.activeLanguageName}.',
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
      case 'translation':
      case 'translation_pair':
      case 'translation_block':
      case 'phrase_pair':
        final base =
            block.blockPayload['base']?.toString() ??
            block.blockPayload['source']?.toString() ??
            block.blockPayload['en']?.toString() ??
            block.blockPayload['translation']?.toString() ??
            block.blockPayload['meaning']?.toString() ??
            block.blockPayload['am']?.toString() ??
            block.blockPayload['explanation']?.toString() ??
            '';
        final target =
            block.blockPayload['target']?.toString() ??
            block.blockPayload['french']?.toString() ??
            block.blockPayload['fr']?.toString() ??
            block.blockPayload['sentence']?.toString() ??
            block.blockPayload['phrase']?.toString() ??
            block.blockPayload['expression']?.toString() ??
            block.blockPayload['text']?.toString() ??
            '';
        final textToSpeak = block.textToSpeak.trim().isNotEmpty
            ? block.textToSpeak
            : target;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: FluentianColors.cardBg,
            border: Border.fromBorderSide(FluentianBorders.hairline),
            boxShadow: [FluentianShadows.subtle],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      target.isNotEmpty ? target : textToSpeak,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.primary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (base.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 32,
                        height: 2,
                        color: FluentianColors.primary.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 8),
                      LText(
                        base,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          color: FluentianColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: context.tr('Listen'),
                    icon: const Icon(
                      Iconsax.volume_high,
                      color: FluentianColors.primary,
                    ),
                    onPressed: () => _speakText(
                      textToSpeak.isNotEmpty ? textToSpeak : target,
                      language: block.ttsLanguage,
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Ask AI'),
                    icon: const Icon(
                      Iconsax.message5,
                      color: FluentianColors.primary,
                    ),
                    onPressed: () {
                      AiTutorSheet.show(
                        context,
                        systemContext: _aiLessonContext(
                          focus:
                              'Explain the French sentence or phrase "$target" ($base). Break down its grammar and vocabulary.',
                        ),
                        initialPrompt:
                            'Can you explain the French sentence "$target" and how to use it in conversation?',
                      );
                    },
                  ),
                ],
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
            color: FluentianColors.primaryTint,
            borderRadius: BorderRadius.circular(0),
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
                  LText(
                    'GRAMMAR RULE',
                    style: FluentianTheme.label(color: FluentianColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LText(
                rule,
                style: GoogleFonts.ibmPlexSans(
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
                    label: const LText('Listen'),
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
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LText(
                              'EXAMPLE',
                              style: FluentianTheme.label(size: 9, color: FluentianColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            LText(
                              example,
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: FluentianColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: context.tr('Listen'),
                        icon: const Icon(
                          Iconsax.volume_high,
                          size: 18,
                          color: FluentianColors.primary,
                        ),
                        onPressed: () {
                          final frenchPart = example.split('\n').first;
                          _speakText(frenchPart);
                        },
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
        await MediaCacheManager.instance.loadIntoPlayer(_audioPlayer, audioUrl);
        _audioPlayer.play();
        return;
      } catch (e) {
        debugPrint('Lesson audio playback error: $audioUrl $e');
      }
    }

    await _speakBlock(block);
  }

  Future<void> _speakBlock(BlockModel block) async {
    await _speakText(block.textToSpeak, language: block.ttsLanguage);
  }

  Future<void> _speakText(String text, {String language = 'fr-FR'}) async {
    if (text.trim().isEmpty) return;
    try {
      // The voice the learner picked in Settings was saved but never passed
      // here, so every word played in the default voice regardless.
      final settingsUser = context.read<AuthProvider>().user;
      final ttsSpeed = settingsUser?.ttsSpeed ?? 1.0;
      await _audioPlayer.stop();
      await _ttsService.speak(
        text,
        language: language,
        speed: ttsSpeed,
        voiceId: settingsUser?.preferredVoiceId ?? 'claire',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: LText('Could not play audio')));
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
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: LText(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ibmPlexSans(
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

class _BlockPresentation {
  final String title;
  final String instruction;
  final IconData icon;
  final Color color;

  const _BlockPresentation({
    required this.title,
    required this.instruction,
    required this.icon,
    required this.color,
  });
}

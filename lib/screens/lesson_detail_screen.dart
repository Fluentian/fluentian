import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
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
  final TtsService _ttsService = TtsService.instance;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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

    final quizQuestions = _lesson!.questions
        .where((q) => q.questionKind != 'speech_record')
        .toList();

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
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: blocks.isEmpty
                      ? Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.05),
                          ),
                          boxShadow: [FluentianShadows.subtle],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: FluentianColors.primary.withValues(
                                  alpha: 0.1,
                                ),
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
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: blocks.length,
                      itemBuilder: (context, index) {
                        return _buildBlock(blocks[index]);
                      },
                    ),
            ),
            Container(
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
                      final result = await context.read<ContentProvider>().completeLesson(
                        lessonId: _lesson!.id,
                        score: 1.0,
                        answers: [],
                        timeSeconds: 5,
                      );
                      if (mounted) {
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
                      }
                    } else {
                      // Navigate to MCQ flow with the questions
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
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FluentianColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    quizQuestions.isEmpty
                        ? 'Complete Lesson'
                        : 'Continue to Quiz',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 80,
            child: FloatingActionButton(
              backgroundColor: FluentianColors.primary,
              onPressed: () {
                AiTutorSheet.show(
                  context,
                  systemContext: 'You are a helpful language tutor. Help the user summarize the lesson "${_lesson!.title}". Keep the response short and friendly.',
                  initialPrompt: 'Can you summarize this lesson and tell me what I will learn?',
                );
              },
              child: const Icon(Icons.psychology_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
                          Icons.volume_up_rounded,
                          color: FluentianColors.primary,
                        ),
                        onPressed: () => _speakBlock(block),
                      ),
                      IconButton(
                        tooltip: 'Ask AI',
                        icon: const Icon(
                          Icons.psychology_rounded,
                          color: FluentianColors.primary,
                        ),
                        onPressed: () {
                          AiTutorSheet.show(
                            context,
                            systemContext: 'You are a language tutor. Explain the text or phrase clearly: "$text"',
                            initialPrompt: 'Can you explain this phrase to me: "$text"?',
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
                      Icons.volume_up_rounded,
                      color: FluentianColors.primary,
                    ),
                    onPressed: () => _playBlockAudioOrTts(block),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.psychology_rounded,
                      color: FluentianColors.primary,
                    ),
                    onPressed: () {
                      AiTutorSheet.show(
                        context,
                        systemContext: 'You are a language tutor. Explain the vocabulary word "$word" which means "$meaning". Give an example sentence.',
                        initialPrompt: 'Can you give me an example sentence for the word "$word"?',
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
                    Icons.volume_up_rounded,
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
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
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
      await _audioPlayer.stop();
      await _ttsService.speak(block.textToSpeak, language: block.ttsLanguage);
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
import '../providers/content_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'mcq_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    final detail = await context
        .read<ContentProvider>()
        .getLessonDetail(widget.lessonId);
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
    super.dispose();
  }

  Future<void> _playAudio(String? url) async {
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio not available')),
        );
      }
      return;
    }
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play audio')),
        );
      }
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

    final blocks = List<BlockModel>.from(_lesson!.blocks)
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
    final questions = List<QuestionModel>.from(_lesson!.questions)
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));

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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: blocks.length,
                itemBuilder: (context, index) => _buildBlock(blocks[index]),
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
                  onPressed: questions.isEmpty
                      ? null
                      : () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => McqScreen(
                                lessonId: _lesson!.id,
                                questions: questions,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FluentianColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    questions.isEmpty
                        ? 'No quiz yet'
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
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(BlockModel block) {
    final kind = block.blockKind;
    final p = block.blockPayload;

    switch (kind) {
      case 'explanation':
      case 'rich_text':
      case 'text':
        final text =
            p['content']?.toString() ?? p['text']?.toString() ?? '';
        return _textBlock(text);
      case 'vocabulary':
        return _vocabularyBlock(
          p['word']?.toString() ?? '',
          p['meaning']?.toString() ?? '',
          p['audio_url']?.toString(),
        );
      case 'grammar_note':
        return _grammarBlock(
          p['rule']?.toString() ?? p['text']?.toString() ?? '',
          p['example']?.toString() ?? '',
        );
      case 'sentence_pair':
        return _sentencePairBlock(
          p['target']?.toString() ?? p['french']?.toString() ?? '',
          p['base']?.toString() ?? p['translation']?.toString() ?? '',
        );
      case 'ai_hint':
        return _hintBlock(p['hint']?.toString() ?? '');
      case 'audio_clip':
      case 'audio':
        return _audioBlock(
          p['caption']?.toString() ?? 'Listen',
          p['url']?.toString() ?? p['audio_url']?.toString(),
        );
      default:
        final fallback = p['text']?.toString() ??
            p['content']?.toString() ??
            p['word']?.toString();
        if (fallback != null && fallback.isNotEmpty) {
          return _textBlock(fallback);
        }
        return const SizedBox.shrink();
    }
  }

  Widget _textBlock(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: FluentianColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _vocabularyBlock(String word, String meaning, String? audioUrl) {
    if (word.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
                if (meaning.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meaning,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.volume_up_rounded,
              color: FluentianColors.primary,
            ),
            onPressed: () => _playAudio(audioUrl),
          ),
        ],
      ),
    );
  }

  Widget _grammarBlock(String rule, String example) {
    if (rule.isEmpty && example.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FluentianColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rule.isNotEmpty)
            Text(
              rule,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: FluentianColors.textPrimary,
                height: 1.4,
              ),
            ),
          if (example.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              example,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: FluentianColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sentencePairBlock(String target, String base) {
    if (target.isEmpty && base.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              target,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: FluentianColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              base,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: FluentianColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintBlock(String hint) {
    if (hint.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hint,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: FluentianColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _audioBlock(String caption, String? url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        onPressed: () => _playAudio(url),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text(caption),
        style: OutlinedButton.styleFrom(
          foregroundColor: FluentianColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
    );
  }
}

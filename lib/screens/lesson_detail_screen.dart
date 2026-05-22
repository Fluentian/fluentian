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
                  onPressed: () {
                    // Navigate to MCQ flow with the questions
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => McqScreen(
                          lessonId: _lesson!.id,
                          questions: _lesson!.questions,
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
                  child: Text(
                    'Continue to Quiz',
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
    switch (block.blockKind) {
      case 'explanation':
        final text = block.blockPayload['text']?.toString() ?? '';
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
      case 'vocabulary':
        final word = block.blockPayload['word']?.toString() ?? '';
        final meaning = block.blockPayload['meaning']?.toString() ?? '';
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
                    const SizedBox(height: 4),
                    Text(
                      meaning,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: FluentianColors.primary),
                onPressed: () async {
                  final audioUrl = block.blockPayload['audio_url']?.toString();
                  if (audioUrl != null && audioUrl.isNotEmpty) {
                    try {
                      await _audioPlayer.setUrl(audioUrl);
                      _audioPlayer.play();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not play audio')),
                        );
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Audio not available')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/content_provider.dart';
import '../models/course_model.dart';
import 'mcq_screen.dart';

class SrsReviewScreen extends StatefulWidget {
  const SrsReviewScreen({super.key});

  @override
  State<SrsReviewScreen> createState() => _SrsReviewScreenState();
}

class _SrsReviewScreenState extends State<SrsReviewScreen> {
  bool _isLoading = true;
  List<QuestionModel> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await context
        .read<ContentProvider>()
        .getDueSrsQuestions();
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
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

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: FluentianColors.pageBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: FluentianColors.textPrimary),
          title: LText(
            'Daily Review',
            style: GoogleFonts.ibmPlexSans(
              color: FluentianColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: FluentianColors.success,
              ),
              const SizedBox(height: 16),
              LText(
                'You\'re all caught up!',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: FluentianColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              LText(
                'No questions due for review right now.',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  color: FluentianColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FluentianColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: LText(
                  'Go Back',
                  style: GoogleFonts.ibmPlexSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Launch MCQ Screen directly
    return McqScreen(
      lessonId: 'srs_review',
      questions: _questions,
      xpReward: 0, // dynamic xp is calculated in provider
      isSrsReview: true,
    );
  }
}

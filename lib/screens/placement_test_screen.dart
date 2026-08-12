import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../services/learning_api.dart';
import '../services/onboarding_draft_store.dart';
import '../widgets/common_widgets.dart';
import 'goal_setup_screen.dart';

class PlacementTestScreen extends StatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  final Map<int, int> _answers = {};
  bool _isSubmitting = false;

  final _questions = const [
    _PlacementQuestion(
      prompt: 'Choose the French greeting for "Good morning".',
      options: ['Bonsoir', 'Bonjour', 'Merci'],
      correctIndex: 1,
    ),
    _PlacementQuestion(
      prompt: 'What does "Je suis etudiant" mean?',
      options: ['I am a student', 'I have a book', 'I speak French'],
      correctIndex: 0,
    ),
    _PlacementQuestion(
      prompt: 'Choose the correct article: ___ maison',
      options: ['Le', 'La', 'Les'],
      correctIndex: 1,
    ),
    _PlacementQuestion(
      prompt: 'Which phrase means "I would like"?',
      options: ['Je voudrais', 'Je vais', 'Je vois'],
      correctIndex: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final complete = _answers.length == _questions.length;
    return Scaffold(
      backgroundColor: FluentianColors.white,
      appBar: AppBar(
        title: const LText('Placement test'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final q = _questions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              boxShadow: [FluentianShadows.subtle],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  q.prompt,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                RadioGroup<int>(
                  groupValue: _answers[index],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _answers[index] = value);
                    }
                  },
                  child: Column(
                    children: List.generate(q.options.length, (optionIndex) {
                      return RadioListTile<int>(
                        contentPadding: EdgeInsets.zero,
                        title: LText(q.options[optionIndex]),
                        value: optionIndex,
                        activeColor: FluentianColors.primary,
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FluentianButton(
            text: _isSubmitting ? 'Checking...' : 'Finish placement',
            onPressed: complete && !_isSubmitting ? _submit : null,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();
    final correct = List.generate(_questions.length, (index) {
      return _answers[index] == _questions[index].correctIndex;
    });
    try {
      final result = await LearningApi.instance.submitPlacement(
        answers: correct,
        detail: {
          'source': 'flutter_mvp',
          'selected': _answers.map((key, value) => MapEntry('$key', value)),
        },
      );
      final assigned = result['assigned_level']?.toString() ?? 'a0';
      final user = auth.user;
      if (user != null) {
        auth.updateUser(user.copyWith(currentLevel: assigned));
      }
      if (mounted) {
        // Placement-test users never tap Continue on LevelSetupScreen, so
        // that screen never gets a chance to save its own draft -- do it
        // here so an app kill right after this still resumes with the
        // assigned level pre-filled instead of losing it.
        await OnboardingDraftStore.instance.saveLevel(
          CEFRLevel.fromCode(assigned),
        );
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GoalSetupScreen.fromPlacement(levelCode: assigned),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: LText('Could not submit placement test.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _PlacementQuestion {
  final String prompt;
  final List<String> options;
  final int correctIndex;

  const _PlacementQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
}

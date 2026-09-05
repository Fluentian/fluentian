import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../core/theme.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});
  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen>
    with SingleTickerProviderStateMixin {
  _RecordState _state = _RecordState.idle;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _toggleRecord() {
    setState(() {
      if (_state == _RecordState.idle) {
        _state = _RecordState.recording;
      } else if (_state == _RecordState.recording) {
        _state = _RecordState.analyzing;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _state = _RecordState.result);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      color: FluentianColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: FluentianColors.border,
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
                          i < 4
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: i < 4
                              ? FluentianColors.error
                              : FluentianColors.border,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    LText(
                      'SAY THIS IN FRENCH',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textSecondary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LText(
                      "Je voudrais un café,\ns'il vous plaît.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LText(
                      'zhuh voo-DREH uhn ka-FEH, seel voo PLEH',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: FluentianColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Listen card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: FluentianColors.primaryTint,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: FluentianColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          LText(
                            'Listen to native speaker',
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          // Waveform bars
                          Row(
                            children: List.generate(
                              7,
                              (i) => Container(
                                width: 3,
                                height: 8.0 + (i % 3) * 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: FluentianColors.accent,
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Record button
                    _buildRecordButton(),

                    const SizedBox(height: 16),
                    LText(
                      _state == _RecordState.idle
                          ? 'Tap to record'
                          : _state == _RecordState.recording
                          ? 'Recording...'
                          : _state == _RecordState.analyzing
                          ? 'Analysing...'
                          : '',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 14,
                        color: FluentianColors.textSecondary,
                      ),
                    ),

                    if (_state == _RecordState.result) ...[
                      const SizedBox(height: 32),
                      _buildFeedbackCard(),
                    ],
                  ],
                ),
              ),
            ),

            if (_state == _RecordState.result)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _state = _RecordState.idle),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: FluentianColors.primary,
                          side: const BorderSide(
                            color: FluentianColors.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          minimumSize: const Size(0, 52),
                        ),
                        child: const LText('Try again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FluentianColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          minimumSize: const Size(0, 52),
                        ),
                        child: const LText('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    final isRecording = _state == _RecordState.recording;
    final isAnalyzing = _state == _RecordState.analyzing;

    return GestureDetector(
      onTap: isAnalyzing ? null : _toggleRecord,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isRecording)
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 100 + _pulseCtrl.value * 20,
                height: 100 + _pulseCtrl.value * 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FluentianColors.error.withValues(alpha: 0.1),
                ),
              ),
            ),
          if (isRecording)
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FluentianColors.error.withValues(alpha: 0.15),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording
                  ? FluentianColors.error
                  : isAnalyzing
                  ? FluentianColors.primary
                  : FluentianColors.white,
              border: Border.all(
                color: isRecording
                    ? FluentianColors.error
                    : FluentianColors.primary,
                width: 3,
              ),
            ),
            child: isAnalyzing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 32,
                    color: isRecording ? Colors.white : FluentianColors.primary,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FluentianColors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: FluentianColors.border),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 44,
            lineWidth: 6,
            percent: 0.82,
            center: LText(
              '82%',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: FluentianColors.primary,
              ),
            ),
            progressColor: FluentianColors.primary,
            backgroundColor: FluentianColors.primary.withValues(alpha: 0.15),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 20),
          _MetricRow('Pronunciation', 0.80, FluentianColors.info),
          _MetricRow('Fluency', 0.90, FluentianColors.success),
          _MetricRow('Accuracy', 0.76, FluentianColors.accent),
          const SizedBox(height: 16),
          // Word-by-word
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _WordChip('Je', FluentianColors.success),
              _WordChip('voudrais', FluentianColors.accent),
              _WordChip('un', FluentianColors.success),
              _WordChip('café', FluentianColors.success),
              _WordChip("s'il", FluentianColors.success),
              _WordChip('vous', FluentianColors.success),
              _WordChip('plaît', FluentianColors.error),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: LText(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: FluentianColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          LText(
            '${(value * 100).toInt()}%',
            style: GoogleFonts.ibmPlexSans(
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

class _WordChip extends StatelessWidget {
  final String word;
  final Color color;
  const _WordChip(this.word, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: LText(
        word,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

enum _RecordState { idle, recording, analyzing, result }

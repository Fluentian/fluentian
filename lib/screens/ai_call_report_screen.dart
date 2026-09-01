import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import '../services/social_api.dart';
import '../services/product_analytics.dart';
import 'ai_live_call_screen.dart';

class AiCallReportScreen extends StatefulWidget {
  final AiCallReport report;
  const AiCallReportScreen({super.key, required this.report});
  @override
  State<AiCallReportScreen> createState() => _AiCallReportScreenState();
}

class _AiCallReportScreenState extends State<AiCallReportScreen> {
  @override
  void initState() {
    super.initState();
    ProductAnalytics.instance.feedbackReportViewed(widget.report.scenarioId ?? 'unknown');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const LText('Practice report')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(
              widget.report.goalCompleted
              ? Icons.emoji_events_rounded
              : Icons.auto_awesome,
          size: 58,
          color: FluentianColors.secondary,
        ),
        const SizedBox(height: 12),
        Text(
          widget.report.goalCompleted
              ? 'You completed the goal!'
              : 'Nice work practicing!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: FluentianColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        _section('Focus tip', widget.report.focusTip),
        if (widget.report.vocabulary.isNotEmpty)
          _section('Words you used', widget.report.vocabulary.join(' · ')),
        if (widget.report.culturalNote != null)
          _section('Cultural note', widget.report.culturalNote!),
        if (widget.report.scenarioId != null)
          OutlinedButton.icon(
            icon: const Icon(Icons.swap_horiz_rounded),
            label: const LText('Replay with role swap'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AiLiveCallScreen(
                  settings: AiCallSettings(
                    scenarioId: widget.report.scenarioId,
                    learnerRole: widget.report.learnerRole == 'traveler'
                        ? 'student'
                        : 'traveler',
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: () =>
              Navigator.popUntil(context, (route) => route.isFirst),
          child: const LText('Back to practice'),
        ),
      ],
    ),
  );
  Widget _section(String title, String body) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: FluentianColors.primary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: GoogleFonts.inter(
              color: FluentianColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}

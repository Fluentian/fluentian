import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import '../services/product_analytics.dart';
import '../services/social_api.dart';
import 'ai_live_call_screen.dart';

class AiCallReportScreen extends StatefulWidget {
  final AiCallReport? report;
  final Future<AiCallReport>? reportFuture;
  final String? topic;

  const AiCallReportScreen({
    super.key,
    this.report,
    this.reportFuture,
    this.topic,
  }) : assert(report != null || reportFuture != null, 'Must provide either report or reportFuture');

  @override
  State<AiCallReportScreen> createState() => _AiCallReportScreenState();
}

class _AiCallReportScreenState extends State<AiCallReportScreen> with SingleTickerProviderStateMixin {
  AiCallReport? _report;
  bool _isLoading = false;
  String? _error;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    if (widget.report != null) {
      _report = widget.report;
      ProductAnalytics.instance.feedbackReportViewed(
        widget.report!.scenarioId ?? 'unknown',
      );
    } else if (widget.reportFuture != null) {
      _isLoading = true;
      widget.reportFuture!.then((rep) {
        if (!mounted) return;
        setState(() {
          _report = rep;
          _isLoading = false;
        });
        ProductAnalytics.instance.feedbackReportViewed(
          rep.scenarioId ?? 'unknown',
        );
      }).catchError((err) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = err.toString();
        });
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pageBg = isDark ? FluentianColors.darkPageBg : FluentianColors.pageBg;
    final cardBg = isDark ? const Color(0xFF092847) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1A4570) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : FluentianColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569);
    final accentTeal = isDark ? FluentianColors.secondaryLight : FluentianColors.secondary;

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: textPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
        title: Text(
          context.tr('Practice report'),
          style: GoogleFonts.inter(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? _buildLoadingState(
                  context: context,
                  isDark: isDark,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                )
              : _error != null
                  ? _buildErrorState(
                      context: context,
                      isDark: isDark,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    )
                  : _buildReportContent(
                      context: context,
                      isDark: isDark,
                      cardBg: cardBg,
                      cardBorder: cardBorder,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      accentTeal: accentTeal,
                      report: _report!,
                    ),
        ),
      ),
    );
  }

  // ── Loading Skeleton / State while AI prepares report ────────────────────
  Widget _buildLoadingState({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing avatar animation
          ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.06).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? FluentianColors.secondaryLight : FluentianColors.secondary)
                    .withValues(alpha: 0.16),
                border: Border.all(
                  color: (isDark ? FluentianColors.secondaryLight : FluentianColors.secondary)
                      .withValues(alpha: 0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: FluentianColors.secondary.withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.magic_star,
                size: 42,
                color: Color(0xFF74DDD7),
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            context.tr('Marie is preparing your report…'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          Text(
            context.tr(
              'Analyzing pronunciation, grammar refinements, and key vocabulary from your conversation.',
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 36),

          // Loading progress indicator
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: isDark ? FluentianColors.secondaryLight : FluentianColors.secondary,
            ),
          ),
          const SizedBox(height: 48),

          // Skip to practice option in case user doesn't want to wait
          TextButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: Text(
              context.tr('Skip to home'),
              style: GoogleFonts.inter(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error Fallback State ────────────────────────────────────────────────
  Widget _buildErrorState({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.info_circle,
              color: Color(0xFFF5C86B),
              size: 44,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('Practice finished'),
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(
                'Great practice session! We could not load the detailed analysis right now.',
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              child: Text(context.tr('Back to practice')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Report Content ─────────────────────────────────────────────────
  Widget _buildReportContent({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentTeal,
    required AiCallReport report,
  }) {
    final goalCompleted = report.goalCompleted;
    final topic = report.topic.trim().isNotEmpty
        ? report.topic
        : (widget.topic ?? 'French Practice Call');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      children: [
        // ── Hero Celebration Card ──────────────────────────────────────
        _buildHeroCard(
          context: context,
          isDark: isDark,
          goalCompleted: goalCompleted,
          topic: topic,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        const SizedBox(height: 18),

        // ── Quick Stats Row ───────────────────────────────────────────
        _buildStatsRow(
          context: context,
          isDark: isDark,
          cardBg: cardBg,
          cardBorder: cardBorder,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          report: report,
        ),
        const SizedBox(height: 20),

        // ── Focus Tip Card ────────────────────────────────────────────
        if (report.focusTip.isNotEmpty) ...[
          _buildFocusTipCard(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            cardBorder: cardBorder,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentTeal,
            focusTip: report.focusTip,
          ),
          const SizedBox(height: 16),
        ],

        // ── Corrections & Refinements ─────────────────────────────────
        if (report.corrections.isNotEmpty) ...[
          _buildCorrectionsSection(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            cardBorder: cardBorder,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            corrections: report.corrections,
          ),
          const SizedBox(height: 16),
        ],

        // ── Words You Used ────────────────────────────────────────────
        if (report.vocabulary.isNotEmpty) ...[
          _buildVocabularySection(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            cardBorder: cardBorder,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            accentColor: accentTeal,
            vocabulary: report.vocabulary,
          ),
          const SizedBox(height: 16),
        ],

        // ── Cultural Note ─────────────────────────────────────────────
        if (report.culturalNote != null &&
            report.culturalNote!.trim().isNotEmpty) ...[
          _buildCulturalNoteCard(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            cardBorder: cardBorder,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            culturalNote: report.culturalNote!,
          ),
          const SizedBox(height: 24),
        ] else ...[
          const SizedBox(height: 12),
        ],

        // ── Role Swap Replay Action ───────────────────────────────────
        if (report.scenarioId != null) ...[
          OutlinedButton.icon(
            icon: const Icon(Iconsax.arrow_swap_horizontal, size: 20),
            label: LText(context.tr('Replay with role swap')),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? FluentianColors.accent : FluentianColors.primary,
              side: BorderSide(
                color: isDark
                    ? FluentianColors.accent.withValues(alpha: 0.7)
                    : FluentianColors.primary,
                width: 1.5,
              ),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FluentianRadius.card),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiLiveCallScreen(
                    settings: AiCallSettings(
                      scenarioId: report.scenarioId,
                      learnerRole: report.learnerRole == 'traveler'
                          ? 'student'
                          : 'traveler',
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // ── Back to Practice Button ───────────────────────────────────
        Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: FluentianColors.primaryGradient,
            borderRadius: BorderRadius.circular(FluentianRadius.card),
            boxShadow: [
              BoxShadow(
                color: FluentianColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FluentianRadius.card),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: Text(
              context.tr('Back to practice'),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero Celebration Card ──────────────────────────────────────────────
  Widget _buildHeroCard({
    required BuildContext context,
    required bool isDark,
    required bool goalCompleted,
    required String topic,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final statusColor = goalCompleted
        ? FluentianColors.success
        : (isDark ? const Color(0xFFFBBF24) : FluentianColors.warning);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF092847) : Colors.white,
        borderRadius: BorderRadius.circular(FluentianRadius.large),
        border: Border.all(
          color: goalCompleted
              ? FluentianColors.success.withValues(alpha: isDark ? 0.4 : 0.3)
              : (isDark ? const Color(0xFF1A4570) : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (goalCompleted ? FluentianColors.success : FluentianColors.primary)
                .withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: isDark ? 0.22 : 0.14),
              border: Border.all(
                color: statusColor.withValues(alpha: isDark ? 0.6 : 0.4),
                width: 2,
              ),
            ),
            child: Icon(
              goalCompleted ? Iconsax.award : Iconsax.magic_star,
              size: 38,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            goalCompleted
                ? context.tr('Goal accomplished!')
                : context.tr('Great practice session!'),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : FluentianColors.primaryTint,
              borderRadius: BorderRadius.circular(FluentianRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.book_1,
                  size: 14,
                  color: isDark ? FluentianColors.secondaryLight : FluentianColors.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : FluentianColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Stats Row ───────────────────────────────────────────────────
  Widget _buildStatsRow({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required AiCallReport report,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statItem(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            cardBorder: cardBorder,
            icon: report.goalCompleted ? Iconsax.tick_circle : Iconsax.timer_1,
            iconColor: report.goalCompleted ? FluentianColors.success : FluentianColors.warning,
            title: report.goalCompleted ? 'Completed' : 'Practiced',
            subtitle: 'Goal status',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statItem(
            context: context,
            isDark: isDark,
            cardBg: cardBg,
            cardBorder: cardBorder,
            icon: Iconsax.message_text,
            iconColor: isDark ? FluentianColors.secondaryLight : FluentianColors.secondary,
            title: '${report.vocabulary.length}',
            subtitle: 'Target words',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ),
        if (report.learnerRole != null && report.learnerRole!.isNotEmpty) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _statItem(
              context: context,
              isDark: isDark,
              cardBg: cardBg,
              cardBorder: cardBorder,
              icon: Iconsax.user,
              iconColor: isDark ? FluentianColors.accent : FluentianColors.primaryLight,
              title: report.learnerRole![0].toUpperCase() +
                  report.learnerRole!.substring(1),
              subtitle: 'Your role',
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statItem({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(FluentianRadius.card),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 10),
          Text(
            context.tr(title),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr(subtitle),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Focus Tip Card ────────────────────────────────────────────────────
  Widget _buildFocusTipCard({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    required String focusTip,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(FluentianRadius.card),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFFFBBF24) : FluentianColors.warning)
                      .withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.lamp_on,
                  size: 18,
                  color: isDark ? const Color(0xFFFBBF24) : FluentianColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr("Marie's focus tip"),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : FluentianColors.pageBg,
              borderRadius: BorderRadius.circular(FluentianRadius.medium),
              border: Border(
                left: BorderSide(
                  color: accentColor,
                  width: 3.5,
                ),
              ),
            ),
            child: Text(
              focusTip,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Corrections & Refinements Section ─────────────────────────────────
  Widget _buildCorrectionsSection({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required List<dynamic> corrections,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.edit_2,
              size: 18,
              color: isDark ? FluentianColors.secondaryLight : FluentianColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('Grammar & pronunciation tips'),
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...corrections.map((item) {
          final original = item is Map ? (item['original']?.toString() ?? '') : '';
          final corrected = item is Map
              ? (item['corrected']?.toString() ?? '')
              : item.toString();
          final explanation = item is Map ? (item['explanation']?.toString() ?? '') : '';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(FluentianRadius.card),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (original.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Iconsax.close_circle,
                          size: 15,
                          color: FluentianColors.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          original,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFFFCA5A5)
                                : const Color(0xFF991B1B),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: FluentianColors.error,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Iconsax.tick_circle,
                        size: 15,
                        color: FluentianColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        corrected,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFF166534),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: Text(
                      explanation,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Words You Used (Vocabulary) ───────────────────────────────────────
  Widget _buildVocabularySection({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentColor,
    required List<dynamic> vocabulary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(FluentianRadius.card),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Iconsax.message_favorite,
                  size: 18,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('Words you practiced'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vocabulary.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF113861)
                      : FluentianColors.primaryTint,
                  borderRadius: BorderRadius.circular(FluentianRadius.pill),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E528B)
                        : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Text(
                  word.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : FluentianColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Cultural Note ─────────────────────────────────────────────────────
  Widget _buildCulturalNoteCard({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required String culturalNote,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(FluentianRadius.card),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: FluentianColors.info.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.global,
                  size: 18,
                  color: FluentianColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('Cultural note'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            culturalNote,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

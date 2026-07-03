import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../services/opportunities_api.dart';
import 'professional_application_screen.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'scholarships':
        return Iconsax.teacher;
      case 'jobs':
        return Iconsax.briefcase;
      case 'exchange':
        return Iconsax.global;
      case 'events':
        return Iconsax.calendar_1;
      case 'volunteer':
        return Iconsax.heart;
      default:
        return Iconsax.document_text;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'scholarships':
        return const Color(0xFF9C27B0);
      case 'jobs':
        return const Color(0xFF0288D1);
      case 'exchange':
        return const Color(0xFF009688);
      case 'events':
        return const Color(0xFFF57C00);
      case 'volunteer':
        return const Color(0xFFE91E63);
      default:
        return FluentianColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getColorForType(opportunity.type);

    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: Text(
          'Opportunity Details',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 340;
                      final iconBox = Container(
                        width: compact ? 46 : 56,
                        height: compact ? 46 : 56,
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            _getIconForType(opportunity.type),
                            color: typeColor,
                            size: compact ? 23 : 28,
                          ),
                        ),
                      );
                      final titleBlock = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opportunity.title,
                            maxLines: compact ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: compact ? 18 : 20,
                              fontWeight: FontWeight.w800,
                              color: FluentianColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                opportunity.type.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: typeColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            iconBox,
                            const SizedBox(height: 12),
                            titleBlock,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          iconBox,
                          const SizedBox(width: 14),
                          Expanded(child: titleBlock),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPill(Iconsax.location, 'Addis Ababa, Ethiopia'),
                      _buildPill(
                        Iconsax.clock,
                        opportunity.deadline != null
                            ? 'Ends ${opportunity.deadline.toString().split(' ')[0]}'
                            : 'Ongoing',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Description',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              opportunity.description,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: FluentianColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40), // Spacing before the bottom button
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfessionalApplicationScreen(opportunity: opportunity),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FluentianColors.accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              elevation: 4,
              shadowColor: FluentianColors.accent.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.send_1, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Apply Now',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 260),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: FluentianColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: FluentianColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

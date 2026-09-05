import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../services/opportunities_api.dart';
import '../widgets/common_widgets.dart';
import 'opportunity_detail_screen.dart';

class OpportunityScreen extends StatefulWidget {
  const OpportunityScreen({super.key});
  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen> {
  final OpportunitiesApi _api = OpportunitiesApi();
  List<Opportunity>? _opportunities;
  bool _isLoading = true;
  String? _error;

  int _filterIndex = 0;
  final _filters = [
    {'label': 'All', 'icon': Iconsax.category},
    {'label': 'Scholarships', 'icon': Iconsax.teacher},
    {'label': 'Jobs', 'icon': Iconsax.briefcase},
    {'label': 'Exchange', 'icon': Iconsax.global},
    {'label': 'Events', 'icon': Iconsax.calendar_1},
    {'label': 'Volunteer', 'icon': Iconsax.heart},
  ];

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

  Future<void> _fetchOpportunities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final results = await _api.getOpportunities();
      setState(() {
        _opportunities = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Opportunity> get _filteredOpportunities {
    if (_opportunities == null) return [];
    if (_filterIndex == 0) return _opportunities!;

    final category = (_filters[_filterIndex]['label'] as String).toLowerCase();
    return _opportunities!
        .where((o) => o.type.toLowerCase() == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: FluentianColors.accentTint,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Icon(
                      Iconsax.briefcase,
                      color: FluentianColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText(
                          'Opportunities',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: FluentianColors.textPrimary,
                          ),
                        ),
                        LText(
                          'Find your next step',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter pills
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final isSelected = _filterIndex == i;
                  final label = _filters[i]['label'] as String;
                  final icon = _filters[i]['icon'] as IconData;

                  return GestureDetector(
                    onTap: () => setState(() => _filterIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? FluentianColors.accent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(0),
                        border: Border.all(
                          color: isSelected
                              ? FluentianColors.accent
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: isSelected
                            ? [
                                FluentianShadows.subtle,
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (i != 0) ...[
                            Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? FluentianColors.primaryDark
                                  : FluentianColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                          ],
                          LText(
                            label,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? FluentianColors.primaryDark
                                  : FluentianColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const FluentianShimmer(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              SkeletonOpportunityCard(),
                              SkeletonOpportunityCard(),
                              SkeletonOpportunityCard(),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.warning_2,
                              size: 48,
                              color: FluentianColors.error,
                            ),
                            const SizedBox(height: 16),
                            LText(
                              'Could not load opportunities',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LText(
                              _error!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexSans(
                                color: FluentianColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _fetchOpportunities,
                              icon: const Icon(Iconsax.refresh),
                              label: const LText('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FluentianColors.accent,
                                foregroundColor: FluentianColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: FluentianColors.accent,
                      onRefresh: _fetchOpportunities,
                      child: _filteredOpportunities.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                ),
                                Icon(
                                  Iconsax.search_status,
                                  size: 64,
                                  color: FluentianColors.border,
                                ),
                                const SizedBox(height: 16),
                                LText(
                                  'No opportunities found',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: FluentianColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                100,
                              ),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: _filteredOpportunities.length,
                              itemBuilder: (context, i) {
                                final o = _filteredOpportunities[i];
                                return _OpportunityCard(opportunity: o);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard({required this.opportunity});

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
    final deadlineText = opportunity.deadline != null
        ? 'Ends ${opportunity.deadline.toString().split(' ')[0]}'
        : 'Flexible';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OpportunityDetailScreen(opportunity: opportunity),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          boxShadow: [
            FluentianShadows.subtle,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (opportunity.imageUrl != null)
              Image.network(
                opportunity.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 190),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getIconForType(opportunity.type),
                                size: 14,
                                color: typeColor,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: LText(
                                  opportunity.type.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: typeColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: FluentianColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: FluentianColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            LText(
                              'Open',
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: FluentianColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LText(
                    opportunity.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: FluentianColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LText(
                    opportunity.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 14,
                      color: FluentianColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.black.withValues(alpha: 0.04)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.clock,
                        size: 14,
                        color: FluentianColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 170),
                        child: LText(
                          deadlineText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LText(
                        'View details',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: FluentianColors.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Iconsax.arrow_right_1,
                        size: 16,
                        color: FluentianColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

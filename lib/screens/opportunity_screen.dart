import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'opportunity_detail_screen.dart';

class OpportunityScreen extends StatefulWidget {
  const OpportunityScreen({super.key});
  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen> {
  int _filterIndex = 0;
  final _filters = [
    'All',
    '🎓 Scholarships',
    '💼 Jobs',
    '🌍 Exchange',
    '🎪 Events',
    '🤝 Volunteer',
  ];
  final Set<int> _saved = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Opportunity Board',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: FluentianColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: FluentianColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Filter pills
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => _filterIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _filterIndex == i
                        ? FluentianColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: _filterIndex == i
                          ? FluentianColors.primary
                          : FluentianColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _filters[i],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _filterIndex == i
                          ? Colors.white
                          : FluentianColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Featured card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: FluentianColors.headerGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: FluentianColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FEATURED',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'CAMPUS France Scholarship 2025',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Deadline: Mar 15',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: FluentianColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'B2+',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Full scholarship for Ethiopian students to study in France. Covers tuition and living expenses.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View details →',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: FluentianColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Opportunity cards
                  ...List.generate(_opportunities.length, (i) {
                    final o = _opportunities[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OpportunityDetailScreen(
                              title: o.title,
                              company: o.org,
                              location: 'France', // mock based on flag
                              timeText: o.posted,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: o.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    o.category,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: o.color,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  o.posted,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: FluentianColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              o.title,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FluentianColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${o.org} 🇫🇷',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: FluentianColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: FluentianColors.textSecondary,
                                ),
                                Text(
                                  ' ${o.location}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: FluentianColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: FluentianColors.textSecondary,
                                ),
                                Text(
                                  ' ${o.deadline}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: FluentianColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.school_rounded,
                                  size: 14,
                                  color: FluentianColors.textSecondary,
                                ),
                                Text(
                                  ' ${o.level}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: FluentianColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _saved.contains(i)
                                        ? _saved.remove(i)
                                        : _saved.add(i),
                                  ),
                                  child: Icon(
                                    _saved.contains(i)
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 20,
                                    color: _saved.contains(i)
                                        ? FluentianColors.primary
                                        : FluentianColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: FluentianColors.primary,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Details',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: FluentianColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _opportunities = [
  _Opp(
    '🎓 Scholarship',
    'Alliance Française Scholarship',
    'Alliance Française Ethiopia',
    'Addis Ababa',
    'Apr 30',
    'B1+',
    FluentianColors.primary,
    '2 days ago',
  ),
  _Opp(
    '💼 Job',
    'French Translator — Remote',
    'UN OCHA',
    'Remote',
    'May 15',
    'B2+',
    FluentianColors.accent,
    '5 days ago',
  ),
  _Opp(
    '🌍 Exchange',
    'Student Exchange — Lyon',
    'Université Lyon 2',
    'Lyon, France',
    'Jun 1',
    'A2+',
    FluentianColors.success,
    '1 week ago',
  ),
  _Opp(
    '🎪 Event',
    'Francophone Culture Week',
    'French Embassy',
    'Addis Ababa',
    'Mar 20',
    'All levels',
    FluentianColors.info,
    '3 days ago',
  ),
];

class _Opp {
  final String category, title, org, location, deadline, level, posted;
  final Color color;
  const _Opp(
    this.category,
    this.title,
    this.org,
    this.location,
    this.deadline,
    this.level,
    this.color,
    this.posted,
  );
}

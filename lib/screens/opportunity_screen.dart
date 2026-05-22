import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/opportunities_api.dart';
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
    'All',
    '🎓 Scholarships',
    '💼 Jobs',
    '🌍 Exchange',
    '🎪 Events',
    '🤝 Volunteer',
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
    
    final category = _filters[_filterIndex].split(' ').last.toLowerCase();
    return _opportunities!.where((o) => o.type.toLowerCase() == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchOpportunities,
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
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text(_error!))
                : _filteredOpportunities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No opportunities found',
                            style: GoogleFonts.inter(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredOpportunities.length,
                      itemBuilder: (context, i) {
                        final o = _filteredOpportunities[i];
                        return _OpportunityCard(opportunity: o);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: FluentianColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    opportunity.type.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: FluentianColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Ongoing',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: FluentianColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              opportunity.title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              opportunity.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: FluentianColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: FluentianColors.primary),
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
  }
}

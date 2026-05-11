import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import 'unit_detail_screen.dart';

class LessonListScreen extends StatelessWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: Text('All Lessons', style: GoogleFonts.inter(fontSize: 16)),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildUnitItem(
            context,
            'Unit 1: Basics',
            'A1 · Grammar + Vocabulary',
            1.0,
          ),
          _buildUnitItem(context, 'Unit 2: Family', 'A1 · Vocabulary', 0.8),
          _buildUnitItem(
            context,
            'Unit 3: Greetings & intro',
            'A2 · Shared',
            0.375,
            isActive: true,
          ),
          _buildUnitItem(
            context,
            'Unit 4: Travel',
            'B1 · Conversation',
            0.0,
            isLocked: true,
          ),
          _buildUnitItem(
            context,
            'Unit 5: Work',
            'B1 · Advanced',
            0.0,
            isLocked: true,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitItem(
    BuildContext context,
    String title,
    String subtitle,
    double progress, {
    bool isActive = false,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UnitDetailScreen()),
            ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? FluentianColors.primary
                : Colors.black.withOpacity(0.05),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [FluentianShadows.subtle],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.grey.shade100
                    : FluentianColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? Icons.lock : Iconsax.book_14,
                color: isLocked ? Colors.grey : FluentianColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? Colors.grey
                          : FluentianColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation(
                      isLocked ? Colors.grey.shade300 : FluentianColors.primary,
                    ),
                    borderRadius: BorderRadius.circular(4),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/bottom_nav.dart';
import 'unit_detail_screen.dart';
import 'ai_coach_screen.dart';
import 'social_screen.dart';
import 'opportunity_screen.dart';
import 'profile_screen.dart';
import 'lesson_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeContent(),
      const AiCoachScreen(),
      const SocialScreen(),
      const OpportunityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      body: IndexedStack(index: _navIndex, children: screens),
      bottomNavigationBar: FluentianBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Good morning, Sara',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                  ),
                  const StatChip(
                    icon: Icons.local_fire_department_rounded,
                    value: '7',
                    color: FluentianColors.accent,
                    bgColor: FluentianColors.accentTint,
                  ),
                  const SizedBox(width: 6),
                  StatChip(
                    icon: Icons.bolt_rounded,
                    value: '340 XP',
                    color: FluentianColors.primary,
                    bgColor: FluentianColors.primaryTint,
                  ),
                  const SizedBox(width: 6),
                  StatChip(
                    icon: Icons.favorite_rounded,
                    value: '5/5',
                    color: FluentianColors.error,
                    bgColor: FluentianColors.errorTint,
                  ),
                ],
              ),
            ),

            // Streak banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: FluentianColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '7-day streak!',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Don\'t break it — practice today',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Iconsax.flash_15,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 340 / 500,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '340 / 500 XP to next level',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Continue learning
            SectionHeader(
              title: 'Continue learning',
              actionText: 'View all',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LessonListScreen()));
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _LessonCard(
                    title: 'Greetings',
                    unit: 'Unit 3',
                    iconData: Iconsax.message5,
                    xp: '20 XP',
                    progress: 0.6,
                    color: FluentianColors.primary,
                  ),
                  _LessonCard(
                    title: 'At the café',
                    unit: 'Unit 3',
                    iconData: Iconsax.coffee5,
                    xp: '20 XP',
                    progress: 0.3,
                    color: FluentianColors.primary,
                  ),
                  _LessonCard(
                    title: 'Numbers',
                    unit: 'Unit 2',
                    iconData: Iconsax.math,
                    xp: '15 XP',
                    progress: 1.0,
                    color: FluentianColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily challenge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FluentianColors.accentTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FluentianColors.accent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.cup5,
                      color: FluentianColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DAILY CHALLENGE',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FluentianColors.accent,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete 3 lessons today',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FluentianColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularPercentIndicator(
                      radius: 22,
                      lineWidth: 4,
                      percent: 2 / 3,
                      center: Text(
                        '2/3',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: FluentianColors.primary,
                        ),
                      ),
                      progressColor: FluentianColors.primary,
                      backgroundColor: FluentianColors.primary.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Your learning path
            const SectionHeader(title: 'Your learning path'),
            const SizedBox(height: 12),
            ..._buildUnitList(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUnitList(BuildContext context) {
    final units = [
      _UnitData(
        'Basics',
        'Unit 1',
        '6 lessons · A1',
        Icons.auto_stories_rounded,
        FluentianColors.primary,
        '5/6',
        0.83,
        false,
      ),
      _UnitData(
        'Daily Life',
        'Unit 2',
        '8 lessons · A1',
        Icons.wb_sunny_rounded,
        FluentianColors.primary,
        '8/8',
        1.0,
        false,
      ),
      _UnitData(
        'Greetings',
        'Unit 3',
        '8 lessons · A2',
        Icons.waving_hand_rounded,
        FluentianColors.primary,
        '3/8',
        0.375,
        false,
      ),
      _UnitData(
        'Travel',
        'Unit 4',
        '6 lessons · A2',
        Icons.flight_rounded,
        FluentianColors.primary,
        '0/6',
        0.0,
        true,
      ),
      _UnitData(
        'Food & Dining',
        'Unit 5',
        '7 lessons · B1',
        Icons.restaurant_rounded,
        FluentianColors.primary,
        '0/7',
        0.0,
        true,
      ),
    ];

    return units
        .map(
          (u) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: GestureDetector(
              onTap: u.locked
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UnitDetailScreen(),
                      ),
                    ),
              child: AnimatedOpacity(
                opacity: u.locked ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [FluentianShadows.subtle],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: u.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(u.icon, size: 22, color: u.color),
                            if (u.locked)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                                child: const Icon(
                                  Icons.lock_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.name,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FluentianColors.textPrimary,
                              ),
                            ),
                            Text(
                              u.caption,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: FluentianColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            u.stars,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: FluentianColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CircularPercentIndicator(
                            radius: 16,
                            lineWidth: 3,
                            percent: u.progress,
                            progressColor: u.color,
                            backgroundColor: u.color.withValues(alpha: 0.15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }
}

class _LessonCard extends StatelessWidget {
  final String title, unit, xp;
  final IconData iconData;
  final double progress;
  final Color color;
  const _LessonCard({
    required this.title,
    required this.unit,
    required this.iconData,
    required this.xp,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        boxShadow: [FluentianShadows.subtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillBadge(
            text: unit,
            bgColor: color.withValues(alpha: 0.15),
            textColor: color,
            fontSize: 11,
          ),
          const Spacer(),
          Center(
            child: Icon(iconData, color: FluentianColors.primary, size: 28),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FluentianColors.textPrimary,
                ),
              ),
              XpChip(value: xp),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitData {
  final String name, unit, caption, stars;
  final IconData icon;
  final Color color;
  final double progress;
  final bool locked;
  const _UnitData(
    this.name,
    this.unit,
    this.caption,
    this.icon,
    this.color,
    this.stars,
    this.progress,
    this.locked,
  );
}

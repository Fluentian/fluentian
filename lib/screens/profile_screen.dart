import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../widgets/common_widgets.dart';
import 'auth/sign_in_screen.dart';
import 'settings_screen.dart';
import 'paywall_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: const Border(
                  top: BorderSide(color: FluentianColors.primary, width: 4),
                ),
                boxShadow: [FluentianShadows.subtle],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FluentianColors.primary,
                        width: 3,
                      ),
                      color: FluentianColors.primaryTint,
                    ),
                    child: Center(
                      child: Text(
                        'S',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: FluentianColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sara Tesfaye',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                  Text(
                    '@sara_t',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: FluentianColors.darkNav,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'A2',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      StatChip(
                        icon: Icons.local_fire_department_rounded,
                        value: '7 days',
                        color: FluentianColors.accent,
                        bgColor: FluentianColors.accentTint,
                      ),
                      SizedBox(width: 8),
                      StatChip(
                        icon: Icons.bolt_rounded,
                        value: '2,340 XP',
                        color: FluentianColors.primary,
                        bgColor: FluentianColors.primaryTint,
                      ),
                      SizedBox(width: 8),
                      StatChip(
                        icon: Icons.check_circle_rounded,
                        value: '47 lessons',
                        color: FluentianColors.success,
                        bgColor: FluentianColors.successTint,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Streak calendar
            _buildStreakCalendar(),

            const SizedBox(height: 16),

            // Skills breakdown
            _buildSkillsCard(),

            const SizedBox(height: 16),

            // Badges
            _buildBadgesCard(),

            const SizedBox(height: 20),

            // Upgrade banner (Premium UI)
            GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF818CF8), Color(0xFFC084FC), Color(0xFFF472B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: FluentianColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PRO PLAN',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: FluentianColors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Master French Faster',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: FluentianColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unlock AI Coach, unlimited hearts, and exclusive cultural deep-dives.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: FluentianColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: FluentianColors.proGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFC084FC).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings link
            GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.settings_rounded,
                      size: 20,
                      color: FluentianColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: FluentianColors.textSecondary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Sign out',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FluentianColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCalendar() {
    // Simulated streak data: 1 = practiced, 0 = missed, 2 = today
    final weeks = [
      [1, 1, 1, 1, 1, 0, 0],
      [1, 1, 1, 0, 1, 1, 1],
      [1, 1, 0, 0, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 2],
    ];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak history',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              7,
              (i) => Expanded(
                child: Center(
                  child: Text(
                    days[i],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...weeks.map(
            (week) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: List.generate(7, (i) {
                  final d = week[i];
                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: d == 1
                              ? FluentianColors.primary
                              : d == 2
                              ? Colors.transparent
                              : Colors.grey.shade200,
                          border: d == 2
                              ? Border.all(
                                  color: FluentianColors.primary,
                                  width: 2,
                                )
                              : d == 1
                              ? Border.all(
                                  color: const Color(0xFFF59E0B),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: d == 1
                            ? const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            : d == 2
                            ? const Icon(
                                Icons.circle,
                                size: 8,
                                color: FluentianColors.primary,
                              )
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    final skills = [
      _Skill('Grammar', 0.78, FluentianColors.primary),
      _Skill('Vocabulary', 0.65, const Color(0xFF14B8A6)),
      _Skill('Listening', 0.88, FluentianColors.info),
      _Skill('Speaking', 0.55, FluentianColors.accent),
      _Skill('Reading', 0.80, FluentianColors.success),
      _Skill('Writing', 0.42, FluentianColors.error),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skill mastery',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...skills.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      s.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.value,
                        backgroundColor: s.color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(s.color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(s.value * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: s.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesCard() {
    final badges = [
      _Badge(Iconsax.flash_15, 'First streak', true),
      _Badge(Iconsax.message5, 'First dialogue', true),
      _Badge(Iconsax.radar5, '100% accuracy', true),
      _Badge(Iconsax.book5, 'Unit complete', true),
      _Badge(Iconsax.cup5, '30-day streak', false),
      _Badge(Iconsax.star5, 'All stars', false),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Badges',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              itemBuilder: (_, i) {
                final b = badges[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedOpacity(
                    opacity: b.earned ? 1.0 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: b.earned
                                ? FluentianColors.primaryTint
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: b.earned
                                  ? FluentianColors.primary.withValues(
                                      alpha: 0.3,
                                    )
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              b.iconData,
                              size: 24,
                              color: b.earned
                                  ? FluentianColors.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          b.name,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Skill {
  final String name;
  final double value;
  final Color color;
  const _Skill(this.name, this.value, this.color);
}

class _Badge {
  final String name;
  final IconData iconData;
  final bool earned;
  const _Badge(this.iconData, this.name, this.earned);
}

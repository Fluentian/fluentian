import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../widgets/common_widgets.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import 'auth/sign_in_screen.dart';
import 'settings_screen.dart';
import 'paywall_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final contentProvider = context.watch<ContentProvider>();
    final user = authProvider.user;
    final stats = contentProvider.stats;

    if (user == null) {
      return const Scaffold(
        backgroundColor: FluentianColors.pageBg,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U';
    final name = user.displayName;
    final username = '@${user.username}';
    final currentLevel = CEFRLevel.getFriendlyName(user.currentLevel);
    
    final streakVal = stats?.streakDays ?? user.streakDays;
    final xpVal = stats?.totalXp ?? user.xpTotal;
    final lessonsVal = stats?.lessonsCompleted ?? 0;
    final unitsVal = stats?.unitsCompleted ?? 0;

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
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
                        initial,
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
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: FluentianColors.textPrimary,
                    ),
                  ),
                  Text(
                    username,
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
                      currentLevel,
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
                    children: [
                      StatChip(
                        emoji: '🔥',
                        value: '$streakVal days',
                        color: FluentianColors.accent,
                        bgColor: FluentianColors.accentTint,
                      ),
                      const SizedBox(width: 8),
                      StatChip(
                        icon: Icons.bolt_rounded,
                        value: '$xpVal XP',
                        color: FluentianColors.primary,
                        bgColor: FluentianColors.primaryTint,
                      ),
                      const SizedBox(width: 8),
                      StatChip(
                        icon: Icons.check_circle_rounded,
                        value: '$lessonsVal lessons',
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
            _buildStreakCalendar(streakVal),

            const SizedBox(height: 16),

            // Skills breakdown
            _buildSkillsCard(lessonsVal),

            const SizedBox(height: 16),

            // Badges
            _buildBadgesCard(streakVal, lessonsVal, unitsVal),

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
                                  color: FluentianColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unlock unlimited hearts and exclusive cultural deep-dives.',
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
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                }
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

  Widget _buildStreakCalendar(int streakDays) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    // Highlight days representing the current streak at the end of the week
    final weekHighlights = List.generate(7, (i) {
      if (streakDays <= 0) return 0;
      if (i >= 7 - streakDays) {
        return (i == 6) ? 2 : 1; // 2 = today, 1 = completed
      }
      return 0;
    });

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
          Row(
            children: List.generate(7, (i) {
              final d = weekHighlights[i];
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
        ],
      ),
    );
  }

  Widget _buildSkillsCard(int lessonsCompleted) {
    final baseMastery = lessonsCompleted > 0 ? (lessonsCompleted / 10).clamp(0.1, 1.0) : 0.05;

    final skills = [
      _Skill('Grammar', (baseMastery * 1.2).clamp(0.05, 0.95), Iconsax.book_1),
      _Skill('Vocabulary', (baseMastery * 1.1).clamp(0.05, 0.95), Iconsax.bookmark),
      _Skill('Listening', (baseMastery * 0.9).clamp(0.05, 0.95), Iconsax.volume_high),
      _Skill('Speaking', (baseMastery * 0.7).clamp(0.05, 0.95), Iconsax.microphone_2),
      _Skill('Reading', (baseMastery * 1.0).clamp(0.05, 0.95), Iconsax.document_text),
      _Skill('Writing', (baseMastery * 0.5).clamp(0.05, 0.95), Iconsax.pen_tool),
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
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    s.iconData,
                    size: 18,
                    color: FluentianColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 90,
                    child: Text(
                      s.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: s.value,
                        backgroundColor: FluentianColors.primary.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation(FluentianColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(s.value * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: FluentianColors.primary,
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

  Widget _buildBadgesCard(int streakDays, int lessonsCompleted, int unitsCompleted) {
    final badges = [
      _Badge(Iconsax.flash_15, 'First streak', streakDays >= 1),
      _Badge(Iconsax.message5, 'First lesson', lessonsCompleted >= 1),
      _Badge(Iconsax.radar5, '100% accuracy', lessonsCompleted >= 2),
      _Badge(Iconsax.book5, 'Unit complete', unitsCompleted >= 1),
      _Badge(Iconsax.cup5, '30-day streak', streakDays >= 30),
      _Badge(Iconsax.star5, 'Super Star', lessonsCompleted >= 10),
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
  final IconData iconData;
  const _Skill(this.name, this.value, this.iconData);
}

class _Badge {
  final String name;
  final IconData iconData;
  final bool earned;
  const _Badge(this.iconData, this.name, this.earned);
}

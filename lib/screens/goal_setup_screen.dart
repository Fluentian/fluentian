import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class GoalSetupScreen extends StatefulWidget {
  final CEFRLevel level;
  const GoalSetupScreen({super.key, required this.level});
  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  int _selectedIndex = 1; // Default: Regular
  bool _reminderOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FluentianColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  Text(
                    'Step 2 of 3',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Set your daily goal',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: FluentianColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Consistency beats intensity. Pick what fits your life.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: FluentianColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2x2 grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: List.generate(DailyGoal.goals.length, (i) {
                        final goal = DailyGoal.goals[i];
                        final selected = _selectedIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selected
                                  ? FluentianColors.primaryTint
                                  : FluentianColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? FluentianColors.primary
                                    : FluentianColors.border,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                if (selected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: FluentianColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        goal.iconData,
                                        size: 32,
                                        color: FluentianColors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${goal.xp} XP',
                                        style: GoogleFonts.inter(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: FluentianColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${goal.label} · ${goal.duration}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: FluentianColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Reminder toggle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FluentianColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: FluentianColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.notifications_rounded,
                                size: 20,
                                color: FluentianColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Daily reminder',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    color: FluentianColors.textPrimary,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _reminderOn,
                                onChanged: (v) =>
                                    setState(() => _reminderOn = v),
                                activeThumbColor: FluentianColors.primary,
                              ),
                            ],
                          ),
                          if (_reminderOn)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const SizedBox(width: 32),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: FluentianColors.pageBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '8:00 AM',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: FluentianColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: FluentianColors.textSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return FluentianButton(
                    text: auth.isLoading ? 'Saving...' : 'Start learning',
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final success = await auth.updateProfile({
                              'current_level': widget.level.code,
                              'daily_goal_xp': DailyGoal.goals[_selectedIndex].xp,
                            });
                            if (success && mounted) {
                              auth.completeOnboarding();
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Failed to save profile')),
                              );
                            }
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

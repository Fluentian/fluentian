import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';

class FluentianBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FluentianBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _NavItem(Iconsax.home_1, 'Learn'),
    _NavItem(Iconsax.global, 'Explore'),
    _NavItem(Iconsax.heart, 'Community'),
    _NavItem(Iconsax.briefcase, 'Board'),
    _NavItem(Iconsax.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: FluentianColors.darkNav,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_tabs.length, (index) {
          final isActive = currentIndex == index;
          return Semantics(
            button: true,
            selected: isActive,
            label: context.tr(_tabs[index].label),
            excludeSemantics: true,
            child: GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Orange dot indicator for active tab
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    width: isActive ? 4 : 0,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: FluentianColors.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    height: 26,
                    child: Center(
                      child: Icon(
                        _tabs[index].icon,
                        size: 23,
                        color: isActive
                            ? FluentianColors.white
                            : FluentianColors.white.withValues(alpha: 0.58),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Single line, scaled down to fit if the (localized) label is
                  // long (e.g. "Community") so it never wraps to two lines.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LText(
                      _tabs[index].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isActive
                            ? FluentianColors.white
                            : FluentianColors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';
import 'social_screen.dart';
import 'live_call_screen.dart';

/// Community hub — merges Social and Live behind a single segmented toggle.
/// Segments are lazily activated so the Live/LiveKit screen does no work until
/// the user actually opens it.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _segment = 0; // 0 = Social, 1 = Live
  final Set<int> _activated = {0};

  void _select(int i) {
    if (_segment == i) return;
    setState(() {
      _activated.add(i);
      _segment = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _SegmentToggle(value: _segment, onChanged: _select),
          ),
          Expanded(
            child: IndexedStack(
              index: _segment,
              children: [
                _activated.contains(0)
                    ? const SocialScreen(key: ValueKey('community_social'))
                    : const SizedBox.shrink(),
                _activated.contains(1)
                    ? const LiveCallScreen(key: ValueKey('community_live'))
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentToggle extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _SegmentToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FluentianColors.primaryTint,
        borderRadius: BorderRadius.circular(FluentianRadius.pill),
      ),
      child: Row(
        children: [
          _seg(0, Iconsax.heart, 'Social'),
          _seg(1, Iconsax.microphone_2, 'Live'),
        ],
      ),
    );
  }

  Widget _seg(int i, IconData icon, String label) {
    final selected = value == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(i),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(FluentianRadius.pill),
            boxShadow: selected ? [FluentianShadows.subtle] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? FluentianColors.primary
                    : FluentianColors.textSecondary,
              ),
              const SizedBox(width: 6),
              LText(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? FluentianColors.primary
                      : FluentianColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

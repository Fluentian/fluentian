import 'dart:async';

import 'package:flutter/material.dart';
import '../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../models/course_model.dart';

/// Unit-level "guidebook" summary dialog -- shared between the lesson list
/// and unit detail screens so both entry points open the same content.
void showGuidebookDialog(BuildContext context, UnitModel unit) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        title: Row(
          children: [
            const Icon(Iconsax.book_1, color: FluentianColors.primary),
            const SizedBox(width: 8),
            LText(
              'Unit ${unit.unitNo} Guidebook',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: FluentianColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LText(
              'Key Vocabulary & Grammar:',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            LText(
              'In this unit, you will learn the fundamentals of conversation for this level. Practice daily to master pronoun conjugations, basic sentence structure, and core vocabulary lists.',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                color: FluentianColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            LText(
              'Lessons in this unit:',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: FluentianColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...unit.lessons.take(4).map((l) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: FluentianColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LText(
                        l.title,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          color: FluentianColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (unit.lessons.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 14),
                child: LText(
                  '+ ${unit.lessons.length - 4} more lessons',
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: FluentianColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: LText(
              'Close',
              style: GoogleFonts.ibmPlexSans(
                color: FluentianColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Stat chip — used in top bar and profile
class StatChip extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String value;
  final Color color;
  final Color bgColor;

  const StatChip({
    super.key,
    this.icon,
    this.emoji,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(FluentianRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null)
            LText(emoji!, style: const TextStyle(fontSize: 14))
          else if (icon != null)
            Icon(icon!, size: 14, color: color),
          const SizedBox(width: 4),
          LText(
            value,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class HeartStatusChip extends StatefulWidget {
  final int hearts;
  final int maxHearts;
  final DateTime? nextRefillAt;
  final FutureOr<void> Function()? onRefreshDue;
  final bool compact;
  final bool showHearts;

  const HeartStatusChip({
    super.key,
    required this.hearts,
    required this.maxHearts,
    this.nextRefillAt,
    this.onRefreshDue,
    this.compact = false,
    this.showHearts = true,
  });

  @override
  State<HeartStatusChip> createState() => _HeartStatusChipState();
}

class _HeartStatusChipState extends State<HeartStatusChip> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _refreshQueued = false;
  static const _fullHeartMessages = [
    'Ready to roll',
    'Full power',
    'All set',
    'Hearts loaded',
  ];

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant HeartStatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nextRefillAt != widget.nextRefillAt ||
        oldWidget.hearts != widget.hearts) {
      _refreshQueued = false;
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimer() {
    _timer?.cancel();
    _tick();
    if (widget.hearts < widget.maxHearts) {
      final interval = widget.nextRefillAt == null
          ? const Duration(seconds: 15)
          : const Duration(seconds: 1);
      _timer = Timer.periodic(interval, (_) => _tick());
    }
  }

  void _tick() {
    final target = widget.nextRefillAt;
    final remaining = target == null
        ? Duration.zero
        : target.difference(DateTime.now());
    if (mounted) {
      setState(() {
        _remaining = remaining.isNegative ? Duration.zero : remaining;
      });
    }
    final needsRefresh =
        widget.hearts < widget.maxHearts &&
        (target == null || remaining <= Duration.zero);
    if (needsRefresh && !_refreshQueued) {
      _refreshQueued = true;
      Future.sync(() => widget.onRefreshDue?.call()).whenComplete(() {
        if (!mounted) return;
        _refreshQueued = false;
      });
    }
  }

  String get _countdown {
    if (widget.hearts >= widget.maxHearts) return _fullHeartMessage;
    if (widget.nextRefillAt == null) return 'Checking...';
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _fullHeartMessage {
    final now = DateTime.now();
    final index = (now.day + now.hour) % _fullHeartMessages.length;
    return _fullHeartMessages[index];
  }

  @override
  Widget build(BuildContext context) {
    final heartsFull = widget.hearts >= widget.maxHearts;
    final activeColor = heartsFull
        ? FluentianColors.success
        : FluentianColors.error;
    final backgroundColor = heartsFull
        ? FluentianColors.successTint
        : FluentianColors.errorTint;
    final iconCount = widget.showHearts
        ? widget.compact
              ? widget.maxHearts.clamp(1, 5).toInt()
              : widget.maxHearts
        : 0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 8 : 10,
        vertical: widget.compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FluentianRadius.pill),
        border: Border.all(color: activeColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showHearts) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                iconCount,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 1),
                  child: Icon(
                    i < widget.hearts ? Iconsax.heart5 : Iconsax.heart,
                    size: widget.compact ? 15 : 17,
                    color: i < widget.hearts
                        ? activeColor
                        : FluentianColors.border,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          LText(
            widget.compact
                ? '${widget.hearts}/${widget.maxHearts}'
                : _countdown,
            style: GoogleFonts.ibmPlexSans(
              fontSize: widget.compact ? 11 : 12,
              fontWeight: FontWeight.w800,
              color: activeColor,
            ),
          ),
          if (!widget.compact && widget.hearts < widget.maxHearts) ...[
            const SizedBox(width: 4),
            LText(
              'next',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: FluentianColors.error.withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Section header with "View all" link
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LText(
            title,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textPrimary,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onTap,
              child: LText(
                actionText!,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: FluentianColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FluentianPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final BorderRadius? borderRadius;

  const FluentianPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.borderRadius,
  });

  @override
  State<FluentianPressable> createState() => _FluentianPressableState();
}

class _FluentianPressableState extends State<FluentianPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onPointerUp: widget.onTap == null ? null : (_) => _setPressed(false),
      onPointerCancel: widget.onTap == null ? null : (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Darken a color (used for the 3D "edge" beneath chunky buttons/tiles).
Color fluentianDarken(Color c, [double amount = 0.18]) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
}

/// Primary CTA button — a chunky, "pushable" 3D button (Duolingo-style): a
/// solid face sitting on a darker bottom edge that visibly depresses on press.
/// Public API is unchanged so every existing call site upgrades for free.
class FluentianButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final Gradient? gradient;

  const FluentianButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.gradient,
  });

  @override
  State<FluentianButton> createState() => _FluentianButtonState();
}

class _FluentianButtonState extends State<FluentianButton> {
  static const double _faceHeight = 54;
  static const double _edgeHeight = 4;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // Outlined stays a flat secondary control — chunkiness is for primary CTAs.
    if (widget.isOutlined) {
      return OutlinedButton(
        onPressed: widget.onPressed,
        child: _buttonChild(FluentianColors.primary),
      );
    }

    final Color faceColor = _enabled
        ? (widget.backgroundColor ?? FluentianColors.primary)
        : FluentianColors.border;
    final Color edgeColor = fluentianDarken(faceColor, 0.16);
    final Color fg = _enabled
        ? (widget.textColor ?? FluentianColors.white)
        : FluentianColors.textSecondary;
    final radius = BorderRadius.circular(FluentianRadius.card);

    final face = AnimatedContainer(
      duration: const Duration(milliseconds: 70),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _pressed ? _edgeHeight : 0, 0),
      height: _faceHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: widget.gradient,
        color: widget.gradient == null ? faceColor : null,
        borderRadius: radius,
        boxShadow: _enabled
            ? [
                BoxShadow(
                  color: edgeColor,
                  offset: Offset(0, _pressed ? 0 : _edgeHeight),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Center(child: _buttonChild(fg)),
    );

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) {
        _setPressed(false);
        widget.onPressed?.call();
      },
      onTapCancel: () => _setPressed(false),
      // Reserve the edge height so the layout never jumps as the face depresses.
      child: SizedBox(
        height: _faceHeight + _edgeHeight,
        child: Align(alignment: Alignment.topCenter, child: face),
      ),
    );
  }

  Widget _buttonChild(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 19, color: color),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: LText(
            widget.text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small pill badge (e.g., "Unit 3", "A2")
class PillBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  final double fontSize;

  const PillBadge({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(FluentianRadius.pill),
      ),
      child: LText(
        text,
        style: GoogleFonts.ibmPlexSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// XP chip "20 XP"
class XpChip extends StatelessWidget {
  final String value;

  const XpChip({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: FluentianColors.accentTint,
        borderRadius: BorderRadius.circular(FluentianRadius.chip),
      ),
      child: LText(
        value,
        style: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: FluentianColors.accent,
        ),
      ),
    );
  }
}

/// Fluentian card wrapper
class FluentianCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Gradient? gradient;
  final Color? bgColor;
  final double borderRadius;
  final Border? border;
  final VoidCallback? onTap;

  const FluentianCard({
    super.key,
    required this.child,
    this.padding,
    this.gradient,
    this.bgColor,
    this.borderRadius = FluentianRadius.card,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient == null ? (bgColor ?? FluentianColors.cardBg) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border:
              border ??
              Border.all(color: Colors.black.withValues(alpha: 0.06), width: 1),
          boxShadow: [FluentianShadows.subtle],
        ),
        child: child,
      ),
    );
  }
}

/// Toggle row for settings
class ToggleRow extends StatelessWidget {
  final IconData? icon;
  final IconData? customIconData;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    this.icon,
    this.customIconData,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (customIconData != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                customIconData,
                size: 20,
                color: FluentianColors.primary,
              ),
            )
          else if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(icon, size: 20, color: FluentianColors.textSecondary),
            ),
          Expanded(
            child: LText(
              label,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: FluentianColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: FluentianColors.primary,
          ),
        ],
      ),
    );
  }
}

/// Settings row with chevron
class SettingsRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? trailing;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final Color? textColor;

  const SettingsRow({
    super.key,
    this.icon,
    required this.label,
    this.trailing,
    this.trailingWidget,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  icon,
                  size: 20,
                  color: FluentianColors.textSecondary,
                ),
              ),
            Expanded(
              child: LText(
                label,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: textColor ?? FluentianColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              LText(
                trailing!,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 14,
                  color: FluentianColors.textSecondary,
                ),
              ),
            if (trailingWidget != null) trailingWidget!,
            const SizedBox(width: 4),
            Icon(
              Iconsax.arrow_right_3,
              size: 20,
              color: FluentianColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SKELETON / SHIMMER LOADING SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

/// Smooth pulsing shimmer wrapper for all skeleton states.
class FluentianShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FluentianShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<FluentianShimmer> createState() => _FluentianShimmerState();
}

class _FluentianShimmerState extends State<FluentianShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.35, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the reduced-motion accessibility setting: show a static
    // skeleton instead of a looping shimmer when animations are disabled.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 1.0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Opacity(
        opacity: _animation.value,
        child: widget.child,
      ),
    );
  }
}

/// Primitive skeleton rectangular or rounded container.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? FluentianColors.border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton matching the dark navy Home Hero card.
class SkeletonHeroCard extends StatelessWidget {
  const SkeletonHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: FluentianColors.headerGradient,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 90,
                    height: 12,
                    borderRadius: 6,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 8),
                  SkeletonBox(
                    width: 140,
                    height: 24,
                    borderRadius: 6,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
              SkeletonBox(
                width: 40,
                height: 40,
                borderRadius: 12,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SkeletonBox(
            width: 220,
            height: 14,
            borderRadius: 6,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SkeletonBox(
                width: 110,
                height: 32,
                borderRadius: 16,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              SkeletonBox(
                width: 90,
                height: 32,
                borderRadius: 16,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SkeletonBox(
            width: 100,
            height: 10,
            borderRadius: 4,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 8),
          SkeletonBox(
            width: double.infinity,
            height: 8,
            borderRadius: 4,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching the Continue Journey / Mission card.
class SkeletonMissionCard extends StatelessWidget {
  const SkeletonMissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: FluentianColors.headerGradient,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 180,
            height: 12,
            borderRadius: 6,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          SkeletonBox(
            width: double.infinity,
            height: 22,
            borderRadius: 6,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 8),
          SkeletonBox(
            width: 200,
            height: 18,
            borderRadius: 6,
            color: Colors.white.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          SkeletonBox(
            width: 160,
            height: 14,
            borderRadius: 6,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SkeletonBox(
                width: 65,
                height: 20,
                borderRadius: 6,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 12),
              SkeletonBox(
                width: 65,
                height: 20,
                borderRadius: 6,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              const Spacer(),
              SkeletonBox(
                width: 100,
                height: 46,
                borderRadius: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching the Daily Challenge card.
class SkeletonChallengeCard extends StatelessWidget {
  const SkeletonChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const SkeletonBox(width: 50, height: 50, borderRadius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: 110, height: 11, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 160, height: 16, borderRadius: 6),
              ],
            ),
          ),
          const SkeletonBox(width: 44, height: 44, borderRadius: 22),
        ],
      ),
    );
  }
}

/// Skeleton matching the Learning Path roadmap.
class SkeletonRoadmap extends StatelessWidget {
  const SkeletonRoadmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonBox(width: 38, height: 38, borderRadius: 19),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 16, borderRadius: 6),
                  SizedBox(height: 4),
                  SkeletonBox(width: 80, height: 11, borderRadius: 4),
                ],
              ),
              Spacer(),
              SkeletonBox(width: 60, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: FluentianColors.headerGradient,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 160,
                  height: 11,
                  borderRadius: 4,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                SkeletonBox(
                  width: double.infinity,
                  height: 20,
                  borderRadius: 6,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 6),
                SkeletonBox(
                  width: 180,
                  height: 18,
                  borderRadius: 6,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                SkeletonBox(
                  width: double.infinity,
                  height: 6,
                  borderRadius: 3,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Column(
              children: const [
                SkeletonBox(width: 68, height: 68, borderRadius: 34),
                SizedBox(height: 24),
                SkeletonBox(width: 68, height: 68, borderRadius: 34),
                SizedBox(height: 24),
                SkeletonBox(width: 68, height: 68, borderRadius: 34),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching Opportunity / Board card.
class SkeletonOpportunityCard extends StatelessWidget {
  const SkeletonOpportunityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    SkeletonBox(width: 90, height: 26, borderRadius: 8),
                    SizedBox(width: 8),
                    SkeletonBox(width: 60, height: 22, borderRadius: 20),
                  ],
                ),
                const SizedBox(height: 14),
                const SkeletonBox(width: double.infinity, height: 20, borderRadius: 6),
                const SizedBox(height: 8),
                const SkeletonBox(width: 220, height: 18, borderRadius: 6),
                const SizedBox(height: 12),
                const SkeletonBox(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                const SkeletonBox(width: 180, height: 14, borderRadius: 4),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.04)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SkeletonBox(width: 120, height: 14, borderRadius: 4),
                SkeletonBox(width: 90, height: 14, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching Culture Story Explore card.
class SkeletonCultureStory extends StatelessWidget {
  const SkeletonCultureStory({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: double.infinity, height: 240, borderRadius: 20),
          const SizedBox(height: 18),
          const SkeletonBox(width: 100, height: 24, borderRadius: 8),
          const SizedBox(height: 10),
          const SkeletonBox(width: 220, height: 28, borderRadius: 8),
          const SizedBox(height: 8),
          const SkeletonBox(width: 140, height: 16, borderRadius: 6),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(width: double.infinity, height: 16, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 16, borderRadius: 4),
                SizedBox(height: 8),
                SkeletonBox(width: 180, height: 16, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching Live Speaking Rooms.
class SkeletonLiveRoom extends StatelessWidget {
  const SkeletonLiveRoom({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: FluentianColors.headerGradient,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(
                    width: 44,
                    height: 44,
                    borderRadius: 12,
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 150,
                        height: 16,
                        borderRadius: 6,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 6),
                      SkeletonBox(
                        width: 100,
                        height: 12,
                        borderRadius: 4,
                        color: Colors.white.withValues(alpha: 0.24),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SkeletonBox(
                width: double.infinity,
                height: 48,
                borderRadius: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SkeletonBox(width: 140, height: 14, borderRadius: 4),
        const SizedBox(height: 14),
        ...List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const SkeletonBox(width: 46, height: 46, borderRadius: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 130, height: 16, borderRadius: 6),
                      SizedBox(height: 6),
                      SkeletonBox(width: 160, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SkeletonBox(width: 36, height: 36, borderRadius: 10),
                const SizedBox(width: 8),
                const SkeletonBox(width: 36, height: 36, borderRadius: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Skeleton matching Profile Screen.
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: FluentianColors.headerGradient,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  SkeletonBox(
                    width: 76,
                    height: 76,
                    borderRadius: 38,
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(
                          width: 140,
                          height: 22,
                          borderRadius: 6,
                          color: Colors.white.withValues(alpha: 0.38),
                        ),
                        const SizedBox(height: 6),
                        SkeletonBox(
                          width: 90,
                          height: 14,
                          borderRadius: 4,
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                        const SizedBox(height: 10),
                        SkeletonBox(
                          width: 100,
                          height: 24,
                          borderRadius: 12,
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ],
                    ),
                  ),
                  SkeletonBox(
                    width: 40,
                    height: 40,
                    borderRadius: 12,
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SkeletonBox(width: 120, height: 12, borderRadius: 4),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonBox(width: 110, height: 16, borderRadius: 6),
                  SkeletonBox(width: 40, height: 16, borderRadius: 6),
                ],
              ),
              SizedBox(height: 12),
              SkeletonBox(width: double.infinity, height: 8, borderRadius: 4),
              SizedBox(height: 10),
              SkeletonBox(width: 160, height: 12, borderRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SkeletonBox(width: 100, height: 12, borderRadius: 4),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: List.generate(
            4,
            (_) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SkeletonBox(width: 36, height: 36, borderRadius: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 60, height: 18, borderRadius: 6),
                      SizedBox(height: 4),
                      SkeletonBox(width: 80, height: 11, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


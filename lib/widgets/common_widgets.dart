import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';

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
            Text(emoji!, style: const TextStyle(fontSize: 14))
          else if (icon != null)
            Icon(icon!, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.inter(
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
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            widget.compact
                ? '${widget.hearts}/${widget.maxHearts}'
                : _countdown,
            style: GoogleFonts.inter(
              fontSize: widget.compact ? 11 : 12,
              fontWeight: FontWeight.w800,
              color: activeColor,
            ),
          ),
          if (!widget.compact && widget.hearts < widget.maxHearts) ...[
            const SizedBox(width: 4),
            Text(
              'next',
              style: GoogleFonts.inter(
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
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textPrimary,
            ),
          ),
          if (actionText != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                actionText!,
                style: GoogleFonts.inter(
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

/// Primary CTA button
class FluentianButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (gradient != null) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(FluentianRadius.medium),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(FluentianRadius.medium),
            child: Center(
              child: _buttonChild(textColor ?? FluentianColors.textPrimary),
            ),
          ),
        ),
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        child: _buttonChild(FluentianColors.primary),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: backgroundColor != null
          ? ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor ?? FluentianColors.white,
            )
          : null,
      child: _buttonChild(textColor ?? FluentianColors.white),
    );
  }

  Widget _buttonChild(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 19, color: color),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
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
      child: Text(
        text,
        style: GoogleFonts.inter(
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
      child: Text(
        value,
        style: GoogleFonts.inter(
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
            child: Text(
              label,
              style: GoogleFonts.inter(
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
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: textColor ?? FluentianColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: GoogleFonts.inter(
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

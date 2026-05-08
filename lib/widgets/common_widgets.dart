import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

/// Stat chip — used in top bar and profile
class StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final Color bgColor;

  const StatChip({
    super.key,
    required this.icon,
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
          Icon(icon, size: 14, color: color),
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

/// Primary CTA button
class FluentianButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final Gradient? gradient;

  const FluentianButton({
    super.key,
    required this.text,
    this.onPressed,
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
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? FluentianColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isOutlined) {
      return OutlinedButton(onPressed: onPressed, child: Text(text));
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: backgroundColor != null
          ? ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor ?? FluentianColors.white,
            )
          : null,
      child: Text(text),
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
              Icons.chevron_right_rounded,
              size: 20,
              color: FluentianColors.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthColors {
  static const primary = FluentianColors.primaryDark;
  static const primaryBlue = FluentianColors.primary;
  static const pageBg = FluentianColors.white;
  static const cardBg = FluentianColors.cardBg;
  static const heading = FluentianColors.textPrimary;
  static const body = FluentianColors.textSecondary;
  static const placeholder = Color(0xFF64748B);
  static const border = FluentianColors.border;
  static const inputBg = FluentianColors.pageBg;
  static const errorText = FluentianColors.error;
  static const errorBg = FluentianColors.errorTint;
  static const success = FluentianColors.success;
  static const disabledBtn = Color(0xFF94A3B8);
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LText(
          'fluentian',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AuthColors.heading,
            letterSpacing: -1.0,
          ),
        ),
        LText(
          '.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AuthColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}

class AuthInputField extends StatefulWidget {
  final String label;
  final IconData? leftIcon;
  final bool isPassword;
  final String? errorText;
  final TextInputType keyboardType;
  final Widget? rightWidget;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextEditingController? controller;
  final bool enabled;
  final String? hint;

  const AuthInputField({
    super.key,
    required this.label,
    this.leftIcon,
    this.isPassword = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.rightWidget,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.enabled = true,
    this.hint,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AuthColors.errorText
        : (_isFocused ? AuthColors.primaryBlue : AuthColors.border);
    final borderWidth = (_isFocused || hasError) ? 1.5 : 1.0;
    final bgColor = hasError ? AuthColors.errorBg : AuthColors.inputBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LText(
          widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AuthColors.heading,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              if (widget.leftIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    widget.leftIcon,
                    color: _isFocused ? AuthColors.primaryBlue : AuthColors.placeholder,
                    size: 18,
                  ),
                )
              else
                const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  obscureText: _obscureText,
                  keyboardType: widget.keyboardType,
                  controller: widget.controller,
                  enabled: widget.enabled,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onSubmitted,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AuthColors.heading,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AuthColors.placeholder,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (widget.isPassword && widget.rightWidget == null)
                IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AuthColors.placeholder,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              else if (widget.rightWidget != null)
                widget.rightWidget!,
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: LText(
              widget.errorText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AuthColors.errorText,
              ),
            ),
          ),
      ],
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AuthButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isLoading = text.contains('…') || text.toLowerCase().contains('loading');
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AuthColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primary,
          disabledBackgroundColor: AuthColors.disabledBtn,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : LText(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

/// Renders Google's actual official multi-color "G" mark from a bundled SVG
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/google_logo.svg',
    width: size,
    height: size,
  );
}

class AuthSocialButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AuthSocialButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const GoogleLogo(size: 22),
        label: LText(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AuthColors.heading,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AuthColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AuthColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: LText(
            'or continue with',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AuthColors.placeholder,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AuthColors.border, thickness: 1)),
      ],
    );
  }
}

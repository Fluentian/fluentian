import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/tibeb_band.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthColors {
  static const primary = FluentianColors.primaryDark;
  static const primaryBlue = FluentianColors.primary;
  static const pageBg = FluentianColors.pageBg;
  static const cardBg = FluentianColors.cardBg;
  static const heading = FluentianColors.textPrimary;
  static const body = FluentianColors.textSecondary;
  // Was slate-400/500 leftovers from the old palette. Placeholders and
  // disabled states now come out of the paper family so the auth screens sit
  // on the same ground as the rest of the app.
  static const placeholder = FluentianColors.textSecondary;
  static const border = FluentianColors.border;
  static const inputBg = FluentianColors.cardBg;
  static const errorText = FluentianColors.error;
  static const errorBg = FluentianColors.errorTint;
  static const success = FluentianColors.success;
  static const disabledBtn = Color(0xFFB4B4AB);
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Was a centred lowercase wordmark with a coloured full stop — the
    // startup-logo convention. Left-aligned, sentence case, sitting on a
    // tibeb rule instead.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LText(
          'Fluentian',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AuthColors.heading,
            letterSpacing: -1.0,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(width: 88, child: TibebBand(height: 10)),
      ],
    );
  }
}

class AuthInputField extends StatefulWidget {
  final String label;
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
    final borderWidth = (_isFocused || hasError) ? 2.0 : 1.0;
    final bgColor = hasError ? AuthColors.errorBg : AuthColors.inputBg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mono, upper, tracked -- the same caption voice as the onboarding
        // field-set labels, so a form is a form everywhere in the app.
        Text(
          context.tr(widget.label).toUpperCase(),
          style: FluentianTheme.label(),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              // No leading icon. Every field used to pair one with a label
              // that already said the same word -- an envelope beside EMAIL
              // ADDRESS, a padlock beside PASSWORD. Two of the six auth
              // fields never had one, so the flow was inconsistent as well
              // as redundant.
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  obscureText: _obscureText,
                  keyboardType: widget.keyboardType,
                  controller: widget.controller,
                  enabled: widget.enabled,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onSubmitted,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AuthColors.heading,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.ibmPlexSans(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Never colour alone: the mark carries the error for anyone
                // who cannot separate the red from the ink.
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AuthColors.errorText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: LText(
                    widget.errorText!,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AuthColors.errorText,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
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
        borderRadius: BorderRadius.circular(0),
        // A solid offset block, not a 30%-alpha ghost. The button looks
        // physically stacked on the paper; a translucent halo just looks
        // like a blur that failed to render.
        boxShadow: onPressed != null
            ? const [
                BoxShadow(
                  color: FluentianColors.border,
                  blurRadius: 0,
                  offset: Offset(3, 3),
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
            borderRadius: BorderRadius.circular(0),
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
                style: GoogleFonts.ibmPlexSans(
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
        borderRadius: BorderRadius.circular(0),
        // A 4%-black offset is invisible; the 1px rule already separates
        // this from the ground.

      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const GoogleLogo(size: 22),
        label: LText(
          text,
          style: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AuthColors.heading,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AuthColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
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
          child: Text(
            context.tr('or continue with').toUpperCase(),
            style: FluentianTheme.label(),
          ),
        ),
        const Expanded(child: Divider(color: AuthColors.border, thickness: 1)),
      ],
    );
  }
}

/// The auth error banner.
///
/// This existed four times over -- an identical private copy in sign in, sign
/// up, OTP and reset password, each hard-coding `#FFF8F8` on `#FECACA` from
/// the palette this app no longer uses. One copy, on the system's error tint,
/// with a rule down the left edge so the message reads as a stamped note.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: const BoxDecoration(
        color: FluentianColors.errorTint,
        border: Border(
          left: BorderSide(color: FluentianColors.error, width: 3),
          top: BorderSide(color: FluentianColors.error, width: 1),
          right: BorderSide(color: FluentianColors.error, width: 1),
          bottom: BorderSide(color: FluentianColors.error, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: FluentianColors.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LText(
              message,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 14,
                height: 1.4,
                color: FluentianColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

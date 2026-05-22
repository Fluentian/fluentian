import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthColors {
  static const primary = Color(0xFF6C3BF5);
  static const pageBg = Color(0xFFF8F7FC);
  static const cardBg = Color(0xFFFFFFFF);
  static const heading = Color(0xFF1A0A2E);
  static const body = Color(0xFF374151);
  static const placeholder = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const errorText = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEE2E2);
  static const success = Color(0xFF22C55E);
  static const disabledBtn = Color(0xFFD1C4F9);
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AuthColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AuthColors.primary.withOpacity(0.2),
                blurRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'fluentian',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: AuthColors.heading,
          ),
        ),
      ],
    );
  }
}

class AuthInputField extends StatefulWidget {
  final String label;
  final IconData leftIcon;
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
    required this.leftIcon,
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
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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
        : (_isFocused ? AuthColors.primary : AuthColors.border);
    final borderWidth = (_isFocused || hasError) ? 1.5 : 1.0;
    final iconColor = hasError
        ? AuthColors.errorText
        : (_isFocused ? AuthColors.primary : AuthColors.placeholder);
    final bgColor = hasError ? const Color(0xFFFFF8F8) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(widget.leftIcon, color: iconColor, size: 18),
              ),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  obscureText: _obscureText,
                  keyboardType: widget.keyboardType,
                  controller: widget.controller,
                  enabled: widget.enabled,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onSubmitted,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AuthColors.heading,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: widget.label,
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AuthColors.placeholder.withOpacity(0.7),
                    ),
                    labelStyle: GoogleFonts.inter(
                      fontSize: _isFocused ? 12 : 16,
                      color: AuthColors.placeholder,
                    ),
                    floatingLabelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: hasError
                          ? AuthColors.errorText
                          : AuthColors.primary,
                    ),
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
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AuthColors.errorText,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AuthColors.errorText,
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
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primary,
          disabledBackgroundColor: AuthColors.disabledBtn,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  final String text;
  final IconData icon; // Placeholder for logo
  final VoidCallback onPressed;

  const AuthSocialButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: AuthColors.body),
        label: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AuthColors.body,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AuthColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AuthColors.placeholder,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AuthColors.border, thickness: 1)),
      ],
    );
  }
}

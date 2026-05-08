import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _emailSent = false;
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AuthColors.body,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(child: _SmallLogo()),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              if (!_emailSent) _buildStateA() else _buildStateB(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateA() {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Center(
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: 48,
              color: AuthColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          decoration: BoxDecoration(
            color: AuthColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AuthColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forgot your password?',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No worries. Enter your email and we\'ll send you a reset link.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AuthColors.placeholder,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              AuthInputField(
                label: 'Email address',
                leftIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => _email = val,
              ),
              const SizedBox(height: 28),
              AuthButton(
                text: 'Send reset link',
                onPressed: () => setState(() => _emailSent = true),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: AuthColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Back to sign in',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AuthColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStateB() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            shape: BoxShape.circle,
            border: Border.all(color: AuthColors.success, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.check, color: AuthColors.success, size: 28),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          decoration: BoxDecoration(
            color: AuthColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AuthColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Check your email',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a password reset link to',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AuthColors.placeholder,
                ),
              ),
              Text(
                _email.isEmpty ? 'your email' : _email,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.heading,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The link expires in 15 minutes.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AuthColors.placeholder,
                ),
              ),
              const SizedBox(height: 24),
              AuthButton(text: 'Open email app', onPressed: () {}),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AuthColors.placeholder,
                  ),
                  children: const [
                    TextSpan(text: 'Didn\'t receive it? '),
                    TextSpan(
                      text: 'Resend',
                      style: TextStyle(
                        color: AuthColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: AuthColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Back to sign in',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AuthColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallLogo extends StatelessWidget {
  const _SmallLogo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AuthColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'fluentian',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AuthColors.heading,
          ),
        ),
      ],
    );
  }
}

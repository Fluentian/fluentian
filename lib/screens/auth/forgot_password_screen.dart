import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _email = '';
  bool _isLoading = false;

  void _dismissMessages() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.read<AuthProvider>().clearError();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _dismissMessages();
    });
  }

  Future<void> _handleSendResetOtp() async {
    final email = _email.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LText('Please enter your email address.'),
          duration: AuthProvider.errorDisplayDuration,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().sendPasswordResetOtp(
      email,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)),
      );
    } else {
      final error = context.read<AuthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LText(
            error ?? 'Failed to send reset code. Please try again.',
          ),
          duration: AuthProvider.errorDisplayDuration,
        ),
      );
      context.read<AuthProvider>().clearError();
    }
  }

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
                    onPressed: () {
                      _dismissMessages();
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(child: AuthLogo()),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              Column(
                children: [
                  // Was a 48px envelope icon floating over the card. A
                  // giant outline glyph restating the heading is the stock
                  // empty-state move; the heading already says it.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: AuthColors.cardBg,
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(color: AuthColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText(
                          'Forgot your password?',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        LText(
                          "Enter your email and we'll send a 6-digit code to reset your password.",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        AuthInputField(
                          label: 'Email address',
                          keyboardType: TextInputType.emailAddress,
                          hint: 'Enter the email linked to your account',
                          onChanged: (val) {
                            _email = val;
                            _dismissMessages();
                          },
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 28),
                        AuthButton(
                          text: _isLoading
                              ? 'Sending code…'
                              : 'Send verification code',
                          onPressed: _isLoading ? null : _handleSendResetOtp,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              _dismissMessages();
                              Navigator.pop(context);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 16,
                                  color: AuthColors.primary,
                                ),
                                const SizedBox(width: 6),
                                LText(
                                  'Back to sign in',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}


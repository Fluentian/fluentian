import 'package:flutter/material.dart';
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
          content: Text('Please enter your email address.'),
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
          content: Text(
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
                  const Expanded(child: _SmallLogo()),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              Column(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 28,
                    ),
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
                          "No worries. Enter your email and we'll send you a 6-digit verification code to reset your password.",
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
                        Center(
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
              ),
            ],
          ),
        ),
      ),
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

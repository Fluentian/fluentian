import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import 'auth_widgets.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _otp;
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: LText('Please enter all 6 digits.')),
      );
      return;
    }

    final success = await context.read<AuthProvider>().verifyEmailOtp(code);
    if (!mounted) return;

    if (success) {
      // Pop to home (main.dart AppRoot will auto-transition on state change)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    final success = await context.read<AuthProvider>().resendVerificationOtp();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LText('Verification code resent successfully.'),
        ),
      );
      _startTimer();
    } else {
      final error = context.read<AuthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LText(error ?? 'Failed to resend code. Please try again.'),
        ),
      );
    }
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Clear focus if last digit is filled
        _focusNodes[index].unfocus();
        _verifyOtp(); // Auto-verify on complete
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
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
                      const Expanded(child: AuthLogo()),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
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
                          'Verify your email',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 15,
                              color: AuthColors.body,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(
                                text: context.tr('We sent a 6-digit code to '),
                              ),
                              TextSpan(
                                text: widget.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AuthColors.heading,
                                ),
                              ),
                              TextSpan(
                                text: context.tr(
                                  '. Enter it below to verify your account.',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 6-digit OTP fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 42,
                              height: 52,
                              child: KeyboardListener(
                                focusNode: FocusNode(), // Dummy focus node
                                onKeyEvent: (KeyEvent event) {
                                  // Auto-backspace behavior if empty
                                  if (event is KeyDownEvent &&
                                      event.logicalKey ==
                                          LogicalKeyboardKey.backspace &&
                                      _controllers[index].text.isEmpty &&
                                      index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  onChanged: (val) => _onChanged(val, index),
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  // A one-time code is data, not prose, so
                                  // it is set in the mono face -- and mono
                                  // digits are the ones that don't confuse
                                  // 0/O or 1/l when read off a phone.
                                  style: FluentianTheme.label(
                                    size: 20,
                                    color: AuthColors.heading,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: const BorderSide(
                                        color: AuthColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: const BorderSide(
                                        color: AuthColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        // Error message
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 20),
                          AuthErrorBanner(message: auth.errorMessage!),
                        ],

                        const SizedBox(height: 32),
                        AuthButton(
                          text: auth.isLoading ? 'Verifying…' : 'Verify email',
                          onPressed: auth.isLoading ? null : _verifyOtp,
                        ),
                        const SizedBox(height: 24),

                        // Timer / Resend
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _canResend
                              ? GestureDetector(
                                  onTap: auth.isLoading ? null : _resendOtp,
                                  child: LText(
                                    'Resend verification code',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 14,
                                      color: AuthColors.primary,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              : Text(
                                  '${context.tr('Resend in')} '
                                  '${_secondsRemaining.toString().padLeft(2, '0')}s',
                                  style: FluentianTheme.label(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


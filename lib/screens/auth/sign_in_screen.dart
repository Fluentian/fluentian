import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../legal_document_screen.dart';
import 'auth_widgets.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';

class SignInScreen extends StatefulWidget {
  final String? initialEmail;

  const SignInScreen({super.key, this.initialEmail});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final _emailController = TextEditingController(
    text: widget.initialEmail ?? '',
  );
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _dismissMessages() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.read<AuthProvider>().clearError();
  }

  void _openAuthPage(Widget page) {
    _dismissMessages();
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().clearError();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      context
          .read<AuthProvider>()
          // ignore: invalid_use_of_protected_member
          .clearError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: LText('Please fill in all fields.'),
          duration: AuthProvider.errorDisplayDuration,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email: email, password: password);

    if (!mounted) return;
    if (success) {
      // Sign in can be reached from a pushed Sign Up/Forgot Password route.
      // AuthProvider has already switched _AppRoot to Home, so remove any
      // auth pages that would otherwise continue covering it.
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
      return;
    }

    if (!success) {
      if (authProvider.unverifiedEmail != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                OtpVerificationScreen(email: authProvider.unverifiedEmail!),
          ),
        );
      } else {
        final message =
            authProvider.errorMessage ??
            'Sign in failed. Check your connection and try again.';
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: LText(message),
              duration: AuthProvider.errorDisplayDuration,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
    // On success, _AppRoot Consumer in main.dart auto-navigates to HomeScreen
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted) return;
    if (success) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
      return;
    }
    final message = auth.errorMessage;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LText(message),
          duration: AuthProvider.errorDisplayDuration,
        ),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthColors.pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    const AuthLogo(),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: AuthColors.cardBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AuthColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Friendly French greeting badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AuthColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('👋 ', style: TextStyle(fontSize: 13)),
                                LText(
                                  'Bonjour ! Welcome back',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AuthColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          LText(
                            'Sign in to your account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AuthColors.heading,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          LText(
                            'Continue your French learning journey today.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AuthColors.placeholder,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Email field
                          AuthInputField(
                            label: 'Email address',
                            leftIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            hint: 'name@example.com',
                            enabled: !auth.isLoading,
                            onChanged: (_) => _dismissMessages(),
                          ),
                          const SizedBox(height: 20),

                          // Password field
                          AuthInputField(
                            label: 'Password',
                            leftIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            controller: _passwordController,
                            hint: '••••••••',
                            enabled: !auth.isLoading,
                            onChanged: (_) => _dismissMessages(),
                            onSubmitted: (_) => _handleSignIn(),
                          ),

                          const SizedBox(height: 16),

                          // Remember me & Forgot Password row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: auth.isLoading
                                    ? null
                                    : () => setState(
                                        () => _rememberMe = !_rememberMe,
                                      ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _rememberMe
                                            ? AuthColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _rememberMe
                                              ? AuthColors.primary
                                              : AuthColors.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: _rememberMe
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    LText(
                                      'Remember me',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AuthColors.body,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _openAuthPage(const ForgotPasswordScreen()),
                                child: LText(
                                  'Forgot password?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AuthColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Error banner
                          if (auth.errorMessage != null) ...[
                            const SizedBox(height: 20),
                            _ErrorBanner(message: auth.errorMessage!),
                          ],

                          const SizedBox(height: 24),
                          AuthButton(
                            text: auth.isLoading ? 'Signing in…' : 'Sign in',
                            onPressed: auth.isLoading ? null : _handleSignIn,
                          ),
                          const SizedBox(height: 24),
                          const AuthDivider(),
                          const SizedBox(height: 20),
                          AuthSocialButton(
                            text: 'Continue with Google',
                            onPressed: auth.isLoading
                                ? null
                                : _handleGoogleSignIn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            LegalDocumentScreen.route(
                              title: 'Privacy policy',
                              url:
                                  'https://api.fluentianapp.binovatechnologies.com/privacy',
                            ),
                          ),
                          icon: const Icon(Icons.shield_outlined, size: 16, color: AuthColors.placeholder),
                          label: LText(
                            'Privacy policy',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AuthColors.placeholder,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _openAuthPage(const SignUpScreen()),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AuthColors.placeholder,
                          ),
                          children: [
                            TextSpan(text: context.tr("Don't have an account? ")),
                            TextSpan(
                              text: context.tr('Sign up'),
                              style: const TextStyle(
                                color: AuthColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AuthColors.errorText,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LText(
              message,
              style: GoogleFonts.inter(fontSize: 14, color: AuthColors.body),
            ),
          ),
        ],
      ),
    );
  }
}

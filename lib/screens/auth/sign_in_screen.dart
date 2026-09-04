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
import '../../core/endpoints.dart';

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Center(child: AuthLogo()),
                  const SizedBox(height: 36),

                  LText(
                    'Welcome back',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AuthColors.heading,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LText(
                    'Sign in to your Fluentian account to continue.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: AuthColors.placeholder,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  AuthInputField(
                    label: 'Email address',
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
                                    ? AuthColors.primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _rememberMe
                                      ? AuthColors.primaryBlue
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
                            color: AuthColors.primaryBlue,
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

                  const SizedBox(height: 28),
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
                  const SizedBox(height: 32),

                  Center(
                    child: Column(
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            LegalDocumentScreen.route(
                              title: 'Privacy policy',
                              url:
                                  Endpoints.privacy,
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
                                    color: AuthColors.primaryBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
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

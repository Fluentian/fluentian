import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
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
                  const AuthLogo(),
                  const SizedBox(height: 36),

                  // Straight off the theme, so the auth pages and the
                  // onboarding pages share one heading size and one
                  // measure rather than each screen picking its own.
                  LText(
                    'Welcome back',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  LText(
                    'Sign in to your Fluentian account to continue.',
                    style: Theme.of(context).textTheme.bodyLarge,
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
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  color: _rememberMe
                                      ? AuthColors.primaryBlue
                                      : AuthColors.border,
                                  width: _rememberMe ? 2 : 1,
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
                              style: GoogleFonts.ibmPlexSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AuthColors.heading,
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
                          style: GoogleFonts.ibmPlexSans(
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
                    AuthErrorBanner(message: auth.errorMessage!),
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

                  // Left-aligned like everything above it. This block used
                  // to be centred under a left-aligned page, and the privacy
                  // link wore a shield icon -- a padlock-for-security reflex
                  // that adds nothing to a word that already says it.
                  GestureDetector(
                    onTap: () => _openAuthPage(const SignUpScreen()),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14.5,
                          color: AuthColors.body,
                        ),
                        children: [
                          TextSpan(
                            text: context.tr("Don't have an account? "),
                          ),
                          TextSpan(
                            text: context.tr('Sign up'),
                            style: const TextStyle(
                              color: AuthColors.primaryBlue,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AuthColors.border, height: 1),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        LegalDocumentScreen.route(
                          title: 'Privacy policy',
                          url: Endpoints.privacy,
                        ),
                      ),
                      child: Text(
                        context.tr('Privacy policy').toUpperCase(),
                        style: FluentianTheme.label(),
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
    );
  }
}


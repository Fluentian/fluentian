import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart';
import 'auth_widgets.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _rememberMe = false;
  bool _hasError = false;

  void _handleSignIn() {
    // Navigate to HomeScreen on sign in
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
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
              const SizedBox(height: 32),
              const AuthLogo(),
              const SizedBox(height: 32),
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
                      'Welcome back',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AuthColors.heading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue learning.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AuthColors.placeholder,
                      ),
                    ),
                    const SizedBox(height: 32),

                    const AuthInputField(
                      label: 'Email address',
                      leftIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    const AuthInputField(
                      label: 'Password',
                      leftIcon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AuthColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _rememberMe = !_rememberMe),
                          child: Container(
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
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Remember me',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AuthColors.body,
                          ),
                        ),
                      ],
                    ),

                    if (_hasError) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                              color: AuthColors.errorText,
                              width: 3,
                            ),
                            top: const BorderSide(color: Color(0xFFFECACA)),
                            right: const BorderSide(color: Color(0xFFFECACA)),
                            bottom: const BorderSide(color: Color(0xFFFECACA)),
                          ),
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
                              child: Text(
                                'Incorrect email or password. Please try again.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AuthColors.body,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),
                    AuthButton(text: 'Sign in', onPressed: _handleSignIn),
                    const SizedBox(height: 20),
                    const AuthDivider(),
                    const SizedBox(height: 16),

                    AuthSocialButton(
                      text: 'Continue with Google',
                      icon: Icons.g_mobiledata,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    AuthSocialButton(
                      text: 'Continue with Apple',
                      icon: Icons.apple,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AuthColors.placeholder,
                    ),
                    children: const [
                      TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                          color: AuthColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'auth_widgets.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreedToTerms = false;
  String _selectedLang = 'English';

  void _showLangBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AuthColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Choose your language',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.heading,
                ),
              ),
              const SizedBox(height: 16),
              _buildLangOption(Iconsax.global, 'English'),
              _buildLangOption(Iconsax.global, 'አማርኛ (Amharic)'),
              _buildLangOption(Iconsax.global, 'Afaan Oromo'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption(IconData iconData, String name) {
    bool isSelected = _selectedLang == name;
    return InkWell(
      onTap: () {
        setState(() => _selectedLang = name);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(iconData, size: 20, color: AuthColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(fontSize: 16, color: AuthColors.body),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AuthColors.primary : AuthColors.border,
                  width: isSelected ? 5 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
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
                  const SizedBox(width: 48), // Balance for centering
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
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AuthColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your account',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AuthColors.heading,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start your French journey today.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AuthColors.placeholder,
                      ),
                    ),
                    const SizedBox(height: 32),

                    const AuthInputField(
                      label: 'Full name',
                      leftIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _showLangBottomSheet,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AuthColors.border),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.language_outlined,
                              color: AuthColors.placeholder,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedLang,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: AuthColors.heading,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AuthColors.placeholder,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _agreedToTerms
                                  ? AuthColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _agreedToTerms
                                    ? AuthColors.primary
                                    : AuthColors.border,
                              ),
                            ),
                            child: _agreedToTerms
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AuthColors.body,
                              ),
                              children: const [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AuthColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: AuthColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    AuthButton(text: 'Create account', onPressed: () {}),
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
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                ),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AuthColors.placeholder,
                    ),
                    children: const [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: AuthColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';
import 'otp_verification_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pageController = PageController();
  bool _agreedToTerms = false;
  bool _usernameEdited = false;
  int _step = 0;
  String _selectedLang = 'English';

  static const _stepCount = 4;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateGeneratedUsername(String value) {
    if (_usernameEdited) return;
    final generated = _generateUsername(value);
    if (_usernameController.text != generated) {
      _usernameController.text = generated;
    }
  }

  String _generateUsername(String name) {
    final cleaned = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final base = cleaned.length >= 3 ? cleaned : 'learner';
    final suffix = DateTime.now().millisecondsSinceEpoch % 1000;
    return '${base}_$suffix';
  }

  Future<void> _goNext() async {
    if (!_validateStep()) return;
    if (_step == _stepCount - 1) {
      await _handleSignUp();
      return;
    }
    final next = _step + 1;
    setState(() => _step = next);
    await _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goBack() async {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    final previous = _step - 1;
    setState(() => _step = previous);
    await _pageController.animateToPage(
      previous,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  bool _validateStep() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    String? message;

    switch (_step) {
      case 0:
        if (name.length < 2) {
          message = 'Please enter your name.';
        } else if (_usernameController.text.trim().isEmpty) {
          _usernameController.text = _generateUsername(name);
        }
      case 1:
        if (username.length < 3) {
          message = 'Username must be at least 3 characters.';
        } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
          message = 'Use only letters, numbers, and underscores.';
        }
      case 2:
        if (email.isEmpty || !email.contains('@')) {
          message = 'Please enter a valid email address.';
        }
      case 3:
        if (password.length < 8) {
          message = 'Password must be at least 8 characters.';
        } else if (!_agreedToTerms) {
          message = 'You must agree to the Terms of Service.';
        }
    }

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return false;
    }
    return true;
  }

  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await context.read<AuthProvider>().register(
      username: username,
      email: email,
      password: password,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email)),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted || success) return;
    final message = auth.errorMessage;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showLangBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
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
              _buildLangOption('English'),
              _buildLangOption('Amharic'),
              _buildLangOption('Afaan Oromo'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption(String name) {
    final isSelected = _selectedLang == name;
    return InkWell(
      onTap: () {
        setState(() => _selectedLang = name);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            const Icon(
              Icons.language_rounded,
              size: 20,
              color: AuthColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(fontSize: 16, color: AuthColors.body),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AuthColors.primary : AuthColors.border,
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
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AuthColors.body,
                          size: 24,
                        ),
                        onPressed: auth.isLoading ? null : _goBack,
                      ),
                      const Expanded(child: AuthLogo()),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
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
                          _StepProgress(step: _step, count: _stepCount),
                          const SizedBox(height: 28),
                          SizedBox(
                            height: 340,
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _NameStep(
                                  controller: _nameController,
                                  enabled: !auth.isLoading,
                                  onChanged: _updateGeneratedUsername,
                                  onSubmitted: (_) => _goNext(),
                                ),
                                _UsernameStep(
                                  controller: _usernameController,
                                  enabled: !auth.isLoading,
                                  onChanged: (_) => _usernameEdited = true,
                                  onSubmitted: (_) => _goNext(),
                                ),
                                _EmailStep(
                                  controller: _emailController,
                                  enabled: !auth.isLoading,
                                  onSubmitted: (_) => _goNext(),
                                ),
                                _PasswordStep(
                                  controller: _passwordController,
                                  enabled: !auth.isLoading,
                                  language: _selectedLang,
                                  agreedToTerms: _agreedToTerms,
                                  onLanguageTap: _showLangBottomSheet,
                                  onTermsTap: () => setState(
                                    () => _agreedToTerms = !_agreedToTerms,
                                  ),
                                  onSubmitted: (_) => _goNext(),
                                ),
                              ],
                            ),
                          ),
                          if (auth.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            _ErrorBanner(message: auth.errorMessage!),
                          ],
                          const SizedBox(height: 24),
                          AuthButton(
                            text: auth.isLoading
                                ? 'Creating account...'
                                : _step == _stepCount - 1
                                ? 'Create account'
                                : 'Continue',
                            onPressed: auth.isLoading ? null : _goNext,
                          ),
                          const SizedBox(height: 20),
                          const AuthDivider(),
                          const SizedBox(height: 16),
                          AuthSocialButton(
                            text: 'Continue with Google',
                            icon: Icons.g_mobiledata,
                            onPressed: auth.isLoading
                                ? null
                                : _handleGoogleSignUp,
                          ),
                          const SizedBox(height: 12),
                          AuthSocialButton(
                            text: 'Continue with Apple',
                            icon: Icons.apple,
                            onPressed: auth.isLoading ? null : () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: auth.isLoading
                        ? null
                        : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int step;
  final int count;

  const _StepProgress({required this.step, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final isActive = index <= step;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AuthColors.primary
                  : AuthColors.border.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AuthColors.heading,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.35,
            color: AuthColors.placeholder,
          ),
        ),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _NameStep({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'What is your name?',
          subtitle: 'We will use this to make your profile feel like yours.',
        ),
        const SizedBox(height: 28),
        AuthInputField(
          label: 'Full name',
          leftIcon: Icons.person_outline,
          keyboardType: TextInputType.name,
          controller: controller,
          enabled: enabled,
          hint: 'e.g. Sara Bekele',
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _UsernameStep extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _UsernameStep({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'Choose your username',
          subtitle: 'We generated one for you, but you can edit it.',
        ),
        const SizedBox(height: 28),
        AuthInputField(
          label: 'Username',
          leftIcon: Icons.alternate_email_rounded,
          controller: controller,
          enabled: enabled,
          hint: 'sara_123',
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _EmailStep extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  const _EmailStep({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepHeader(
          title: 'What is your email?',
          subtitle: 'We will send your verification code here.',
        ),
        const SizedBox(height: 28),
        AuthInputField(
          label: 'Email address',
          leftIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          controller: controller,
          enabled: enabled,
          onSubmitted: onSubmitted,
        ),
      ],
    );
  }
}

class _PasswordStep extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String language;
  final bool agreedToTerms;
  final VoidCallback onLanguageTap;
  final VoidCallback onTermsTap;
  final ValueChanged<String> onSubmitted;

  const _PasswordStep({
    required this.controller,
    required this.enabled,
    required this.language,
    required this.agreedToTerms,
    required this.onLanguageTap,
    required this.onTermsTap,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepHeader(
            title: 'Secure your account',
            subtitle: 'Add a password and confirm your preferences.',
          ),
          const SizedBox(height: 20),
          AuthInputField(
            label: 'Password',
            leftIcon: Icons.lock_outline,
            isPassword: true,
            controller: controller,
            enabled: enabled,
            hint: 'At least 8 characters',
            onSubmitted: onSubmitted,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: enabled ? onLanguageTap : null,
            borderRadius: BorderRadius.circular(12),
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
                      language,
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
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: enabled ? onTermsTap : null,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: agreedToTerms
                        ? AuthColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: agreedToTerms
                          ? AuthColors.primary
                          : AuthColors.border,
                    ),
                  ),
                  child: agreedToTerms
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'I agree to the Terms of Service and Privacy Policy.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AuthColors.body,
                  ),
                ),
              ),
            ],
          ),
        ],
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
            child: Text(
              message,
              style: GoogleFonts.inter(fontSize: 14, color: AuthColors.body),
            ),
          ),
        ],
      ),
    );
  }
}

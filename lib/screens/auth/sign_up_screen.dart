import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../legal_document_screen.dart';
import '../../core/theme.dart';
import '../../widgets/tibeb_band.dart';
import 'auth_widgets.dart';
import 'otp_verification_screen.dart';
import 'sign_in_screen.dart';
import '../../core/endpoints.dart';

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
  bool _languageInitialized = false;

  static const _stepCount = 4;

  String get _selectedLanguageCode => switch (_selectedLang) {
    'Amharic' => 'am',
    'Afaan Oromo' => 'om',
    _ => 'en',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_languageInitialized) return;
    final code = context.read<AppLocaleController>().locale.languageCode;
    _selectedLang = switch (code) {
      'am' => 'Amharic',
      'om' => 'Afaan Oromo',
      _ => 'English',
    };
    _languageInitialized = true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

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
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LText(message),
          duration: AuthProvider.errorDisplayDuration,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      username: username,
      email: email,
      password: password,
      languageCode: _selectedLanguageCode,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OtpVerificationScreen(email: email)),
      );
      return;
    }

    // A previous signup attempt (e.g. one that timed out client-side but
    // actually succeeded server-side) can leave this email already
    // registered, with no way back to OTP verification -- the backend
    // correctly rejects the duplicate, but without this, the only way out
    // was silently guessing to use Sign In instead.
    final message = authProvider.errorMessage;
    if (message != null && message.toLowerCase().contains('already exists')) {
      authProvider.clearError();
      await _showAlreadyRegisteredDialog(email);
    }
  }

  Future<void> _showAlreadyRegisteredDialog(String email) async {
    final goToSignIn = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.tr('Account already exists')),
        content: Text(
          dialogContext.tr(
            'An account with this email already exists. Sign in instead?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.tr('Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.tr('Sign in')),
          ),
        ],
      ),
    );
    if (goToSignIn == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SignInScreen(initialEmail: email)),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted || success) return;
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

  void _showLangBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
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
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  context.tr('Choose your language').toUpperCase(),
                  style: FluentianTheme.label(),
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
      onTap: () async {
        setState(() => _selectedLang = name);
        Navigator.pop(context);
        await context.read<AppLocaleController>().setLocale(
          Locale(_selectedLanguageCode),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: LText(
                name,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: AuthColors.heading,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AuthColors.primary,
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
                        borderRadius: BorderRadius.circular(0),
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
                            AuthErrorBanner(message: auth.errorMessage!),
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
                            onPressed: auth.isLoading
                                ? null
                                : _handleGoogleSignUp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 14,
                          color: AuthColors.placeholder,
                        ),
                        children: [
                          TextSpan(
                            text: context.tr('Already have an account? '),
                          ),
                          TextSpan(
                            text: context.tr('Sign in'),
                            style: const TextStyle(
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

/// Sign-up progress.
///
/// Was four rounded pill segments -- a third progress language in an app that
/// already draws progress one way. Same counter and same band as the
/// onboarding scaffold, so "how far through am I" looks identical wherever
/// the question comes up.
class _StepProgress extends StatelessWidget {
  final int step;
  final int count;

  const _StepProgress({required this.step, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${step + 1} / $count',
          style: FluentianTheme.label(),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween(end: (step + 1) / count),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => TibebBand(height: 12, progress: v),
        ),
      ],
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
        LText(
          title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        LText(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge,
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
          keyboardType: TextInputType.name,
          controller: controller,
          enabled: enabled,
          hint: 'Enter the name you would like learners to see',
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
          controller: controller,
          enabled: enabled,
          hint: 'Choose a memorable username, like sara_french',
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
          keyboardType: TextInputType.emailAddress,
          controller: controller,
          enabled: enabled,
          hint: 'Enter an email you can verify',
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
            isPassword: true,
            controller: controller,
            enabled: enabled,
            hint: 'Create a secure password with 8+ characters',
            onSubmitted: onSubmitted,
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: enabled ? onLanguageTap : null,
            borderRadius: BorderRadius.circular(0),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
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
                    child: LText(
                      language,
                      style: GoogleFonts.ibmPlexSans(
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
                    borderRadius: BorderRadius.circular(0),
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
                child: _TermsAgreementText(
                  onToggle: enabled ? onTermsTap : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "I agree to the Terms of Service and Privacy Policy." with the two
/// document names individually tappable (opening them in-app), while
/// tapping the rest of the sentence still toggles agreement -- previously
/// this was a single plain Text with no way to actually read either
/// document before agreeing to it.
class _TermsAgreementText extends StatefulWidget {
  final VoidCallback? onToggle;
  const _TermsAgreementText({required this.onToggle});

  @override
  State<_TermsAgreementText> createState() => _TermsAgreementTextState();
}

class _TermsAgreementTextState extends State<_TermsAgreementText> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => Navigator.of(context).push(
        LegalDocumentScreen.route(
          title: 'Terms and conditions',
          url: Endpoints.terms,
        ),
      );
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => Navigator.of(context).push(
        LegalDocumentScreen.route(
          title: 'Privacy policy',
          url: Endpoints.privacy,
        ),
      );
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.ibmPlexSans(fontSize: 13, color: AuthColors.body);
    final linkStyle = bodyStyle.copyWith(
      color: AuthColors.primary,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    return GestureDetector(
      onTap: widget.onToggle,
      child: Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            TextSpan(text: context.tr('I agree to the ')),
            TextSpan(
              text: context.tr('Terms of Service'),
              style: linkStyle,
              recognizer: _termsRecognizer,
            ),
            TextSpan(text: context.tr(' and ')),
            TextSpan(
              text: context.tr('Privacy Policy'),
              style: linkStyle,
              recognizer: _privacyRecognizer,
            ),
            TextSpan(text: context.tr('.')),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../core/app_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import '../../widgets/tibeb_band.dart';
import 'auth_widgets.dart';
import 'sign_in_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isSuccess = false;
  bool _isLoading = false;
  String _code = "";
  String _pwd1 = "";
  String _pwd2 = "";

  int _getPwdStrength(String pwd) {
    if (pwd.isEmpty) return 0;
    if (pwd.length < 3) return 1;
    if (pwd.length < 7) return 2;
    if (pwd.length < 10) return 3;
    return 4;
  }

  Future<void> _handleResetPassword() async {
    final code = _code.trim();
    final pwd = _pwd1;

    if (code.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: LText('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().resetPasswordWithOtp(
      code,
      pwd,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      setState(() => _isSuccess = true);
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
              const SizedBox(height: 32),
              const AuthLogo(),
              const SizedBox(height: 32),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSuccess ? _buildStateB() : _buildStateA(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateA() {
    int strength = _getPwdStrength(_pwd1);
    bool pwdMatch = _pwd1 == _pwd2 && _pwd1.isNotEmpty;
    bool showMismatchError = _pwd2.isNotEmpty && !pwdMatch;
    final auth = context.watch<AuthProvider>();

    return Container(
      key: const ValueKey('stateA'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      decoration: BoxDecoration(
        color: AuthColors.cardBg,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: AuthColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LText(
            'Set a new password',
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
                TextSpan(text: context.tr('We sent a verification code to ')),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AuthColors.heading,
                  ),
                ),
                TextSpan(
                  text: context.tr(
                    '. Enter it below along with your new password.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AuthInputField(
            label: 'Verification code',
            keyboardType: TextInputType.number,
            hint: 'Enter the 6-digit code from your email',
            onChanged: (val) => setState(() => _code = val),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          AuthInputField(
            label: 'New password',
            isPassword: true,
            hint: 'Use 8 or more characters',
            onChanged: (val) => setState(() => _pwd1 = val),
            enabled: !_isLoading,
          ),
          if (_pwd1.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildStrengthIndicator(strength),
          ],
          const SizedBox(height: 16),

          AuthInputField(
            label: 'Confirm password',
            isPassword: !pwdMatch,
            hint: 'Re-enter your new password',
            errorText: showMismatchError ? 'Passwords do not match' : null,
            onChanged: (val) => setState(() => _pwd2 = val),
            enabled: !_isLoading,
            rightWidget: pwdMatch
                ? const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.check_circle,
                      color: AuthColors.success,
                      size: 20,
                    ),
                  )
                : null,
          ),

          if (auth.errorMessage != null) ...[
            const SizedBox(height: 20),
            AuthErrorBanner(message: auth.errorMessage!),
          ],

          const SizedBox(height: 28),
          AuthButton(
            text: _isLoading ? 'Updating…' : 'Reset password',
            onPressed: (pwdMatch && _code.isNotEmpty && !_isLoading)
                ? _handleResetPassword
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator(int str) {
    // The "Fair" step used to be #F59E0B, an amber left over from the old
    // palette and the only place it survived. The word is what actually
    // carries the verdict here -- the bars alone would be colour-only.
    Color c = AuthColors.border;
    String label = "Weak";
    if (str == 1) {
      c = AuthColors.errorText;
      label = "Weak";
    } else if (str == 2) {
      c = FluentianColors.warning;
      label = "Fair";
    } else if (str >= 3) {
      c = FluentianColors.success;
      label = str == 4 ? "Strong" : "Good";
    }

    return Row(
      children: [
        Expanded(child: _buildSegment(str >= 1 ? c : AuthColors.border)),
        const SizedBox(width: 4),
        Expanded(child: _buildSegment(str >= 2 ? c : AuthColors.border)),
        const SizedBox(width: 4),
        Expanded(child: _buildSegment(str >= 3 ? c : AuthColors.border)),
        const SizedBox(width: 4),
        Expanded(child: _buildSegment(str >= 4 ? c : AuthColors.border)),
        const SizedBox(width: 12),
        Text(
          context.tr(label).toUpperCase(),
          style: FluentianTheme.label(color: c),
        ),
      ],
    );
  }

  Widget _buildSegment(Color c) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  Widget _buildStateB() {
    return Container(
      key: const ValueKey('stateB'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        color: AuthColors.cardBg,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(color: AuthColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Was a 72px mint circle with a tick, centred -- the success
          // illustration every flow ships. The band already means "complete"
          // everywhere else in this app, so it means it here too.
          const TibebBand(height: 16),
          const SizedBox(height: 22),
          LText(
            'Password updated',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          LText(
            'Your password has been changed. You can sign in with it now.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          AuthButton(
            text: 'Back to sign in',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

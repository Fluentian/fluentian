import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().resetPasswordWithOtp(code, pwd);
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AuthColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set a new password',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AuthColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AuthColors.placeholder,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'We sent a verification code to '),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AuthColors.heading,
                  ),
                ),
                const TextSpan(text: '. Enter it below along with your new password.'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AuthInputField(
            label: 'Verification code',
            leftIcon: Icons.vpn_key_outlined,
            keyboardType: TextInputType.number,
            onChanged: (val) => setState(() => _code = val),
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),

          AuthInputField(
            label: 'New password',
            leftIcon: Icons.lock_outline,
            isPassword: true,
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
            leftIcon: Icons.lock_outline,
            isPassword: !pwdMatch,
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
            _ErrorBanner(message: auth.errorMessage!),
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
    Color c = AuthColors.border;
    String label = "Weak";
    if (str == 1) {
      c = AuthColors.errorText;
      label = "Weak";
    } else if (str == 2) {
      c = const Color(0xFFF59E0B);
      label = "Fair";
    } else if (str >= 3) {
      c = AuthColors.primary;
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
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: c,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSegment(Color c) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(4),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AuthColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
              border: Border.all(color: AuthColors.success, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.check, color: AuthColors.success, size: 32),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Password updated!',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AuthColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your password has been successfully changed. You can now sign in.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AuthColors.placeholder,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
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
          const Icon(Icons.warning_amber_rounded, color: AuthColors.errorText, size: 18),
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

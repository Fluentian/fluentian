import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/opportunities_api.dart';

class ProfessionalApplicationScreen extends StatefulWidget {
  final Opportunity opportunity;
  const ProfessionalApplicationScreen({super.key, required this.opportunity});

  @override
  State<ProfessionalApplicationScreen> createState() =>
      _ProfessionalApplicationScreenState();
}

class _ProfessionalApplicationScreenState
    extends State<ProfessionalApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = OpportunitiesApi();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _motivationController = TextEditingController();
  final _resumeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _motivationController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _api.applyForOpportunity(widget.opportunity.id, {
        'full_name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'education': _educationController.text,
        'experience': _experienceController.text,
        'skills': _skillsController.text,
        'motivation': _motivationController.text,
        'resume_url': _resumeController.text,
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Apply: ${widget.opportunity.title}',
          style: GoogleFonts.inter(fontSize: 16),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: FluentianColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional Application',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your details to apply for this opportunity.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: FluentianColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Personal Information'),
              _buildField(
                'Full Name',
                _nameController,
                icon: Icons.person_outline,
                placeholder:
                    'Enter your name as it appears on official documents',
              ),
              _buildField(
                'Email Address',
                _emailController,
                icon: Icons.email_outlined,
                isEmail: true,
                placeholder: 'name@example.com',
              ),
              _buildField(
                'Phone Number',
                _phoneController,
                icon: Icons.phone_outlined,
                placeholder: 'Include your country code, for example +251…',
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Professional Profile'),
              _buildField(
                'Educational Background',
                _educationController,
                maxLines: 2,
                icon: Icons.school_outlined,
                placeholder:
                    'Your degree, school, field of study, or current level',
              ),
              _buildField(
                'Relevant Experience',
                _experienceController,
                maxLines: 3,
                icon: Icons.work_outline,
                placeholder:
                    'Describe experience that is relevant to this opportunity',
              ),
              _buildField(
                'Key Skills',
                _skillsController,
                icon: Icons.psychology_outlined,
                placeholder:
                    'Example: French B2, public speaking, community leadership',
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Statement of Intent'),
              _buildField(
                'Motivation Letter',
                _motivationController,
                maxLines: 5,
                icon: Icons.description_outlined,
                placeholder:
                    'Explain why this opportunity matters to you and what you bring',
              ),
              _buildField(
                'Resume Link (LinkedIn/Drive)',
                _resumeController,
                icon: Icons.link_rounded,
                isRequired: false,
                placeholder:
                    'Paste a public LinkedIn, Google Drive, or portfolio link',
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FluentianColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit Application',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: FluentianColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? icon,
    bool isEmail = false,
    bool isRequired = true,
    String? placeholder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: FluentianColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.inter(fontSize: 14),
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
            validator: (val) {
              if (isRequired && (val == null || val.isEmpty)) {
                return 'This field is required';
              }
              if (isEmail && val != null && !val.contains('@')) {
                return 'Invalid email';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: icon != null
                  ? Icon(icon, size: 18, color: FluentianColors.textSecondary)
                  : null,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: FluentianColors.primary),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }
}

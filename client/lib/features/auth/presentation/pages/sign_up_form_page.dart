import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/widgets/custom_text_form_field.dart';
import 'profile_setup_page.dart';
import 'auth_page.dart';

class SignUpFormPage extends StatefulWidget {
  const SignUpFormPage({super.key});

  @override
  State<SignUpFormPage> createState() => _SignUpFormPageState();
}

class _SignUpFormPageState extends State<SignUpFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isEmailValid = false;
  bool _isStudentIdValid = false;
  
  bool _hasEightChars = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _studentIdController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final pass = _passwordController.text;
    setState(() {
      _hasEightChars = pass.length >= 8;
      _hasUppercase = pass.contains(RegExp(r'[A-Z]'));
      _hasNumber = pass.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  void _onEmailChanged(String value) {
    setState(() {
      final trimmedEmail = value.trim().toLowerCase();
      final domain = '@iskolarngbayan.pup.edu.ph';
      _isEmailValid = trimmedEmail.endsWith(domain) && trimmedEmail.length > domain.length;
    });
  }

  void _onStudentIdChanged(String value) {
    setState(() {
      _isStudentIdValid = RegExp(r'^\d{4}-\d{5}-SM-\d$').hasMatch(value);
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    
    final trimmedEmail = value.trim().toLowerCase();
    const domain = '@iskolarngbayan.pup.edu.ph';
    
    if (!trimmedEmail.endsWith(domain)) {
      return 'Must be a PUP webmail address (@iskolarngbayan.pup.edu.ph)';
    }
    
    if (trimmedEmail.length <= domain.length) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) return 'Student ID is required';
    if (!RegExp(r'^\d{4}-\d{5}-SM-\d$').hasMatch(value)) {
      return 'Format must be YYYY-NNNNN-SM-0';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (!_hasEightChars || !_hasUppercase || !_hasNumber || !_hasSpecialChar) {
      return 'Please meet all password requirements';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Step 1/3',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildReq(String text, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check,
          size: 14,
          color: isMet ? Colors.blue.shade500 : Colors.grey.shade400,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: isMet ? Colors.blue.shade500 : Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildReq('At least 8 characters', _hasEightChars)),
              Expanded(child: _buildReq('One uppercase letter', _hasUppercase)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildReq('One number', _hasNumber)),
              Expanded(child: _buildReq('One special character', _hasSpecialChar)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        leadingWidth: 64,
        title: Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  'Register as a PUP Sta. Maria Iskolar ng Bayan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildStepIndicator(),

              const SizedBox(height: 32),

              CustomTextFormField(
                label: 'PUP Webmail Address *',
                hintText: '...iskolarngbayan.pup.edu.ph',
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                prefixIcon: 'email',
                onChanged: _onEmailChanged,
                isValid: _isEmailValid,
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                label: 'Student ID Number *',
                hintText: '2023-00079-SM-0',
                controller: _studentIdController,
                prefixIcon: 'badge',
                onChanged: _onStudentIdChanged,
                isValid: _isStudentIdValid,
                helperText: 'SM = Sta. Maria campus code',
                validator: _validateStudentId,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                label: 'Create Password *',
                hintText: '••••••••',
                inputType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _passwordController,
                prefixIcon: 'password',
                validator: _validatePassword,
              ),
              
              _buildPasswordStrengthIndicator(),

              const SizedBox(height: 12),

              CustomTextFormField(
                label: 'Confirm Password *',
                hintText: '••••••••',
                inputType: TextInputType.visiblePassword,
                isPassword: true,
                controller: _confirmPasswordController,
                prefixIcon: 'password',
                validator: _validateConfirmPassword,
                isValid: _confirmPasswordController.text.isNotEmpty && _confirmPasswordController.text == _passwordController.text,
                onChanged: (v) => setState(() {}),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Navigate to Profile Setup (Step 2)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileSetupPage(
                            email: _emailController.text,
                            studentId: _studentIdController.text,
                            password: _passwordController.text,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: Colors.blue.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    'Continue to Profile Setup',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Log In',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}


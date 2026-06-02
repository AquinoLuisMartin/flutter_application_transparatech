import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/widgets/custom_text_form_field.dart';
import 'package:flutter_application_transparatech/core/widgets/custom_dropdown_field.dart';
import 'package:flutter_application_transparatech/core/network/http_client.dart';
import 'package:flutter_application_transparatech/core/utils/logger.dart';
import 'dart:convert';
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
  
  String? _selectedRole = 'Student';
  bool _isEmailValid = false;
  bool _isStudentIdValid = false;
  bool _isLoading = false;
  
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
      final domain = _selectedRole == 'Admin' ? '@pup.edu.ph' : '@iskolarngbayan.pup.edu.ph';
      _isEmailValid = trimmedEmail.endsWith(domain) && trimmedEmail.length > domain.length;
    });
  }

  void _onStudentIdChanged(String value) {
    setState(() {
      if (_selectedRole == 'Admin') {
        _isStudentIdValid = RegExp(r'^FA-\d{4}-SM-\d{4}$').hasMatch(value);
      } else {
        _isStudentIdValid = RegExp(r'^\d{4}-\d{5}-SM-\d$').hasMatch(value);
      }
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    
    final trimmedEmail = value.trim().toLowerCase();
    final domain = _selectedRole == 'Admin' ? '@pup.edu.ph' : '@iskolarngbayan.pup.edu.ph';
    
    if (!trimmedEmail.endsWith(domain)) {
      return 'Must be a PUP address ($domain)';
    }
    
    if (trimmedEmail.length <= domain.length) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return _selectedRole == 'Admin' ? 'Faculty Number is required' : 'Student ID is required';
    }
    
    if (_selectedRole == 'Admin') {
      if (!RegExp(r'^FA-\d{4}-SM-\d{4}$').hasMatch(value)) {
        return 'Format must be FA-XXXX-SM-YYYY';
      }
    } else {
      if (!RegExp(r'^\d{4}-\d{5}-SM-\d$').hasMatch(value)) {
        return 'Format must be YYYY-NNNNN-SM-0';
      }
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

  Future<void> _handleSignupContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = ApiClient();
      final response = await client.post(
        '/api/auth/signup',
        body: {
          'email': _emailController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'password': _passwordController.text,
          'role': _selectedRole,
          'fullName': _emailController.text.split('@')[0], // Will be overridden in next step
        },
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final jsonResponse = response.data;
        // Store the token (you'll need to set up secure storage)
        AppLogger.info('Signup successful', tag: 'SignUp');
        
        // Navigate to Profile Setup (Step 2)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSetupPage(
              email: _emailController.text,
              studentId: _studentIdController.text,
              password: _passwordController.text,
              token: jsonResponse['token'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['error'] ?? 'Signup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Signup error: $e', tag: 'SignUp');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  double get _strengthScore {
    int score = 0;
    if (_passwordController.text.isEmpty) return 0.0;
    if (_hasEightChars) score++;
    if (_hasUppercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    return score / 4.0;
  }

  String get _strengthText {
    if (_passwordController.text.isEmpty) return '';
    final score = _strengthScore;
    if (score <= 0.25) return 'Weak';
    if (score <= 0.5) return 'Fair';
    if (score <= 0.75) return 'Good';
    return 'Strong';
  }

  Color get _strengthColor {
    final score = _strengthScore;
    if (score <= 0.25) return Colors.red.shade400;
    if (score <= 0.5) return Colors.orange.shade400;
    if (score <= 0.75) return Colors.blue.shade400;
    return Colors.green.shade400;
  }

  Widget _buildReq(String text, bool isMet) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_passwordController.text.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Password Strength',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _strengthText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _strengthColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _strengthScore,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),
          ],
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
                hintText: _selectedRole == 'Admin' ? 'name@pup.edu.ph' : '...iskolarngbayan.pup.edu.ph',
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                prefixIcon: 'email',
                onChanged: _onEmailChanged,
                isValid: _isEmailValid,
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),

              CustomDropdownField<String>(
                label: 'I am a *',
                value: _selectedRole,
                prefixIcon: 'role',
                items: const [
                  DropdownMenuItem(value: 'Student', child: Text('Student')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                    // Re-validate ID and Email when role changes
                    _onStudentIdChanged(_studentIdController.text);
                    _onEmailChanged(_emailController.text);
                  });
                },
                validator: (value) => value == null ? 'Please select a role' : null,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                label: _selectedRole == 'Admin' ? 'Faculty Number *' : 'Student ID Number *',
                hintText: _selectedRole == 'Admin' ? 'FA-1234-SM-2023' : '2023-00079-SM-0',
                controller: _studentIdController,
                prefixIcon: 'badge',
                onChanged: _onStudentIdChanged,
                isValid: _isStudentIdValid,
                helperText: _selectedRole == 'Admin' 
                    ? 'FA = Faculty, SM = Sta. Maria' 
                    : 'SM = Sta. Maria campus code',
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
                  onPressed: _isLoading ? null : _handleSignupContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: Colors.blue.withValues(alpha: 0.3),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
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


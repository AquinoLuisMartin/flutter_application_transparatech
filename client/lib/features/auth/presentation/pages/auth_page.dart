import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/widgets/custom_text_form_field.dart';
import 'package:flutter_application_transparatech/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/sign_up_form_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/forgot_password_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailValid = false;
  bool _keepSignedIn = false;

  void _onEmailChanged(String value) {
    setState(() {
      final trimmedEmail = value.trim().toLowerCase();
      const domain = '@iskolarngbayan.pup.edu.ph';
      _isEmailValid =
          trimmedEmail.endsWith(domain) && trimmedEmail.length > domain.length;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final trimmedEmail = value.trim().toLowerCase();
    const domain = '@iskolarngbayan.pup.edu.ph';
    if (!trimmedEmail.endsWith(domain)) {
      return 'Must use @iskolarngbayan.pup.edu.ph email';
    }
    if (trimmedEmail.length <= domain.length) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildSocialOrQuickAccessButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.grey.shade700, size: 20),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
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
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Text(
                    'Login',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome back to the app',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Form Fields (No Card)
                  CustomTextFormField(
                    label: 'Email Address',
                    hintText: 'username@iskolarngbayan.pup.edu.ph',
                    inputType: TextInputType.emailAddress,
                    controller: _emailController,
                    onChanged: _onEmailChanged,
                    isValid: _isEmailValid,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 24),
                  CustomTextFormField(
                    label: 'Password',
                    hintText: '••••••••••••',
                    inputType: TextInputType.visiblePassword,
                    isPassword: true,
                    controller: _passwordController,
                    validator: _validatePassword,
                    labelTrailing: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B48F6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Keep me signed in
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _keepSignedIn,
                          onChanged: (value) {
                            setState(() {
                              _keepSignedIn = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF3B48F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Keep me signed in',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Log In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Simply navigate to dashboard for now
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B48F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Separator
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or sign in with',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Quick Access / Google Alternative (Kept meaning, changed layout)
                  _buildSocialOrQuickAccessButton(
                    label: 'Continue with Biometrics',
                    icon: Icons.fingerprint,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildSocialOrQuickAccessButton(
                    label: 'Continue with PIN',
                    icon: Icons.pin_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 48),

                  // Create Account Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpFormPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Create an account',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B48F6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

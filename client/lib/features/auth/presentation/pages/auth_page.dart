import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/sign_up_form_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_dashboard_page.dart';

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
      _isEmailValid = (trimmedEmail.endsWith('@pup.edu.ph') && trimmedEmail.length > 11) ||
          (trimmedEmail.endsWith('@iskolarngbayang.pup.edu.ph') && trimmedEmail.length > 25) ||
          (trimmedEmail.endsWith('@iskolarngbayan.pup.edu.ph') && trimmedEmail.length > 24);
    });
  }

  String? get _detectedRole {
    final email = _emailController.text.trim().toLowerCase();
    if (email.endsWith('@pup.edu.ph') && email.length > 11) {
      return 'Admin';
    } else if ((email.endsWith('@iskolarngbayang.pup.edu.ph') && email.length > 25) ||
               (email.endsWith('@iskolarngbayan.pup.edu.ph') && email.length > 24)) {
      return 'Student / Officer';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final trimmedEmail = value.trim().toLowerCase();
    if (trimmedEmail.endsWith('@pup.edu.ph') && trimmedEmail.length > 11) {
      return null;
    }
    if ((trimmedEmail.endsWith('@iskolarngbayang.pup.edu.ph') && trimmedEmail.length > 25) ||
        (trimmedEmail.endsWith('@iskolarngbayan.pup.edu.ph') && trimmedEmail.length > 24)) {
      return null;
    }
    return 'Must use @iskolarngbayang.pup.edu.ph (Student/Officer) or @pup.edu.ph (Admin)';
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        final user = authProvider.currentUser;
        
        if (user?.roleId == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardPage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardPage(),
            ),
          );
        }
      } else if (mounted) {
        showAlertDialog(
          context: context,
          title: 'Login Failed',
          message: authProvider.errorMessage ?? 'Invalid email or password',
          isError: true,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: VeriFiColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: VeriFiColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: VeriFiSpacing.s24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: VeriFiSpacing.s24),
                  // Header
                  Text(
                    'Login',
                    style: VeriFiTypography.pageTitle.copyWith(
                      color: VeriFiColors.primary,
                    ),
                  ),
                  const SizedBox(height: VeriFiSpacing.s8),
                  Text(
                    'Welcome back to the app',
                    style: VeriFiTypography.bodyText.copyWith(
                      color: VeriFiColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: VeriFiSpacing.s48),

                  // Form Fields
                  CustomTextFormField(
                    label: 'Email Address',
                    hintText: 'username@iskolarngbayang.pup.edu.ph',
                    inputType: TextInputType.emailAddress,
                    controller: _emailController,
                    onChanged: _onEmailChanged,
                    isValid: _isEmailValid,
                    validator: _validateEmail,
                    helperText: _detectedRole != null 
                        ? 'Detected Role: $_detectedRole' 
                        : 'Use @iskolarngbayang.pup.edu.ph for Students/Officers or @pup.edu.ph for Admins',
                  ),
                  const SizedBox(height: VeriFiSpacing.s24),
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
                          color: VeriFiColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: VeriFiSpacing.s24),
                  
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
                          activeColor: VeriFiColors.primary,
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
                          color: VeriFiColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VeriFiSpacing.s32),

                  // Log In Button
                  PrimaryButton(
                    label: 'Login',
                    onPressed: _handleLogin,
                    isLoading: authProvider.isLoading,
                  ),
                  const SizedBox(height: VeriFiSpacing.s48),

                  // Separator
                  DividerWithText(text: 'or sign in with'),
                  const SizedBox(height: VeriFiSpacing.s32),

                  // Quick Access / Alternative options
                  SecondaryButton(
                    label: 'Continue with Biometrics',
                    icon: Icons.fingerprint_outlined,
                    onPressed: () {},
                  ),
                  const SizedBox(height: VeriFiSpacing.s16),
                  SecondaryButton(
                    label: 'Continue with PIN',
                    icon: Icons.pin_outlined,
                    onPressed: () {},
                  ),
                  const SizedBox(height: VeriFiSpacing.s48),

                  // Create Account Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
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
                          color: VeriFiColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: VeriFiSpacing.s40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

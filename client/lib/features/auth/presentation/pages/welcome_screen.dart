import 'package:flutter/material.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'sign_up_form_page.dart';
import 'auth_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeriFiColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with white background
            Container(
              width: double.infinity,
              color: VeriFiColors.surface,
              padding: const EdgeInsets.symmetric(
                vertical: VeriFiSpacing.s48,
                horizontal: VeriFiSpacing.s24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // VeriFi Logo
                  Image.asset(
                    'assets/images/VeriFi Logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: VeriFiSpacing.s24),
                  // Title
                  Text(
                    'Welcome to VeriFi',
                    style: VeriFiTypography.pageTitle.copyWith(
                      color: VeriFiColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: VeriFiSpacing.s8),
                  // Subtitle
                  Text(
                    'Financial transparency for Iskolar ng Bayan',
                    style: VeriFiTypography.bodyText.copyWith(
                      color: VeriFiColors.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: VeriFiSpacing.s24,
                  vertical: VeriFiSpacing.s32,
                ),
                child: Column(
                  children: [
                    // Description text
                    Text(
                      'Secure financial document management and audit verification for PUP Sta. Maria student organizations. Powered by AI and SHA-256 hashing.',
                      style: VeriFiTypography.bodyText.copyWith(
                        color: VeriFiColors.textGrey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VeriFiSpacing.s40),
                    // Sign Up Button
                    PrimaryButton(
                      label: 'Sign Up',
                      icon: Icons.person_add_outlined,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpFormPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: VeriFiSpacing.s16),
                    // Log In Button
                    SecondaryButton(
                      label: 'Log In',
                      icon: Icons.login_outlined,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: VeriFiSpacing.s24),
                    // Or continue with
                    Text(
                      'or continue with',
                      style: VeriFiTypography.label.copyWith(
                        color: VeriFiColors.textLight,
                      ),
                    ),
                    const SizedBox(height: VeriFiSpacing.s16),
                    // Google Sign In Button
                    SecondaryButton(
                      label: 'Sign in with Google',
                      icon: Icons.g_mobiledata_outlined,
                      onPressed: () {
                        // TODO: Google sign in
                      },
                    ),
                    const SizedBox(height: VeriFiSpacing.s40),
                    // Terms and Privacy Policy
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: VeriFiTypography.label.copyWith(
                          color: VeriFiColors.textLight,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(
                            text: 'By continuing, you agree to VeriFi\'s ',
                          ),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: VeriFiColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: VeriFiColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







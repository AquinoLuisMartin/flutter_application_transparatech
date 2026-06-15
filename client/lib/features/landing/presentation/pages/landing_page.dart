import 'package:flutter/material.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/welcome_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeriFiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: VeriFiSpacing.s24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: VeriFiSpacing.s40),
                // Logo and Title Section
                Column(
                  children: [
                    // VeriFi Logo
                    Image.asset(
                      'assets/images/VeriFi Logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: VeriFiSpacing.s40),
                    
                    // Title
                    Text(
                      'VeriFi',
                      style: VeriFiTypography.pageTitle.copyWith(
                        fontSize: 40,
                        color: VeriFiColors.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: VeriFiSpacing.s16),
                    
                    // Subtitle 1
                    Text(
                      'AI-Powered Financial Transparency',
                      style: VeriFiTypography.sectionTitle.copyWith(
                        fontSize: 16,
                        color: VeriFiColors.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    
                    // Subtitle 2
                    Text(
                      '& Audit Verification System',
                      style: VeriFiTypography.bodyText.copyWith(
                        color: VeriFiColors.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: VeriFiSpacing.s48),
                
                // Features Section using VeriFiCard
                Column(
                  children: [
                    VeriFiCard(
                      icon: const Icon(Icons.document_scanner_outlined, color: VeriFiColors.primary),
                      title: 'Digital Submission & Tracking',
                      description: 'Submit and track financial records in real-time.',
                      action: const Icon(Icons.check_circle, color: VeriFiColors.success, size: 20),
                    ),
                    VeriFiCard(
                      icon: const Icon(Icons.analytics_outlined, color: VeriFiColors.primary),
                      title: 'AI Data Extraction',
                      description: 'Automatic verification and data extraction from receipts.',
                      action: const Icon(Icons.check_circle, color: VeriFiColors.success, size: 20),
                    ),
                    VeriFiCard(
                      icon: const Icon(Icons.security_outlined, color: VeriFiColors.primary),
                      title: 'Secure Hashing',
                      description: 'Ensuring audit integrity via hash-based record validation.',
                      action: const Icon(Icons.check_circle, color: VeriFiColors.success, size: 20),
                    ),
                  ],
                ),
                
                const SizedBox(height: VeriFiSpacing.s40),
                
                // Get Started Button
                PrimaryButton(
                  label: 'Get Started',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    try {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
                
                const SizedBox(height: VeriFiSpacing.s32),
                
                // Footer
                Text(
                  'PUP Sta. Maria Student Organization Portal',
                  style: VeriFiTypography.label.copyWith(
                    color: VeriFiColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: VeriFiSpacing.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


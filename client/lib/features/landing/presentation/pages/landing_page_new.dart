import 'package:flutter/material.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/auth_page.dart';

/// Landing page widget - Initial app entry point with AI-powered verification theme
class LandingPage extends StatelessWidget {
  /// Constructor for LandingPage
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a2a4e), // Dark blue
              const Color(0xFF0f1e35), // Darker blue
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Shield Icon with checkmark
                  _buildShieldIcon(context),
                  const SizedBox(height: 32),
                  // App Title
                  Text(
                    'Verifi',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'AI-Powered Financial Transparency\n& Audit Verification System',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Feature Cards
                  _buildFeatureCard(
                    context,
                    number: '01',
                    title: 'Digital Document\nSubmission & Tracking',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    number: '02',
                    title: 'AI-Powered Data\nExtraction & Analysis',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    number: '03',
                    title: 'Secure Hash-Based\nData Integrity',
                  ),
                  const SizedBox(height: 48),
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthPage(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Footer text
                  Text(
                    'PUP Sta. Maria Student Organization Panel',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build shield icon widget with blue border and checkmark
  Widget _buildShieldIcon(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF4A90E2),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.verified_user,
        size: 60,
        color: Color(0xFF4A90E2),
      ),
    );
  }

  /// Build feature card widget with number, title, and border
  Widget _buildFeatureCard(
    BuildContext context, {
    required String number,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF4A90E2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1e3a5f).withValues(alpha: 0.4),
            const Color(0xFF0f1e35).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF4A90E2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF4A90E2),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title text
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


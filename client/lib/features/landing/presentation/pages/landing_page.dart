import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/welcome_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  // Logo and Title Section
                  Column(
                    children: [
                      // Verifi Logo
                      Image.asset(
                        'assets/images/VeriFi Logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        'Verifi',
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A3A5C),
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Subtitle 1
                      Text(
                        'AI-Powered Financial Transparency',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2d5a7b),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Subtitle 2
                      Text(
                        '& Audit Verification System',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF5A7A9F),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Features Section
                  Column(
                    children: [
                      _FeatureCard(
                        number: '01',
                        title: 'Digital Document Submission & Tracking',
                      ),
                      const SizedBox(height: 16),
                      _FeatureCard(
                        number: '02',
                        title: 'AI-Powered Data Extraction & Analysis',
                      ),
                      const SizedBox(height: 16),
                      _FeatureCard(
                        number: '03',
                        title: 'Secure Hash-Based Data Integrity',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          Navigator.push(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A9BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Footer
                  Text(
                    'PUP Sta. Maria Student Organization Portal',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5A7A9F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String number;
  final String title;

  const _FeatureCard({
    required this.number,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD1E1F0),
          width: 1,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Number Indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF4A9BFF).withValues(alpha: 0.1),
              border: Border.all(
                color: const Color(0xFF4A9BFF).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A9BFF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A3A5C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


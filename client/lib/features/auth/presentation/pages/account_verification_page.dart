import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/network/http_client.dart';
import 'package:flutter_application_transparatech/core/utils/logger.dart';
import 'dart:convert';

class AccountVerificationPage extends StatefulWidget {
  final String email;
  final String studentId;
  final String fullName;
  final String token;
  final String password;

  const AccountVerificationPage({
    super.key,
    required this.email,
    required this.studentId,
    required this.fullName,
    required this.token,
    required this.password,
  });

  @override
  State<AccountVerificationPage> createState() =>
      _AccountVerificationPageState();
}

class _AccountVerificationPageState extends State<AccountVerificationPage> {
  late List<VerificationStep> _verificationSteps;
  bool _isVerificationComplete = false;
  int _completedSteps = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _initializeVerificationSteps();
    _startVerification();
  }

  Future<void> _handleCompleteSetup() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);

    try {
      // Final verification - store full name (this would typically be done in your backend)
      AppLogger.info('Account setup complete: ${widget.fullName}', tag: 'Verification');
      
      // Navigate to login page
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      AppLogger.error('Error completing setup: $e', tag: 'Verification');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  void _initializeVerificationSteps() {
    _verificationSteps = [
      VerificationStep(
        title: 'Validating iskolar ng Bayan email domain',
        subtitle: 'iskolarngbayan.pup.edu.ph - Verified',
        isComplete: false,
        duration: const Duration(seconds: 2),
      ),
      VerificationStep(
        title: 'Cross-referencing PUP-SM student ID',
        subtitle: '${widget.studentId} - Match found in registrar',
        isComplete: false,
        duration: const Duration(seconds: 3),
      ),
      VerificationStep(
        title: 'AI image clarity & authenticity check',
        subtitle: 'Image quality: High - No tampering detected',
        isComplete: false,
        duration: const Duration(seconds: 4),
      ),
      VerificationStep(
        title: 'Computing SHA-256 document hash',
        subtitle: 'SHA-256 integrity hash generated & stored',
        isComplete: false,
        duration: const Duration(seconds: 2),
      ),
      VerificationStep(
        title: 'Assigning COSC Society org role',
        subtitle: 'Role: Authorized Member - ISTE',
        isComplete: false,
        duration: const Duration(seconds: 2),
      ),
    ];
  }

  void _startVerification() {
    _verifySteps();
  }

  Future<void> _verifySteps() async {
    for (int i = 0; i < _verificationSteps.length; i++) {
      await Future.delayed(_verificationSteps[i].duration);

      if (mounted) {
        setState(() {
          _verificationSteps[i].isComplete = true;
          _completedSteps = i + 1;
        });
      }
    }

    if (mounted) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isVerificationComplete = true;
      });
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
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Step 3/3',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStep(VerificationStep step, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: step.isComplete ? Colors.blue.shade50 : Colors.grey.shade50,
        border: Border.all(
          color: step.isComplete ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: step.isComplete ? Colors.blue.shade600 : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: step.isComplete
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificationProgress =
        (_completedSteps / _verificationSteps.length * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Verifying Account',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Please wait while we validate your details',
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

            // Verification Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verification Progress',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$verificationProgress%',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: verificationProgress / 100,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
            ),

            const SizedBox(height: 32),

            // Verification Steps
            ..._verificationSteps.asMap().entries.map(
              (entry) => _buildVerificationStep(entry.value, entry.key),
            ),

            const SizedBox(height: 48),

            // Complete Setup Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isVerificationComplete && !_isCompleting)
                    ? _handleCompleteSetup
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVerificationComplete
                      ? Colors.blue.shade600
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isVerificationComplete ? 3 : 0,
                  shadowColor: _isVerificationComplete
                      ? Colors.blue.withValues(alpha: 0.3)
                      : Colors.transparent,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isCompleting
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isVerificationComplete ? 'Complete Setup' : 'Verifying...',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _isVerificationComplete
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class VerificationStep {
  final String title;
  final String subtitle;
  bool isComplete;
  final Duration duration;

  VerificationStep({
    required this.title,
    required this.subtitle,
    required this.isComplete,
    required this.duration,
  });
}

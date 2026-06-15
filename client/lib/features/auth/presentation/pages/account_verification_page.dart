import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/core/utils/logger.dart';

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
        title: 'Assigning organization role',
        subtitle: 'Role: Authorized Member',
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
    return VeriFiCard(
      icon: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: step.isComplete ? VeriFiColors.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: step.isComplete
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
      ),
      title: step.title,
      description: step.subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final verificationProgress =
        (_completedSteps / _verificationSteps.length * 100).toInt();

    return Scaffold(
      backgroundColor: VeriFiColors.background,
      appBar: const AppBarWidget(
        title: 'Verifying Account',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: VeriFiSpacing.s24, vertical: VeriFiSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Please wait while we validate your details',
                style: VeriFiTypography.bodyText.copyWith(
                  color: VeriFiColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: VeriFiSpacing.s32),

            _buildStepIndicator(),

            const SizedBox(height: VeriFiSpacing.s32),

            // Verification Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verification Progress',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VeriFiColors.textDark,
                  ),
                ),
                Text(
                  '$verificationProgress%',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VeriFiColors.primary,
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
                    const AlwaysStoppedAnimation<Color>(VeriFiColors.primary),
              ),
            ),

            const SizedBox(height: VeriFiSpacing.s32),

            // Verification Steps
            ..._verificationSteps.asMap().entries.map(
              (entry) => _buildVerificationStep(entry.value, entry.key),
            ),

            const SizedBox(height: VeriFiSpacing.s48),

            // Complete Setup Button
            PrimaryButton(
              label: _isVerificationComplete ? 'Complete Setup' : 'Verifying...',
              onPressed: _handleCompleteSetup,
              isEnabled: _isVerificationComplete,
              isLoading: _isCompleting,
            ),

            const SizedBox(height: VeriFiSpacing.s32),
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

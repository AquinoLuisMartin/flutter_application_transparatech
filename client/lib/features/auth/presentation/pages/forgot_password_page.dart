import 'package:flutter/material.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailValid = false;

  void _onEmailChanged(String value) {
    setState(() {
      final trimmedEmail = value.trim().toLowerCase();
      const domain = '@pup.edu.ph';
      _isEmailValid = trimmedEmail.endsWith(domain) && trimmedEmail.length > domain.length;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final trimmedEmail = value.trim().toLowerCase();
    const domain = '@pup.edu.ph';
    if (!trimmedEmail.endsWith(domain)) {
      return 'Must use @pup.edu.ph email address';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeriFiColors.background,
      appBar: const AppBarWidget(
        title: 'Forgot Password',
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
                    'Forgot Password',
                    style: VeriFiTypography.pageTitle.copyWith(
                      color: VeriFiColors.primary,
                    ),
                  ),
                  const SizedBox(height: VeriFiSpacing.s8),
                  Text(
                    'Enter your PUP webmail address and we will send you instructions to reset your password.',
                    style: VeriFiTypography.bodyText.copyWith(
                      color: VeriFiColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: VeriFiSpacing.s48),

                  // Email Input
                  CustomTextFormField(
                    label: 'Email Address',
                    hintText: 'username@pup.edu.ph',
                    inputType: TextInputType.emailAddress,
                    controller: _emailController,
                    onChanged: _onEmailChanged,
                    isValid: _isEmailValid,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: VeriFiSpacing.s32),

                  // Send Reset Link Button
                  PrimaryButton(
                    label: 'Send Reset Link',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Simulate API call for password reset
                        showAlertDialog(
                          context: context,
                          title: 'Link Sent',
                          message: 'Password reset link sent to your email.',
                          isSuccess: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

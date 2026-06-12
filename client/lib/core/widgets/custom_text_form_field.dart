import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextInputType inputType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final int maxLines;
  final String? prefixIcon;
  final bool isValid;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final Widget? labelTrailing;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.hintText,
    this.inputType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.controller,
    this.maxLines = 1,
    this.prefixIcon,
    this.isValid = false,
    this.helperText,
    this.onChanged,
    this.labelTrailing,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    // Valid field gets a green success border, otherwise neutral.
    final Color borderColor = widget.isValid ? VeriFiColors.success : const Color(0xFFE5E7EB);
    final double borderWidth = widget.isValid ? 1.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: VeriFiTypography.label.copyWith(
                color: VeriFiColors.textGrey,
              ),
            ),
            if (widget.labelTrailing != null) widget.labelTrailing!,
          ],
        ),
        const SizedBox(height: VeriFiSpacing.s8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.inputType,
          obscureText: _isObscured,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.inter(
              color: VeriFiColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      _getIconData(widget.prefixIcon!),
                      color: VeriFiColors.textLight,
                    ),
                  )
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: VeriFiColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : (widget.isValid
                    ? const Icon(Icons.check_circle_outline, color: VeriFiColors.success)
                    : null),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: BorderSide(
                color: widget.isValid ? VeriFiColors.success : VeriFiColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: const BorderSide(
                color: VeriFiColors.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: const BorderSide(
                color: VeriFiColors.error,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: widget.validator,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: VeriFiColors.textDark,
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: VeriFiColors.textLight,
            ),
          ),
        ],
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'email':
        return Icons.email_outlined;
      case 'password':
        return Icons.lock_outline;
      case 'person':
        return Icons.person_outline;
      case 'phone':
        return Icons.phone_outlined;
      case 'badge':
        return Icons.badge_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

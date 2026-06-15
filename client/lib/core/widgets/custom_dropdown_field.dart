import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final String? prefixIcon;
  final String? hintText;
  final double? fontSize;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.hintText,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: VeriFiTypography.label.copyWith(
            color: VeriFiColors.textGrey,
          ),
        ),
        const SizedBox(height: VeriFiSpacing.s8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          style: GoogleFonts.inter(
            fontSize: fontSize ?? 13,
            fontWeight: FontWeight.w500,
            color: VeriFiColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: VeriFiColors.textLight,
              fontSize: fontSize ?? 13,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      _getIconData(prefixIcon!),
                      color: VeriFiColors.textLight,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: const BorderSide(
                color: VeriFiColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              borderSide: const BorderSide(
                color: VeriFiColors.error,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
          icon: const Icon(Icons.keyboard_arrow_down, color: VeriFiColors.textLight),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'role':
        return Icons.work_outline;
      case 'person':
        return Icons.person_outline;
      case 'group':
        return Icons.group_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

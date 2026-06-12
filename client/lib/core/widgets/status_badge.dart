import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';

/// A premium, color-coded status badge widget for the VeriFi Design System.
/// Supports standard statuses: Pending, Verified, Approved, Rejected, Expired, Processing.
class VeriFiStatusBadge extends StatelessWidget {
  /// The status string to display (case-insensitive)
  final String status;
  
  /// Custom font size for the badge text
  final double? fontSize;
  
  /// Custom padding for the badge container
  final EdgeInsetsGeometry? padding;

  /// Constructor for VeriFiStatusBadge
  const VeriFiStatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.trim().toUpperCase();
    
    Color textColor;
    Color bgColor;
    String displayLabel;
    IconData icon;

    switch (cleanStatus) {
      case 'APPROVED':
        textColor = VeriFiColors.success;
        bgColor = VeriFiColors.success.withValues(alpha: 0.1);
        displayLabel = 'Approved';
        icon = Icons.check_circle_outline;
        break;
      case 'VERIFIED':
        textColor = VeriFiColors.success;
        bgColor = VeriFiColors.success.withValues(alpha: 0.1);
        displayLabel = 'Verified';
        icon = Icons.verified_outlined;
        break;
      case 'PENDING':
        textColor = VeriFiColors.warning;
        bgColor = VeriFiColors.warning.withValues(alpha: 0.1);
        displayLabel = 'Pending';
        icon = Icons.schedule_outlined;
        break;
      case 'PROCESSING':
        textColor = VeriFiColors.warning;
        bgColor = VeriFiColors.warning.withValues(alpha: 0.1);
        displayLabel = 'Processing';
        icon = Icons.sync_outlined;
        break;
      case 'REJECTED':
        textColor = VeriFiColors.error;
        bgColor = VeriFiColors.error.withValues(alpha: 0.1);
        displayLabel = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      case 'EXPIRED':
        textColor = VeriFiColors.error;
        bgColor = VeriFiColors.error.withValues(alpha: 0.1);
        displayLabel = 'Expired';
        icon = Icons.history_toggle_off_outlined;
        break;
      default:
        textColor = VeriFiColors.textGrey;
        bgColor = VeriFiColors.secondaryEE;
        displayLabel = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: (fontSize ?? 11) + 2,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            displayLabel,
            style: GoogleFonts.inter(
              fontSize: fontSize ?? 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

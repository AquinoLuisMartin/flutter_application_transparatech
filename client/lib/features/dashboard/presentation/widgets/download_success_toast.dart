import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DownloadSuccessToast extends StatelessWidget {
  final VoidCallback onDismiss;

  const DownloadSuccessToast({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onDismiss,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white, // Solid white background
              borderRadius: BorderRadius.circular(12), // smoothly rounded corners
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3), // soft green outline/border track
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6), // deep ambient drop shadow
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15), // soft green indicator badge background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF10B981), // soft green check icon asset
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Success! Your transparency report file has been successfully prepared for download.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.normal, // crisp, regular-weight text string
                      color: const Color(0xFF374151),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

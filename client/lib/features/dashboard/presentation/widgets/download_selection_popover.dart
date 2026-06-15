import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DownloadSelectionPopOver extends StatefulWidget {
  final Offset triggerOffset;
  final Size triggerSize;
  final VoidCallback onDismiss;
  final ValueChanged<String> onOkay;

  const DownloadSelectionPopOver({
    super.key,
    required this.triggerOffset,
    required this.triggerSize,
    required this.onDismiss,
    required this.onOkay,
  });

  @override
  State<DownloadSelectionPopOver> createState() => _DownloadSelectionPopOverState();
}

class _DownloadSelectionPopOverState extends State<DownloadSelectionPopOver> {
  String _selectedFormat = 'pdf';

  Widget _buildOptionRow({
    required String title,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedFormat = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = 260;
    
    // Position card directly below trigger element aligned to its right boundary edge
    final double topPosition = widget.triggerOffset.dy + widget.triggerSize.height + 8;
    final double rightPosition = size.width - (widget.triggerOffset.dx + widget.triggerSize.width);

    return Stack(
      children: [
        // 1. Transparent Backdrop Barrier (Locks parent interaction, does not dim background)
        GestureDetector(
          onTap: widget.onDismiss,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox.expand(),
        ),
        
        // 2. Pop-over dropdown container card
        Positioned(
          top: topPosition,
          right: rightPosition,
          width: cardWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, // Solid white background
                borderRadius: BorderRadius.circular(12), // rounded corners (12px)
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.08), // thin light gray outer border track
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8), // deep ambient drop shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOptionRow(
                    title: 'PDF Document (.pdf)',
                    value: 'pdf',
                    isSelected: _selectedFormat == 'pdf',
                  ),
                  _buildOptionRow(
                    title: 'Word Document (.docx)',
                    value: 'docx',
                    isSelected: _selectedFormat == 'docx',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onDismiss,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280), // plain gray
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          widget.onDismiss();
                          widget.onOkay(_selectedFormat);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB), // solid system brand blue
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'DOWNLOAD',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

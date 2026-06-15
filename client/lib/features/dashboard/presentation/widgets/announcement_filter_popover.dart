import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnouncementFilterPopOver extends StatefulWidget {
  final Offset triggerOffset;
  final Size triggerSize;
  final VoidCallback onDismiss;
  final List<String> initialSelectedDates;
  final List<String> initialSelectedOrgs;
  final void Function(List<String> selectedDates, List<String> selectedOrgs) onApply;

  const AnnouncementFilterPopOver({
    super.key,
    required this.triggerOffset,
    required this.triggerSize,
    required this.onDismiss,
    required this.initialSelectedDates,
    required this.initialSelectedOrgs,
    required this.onApply,
  });

  @override
  State<AnnouncementFilterPopOver> createState() => _AnnouncementFilterPopOverState();
}

class _AnnouncementFilterPopOverState extends State<AnnouncementFilterPopOver> {
  List<String> _selectedDates = [];
  List<String> _selectedOrgs = [];

  @override
  void initState() {
    super.initState();
    _selectedDates = List.from(widget.initialSelectedDates);
    _selectedOrgs = List.from(widget.initialSelectedOrgs);
  }

  void _toggleDate(String date) {
    setState(() {
      if (_selectedDates.contains(date)) {
        _selectedDates.remove(date);
      } else {
        _selectedDates.add(date);
      }
    });
  }

  void _toggleOrg(String org) {
    setState(() {
      if (_selectedOrgs.contains(org)) {
        _selectedOrgs.remove(org);
      } else {
        _selectedOrgs.add(org);
      }
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
                color: isChecked ? const Color(0xFF2563EB) : Colors.transparent,
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                  color: isChecked ? const Color(0xFF2563EB) : const Color(0xFF374151),
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
    final double cardWidth = 280;
    
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
                borderRadius: BorderRadius.circular(12), // smoothly rounded card corners (12px)
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
                  _buildSectionHeader('Publish Date'),
                  _buildCheckboxRow(
                    label: 'Latest',
                    isChecked: _selectedDates.contains('Latest'),
                    onTap: () => _toggleDate('Latest'),
                  ),
                  _buildCheckboxRow(
                    label: 'Past Week',
                    isChecked: _selectedDates.contains('Past Week'),
                    onTap: () => _toggleDate('Past Week'),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 8),
                  _buildSectionHeader('Source Org'),
                  _buildCheckboxRow(
                    label: 'ACES',
                    isChecked: _selectedOrgs.contains('ACES'),
                    onTap: () => _toggleOrg('ACES'),
                  ),
                  _buildCheckboxRow(
                    label: 'iSITE',
                    isChecked: _selectedOrgs.contains('iSITE'),
                    onTap: () => _toggleOrg('iSITE'),
                  ),
                  _buildCheckboxRow(
                    label: 'COSC',
                    isChecked: _selectedOrgs.contains('COSC'),
                    onTap: () => _toggleOrg('COSC'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDates.clear();
                            _selectedOrgs.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Clear Filters',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF), // regular-weight muted gray text
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onDismiss();
                          widget.onApply(_selectedDates, _selectedOrgs);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB), // solid system brand blue
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'APPLY',
                          style: GoogleFonts.inter(
                            fontSize: 11,
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

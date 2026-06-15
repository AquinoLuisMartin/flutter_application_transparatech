import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentFilterPopOver extends StatefulWidget {
  final Offset triggerOffset;
  final Size triggerSize;
  final VoidCallback onDismiss;
  final List<String> initialSelectedTypes;
  final List<String> initialSelectedStatuses;
  final void Function(List<String> selectedTypes, List<String> selectedStatuses) onApply;

  const DocumentFilterPopOver({
    super.key,
    required this.triggerOffset,
    required this.triggerSize,
    required this.onDismiss,
    required this.initialSelectedTypes,
    required this.initialSelectedStatuses,
    required this.onApply,
  });

  @override
  State<DocumentFilterPopOver> createState() => _DocumentFilterPopOverState();
}

class _DocumentFilterPopOverState extends State<DocumentFilterPopOver> {
  List<String> _selectedTypes = [];
  List<String> _selectedStatuses = [];

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.initialSelectedTypes);
    _selectedStatuses = List.from(widget.initialSelectedStatuses);
  }

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
    });
  }

  void _toggleStatus(String status) {
    setState(() {
      if (_selectedStatuses.contains(status)) {
        _selectedStatuses.remove(status);
      } else {
        _selectedStatuses.add(status);
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
                  _buildSectionHeader('Document Type'),
                  _buildCheckboxRow(
                    label: 'Financial',
                    isChecked: _selectedTypes.contains('Financial'),
                    onTap: () => _toggleType('Financial'),
                  ),
                  _buildCheckboxRow(
                    label: 'Audit',
                    isChecked: _selectedTypes.contains('Audit'),
                    onTap: () => _toggleType('Audit'),
                  ),
                  _buildCheckboxRow(
                    label: 'Resolution',
                    isChecked: _selectedTypes.contains('Resolution'),
                    onTap: () => _toggleType('Resolution'),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 8),
                  _buildSectionHeader('Status'),
                  _buildCheckboxRow(
                    label: 'Approved',
                    isChecked: _selectedStatuses.contains('Approved'),
                    onTap: () => _toggleStatus('Approved'),
                  ),
                  _buildCheckboxRow(
                    label: 'Pending',
                    isChecked: _selectedStatuses.contains('Pending'),
                    onTap: () => _toggleStatus('Pending'),
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
                            _selectedTypes.clear();
                            _selectedStatuses.clear();
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
                          widget.onApply(_selectedTypes, _selectedStatuses);
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

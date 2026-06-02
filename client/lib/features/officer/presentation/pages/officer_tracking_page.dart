import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OfficerTrackingPage extends StatelessWidget {
  const OfficerTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Submission Tracking',
          style: GoogleFonts.inter(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  _buildFilterChip('Pending', false),
                  _buildFilterChip('Verified', false),
                  _buildFilterChip('Rejected', false),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildTrackingItem('Q4 2025 Expense Report', 'Pending', 'Submitted on Mar 15, 2026'),
                _buildTrackingItem('Tech Summit Budget', 'Verified', 'Verified on Mar 14, 2026'),
                _buildTrackingItem('Sponsorship Agreement', 'Rejected', 'Rejected on Mar 12, 2026'),
                _buildTrackingItem('Membership Fees', 'Verified', 'Verified on Mar 10, 2026'),
                _buildTrackingItem('Joint Event Proposal', 'Pending', 'Submitted on Mar 08, 2026'),
                _buildTrackingItem('Maintenance Receipts', 'Verified', 'Verified on Mar 05, 2026'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF3B48F6) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildTrackingItem(String title, String status, String date) {
    Color statusColor = Colors.orange;
    if (status == 'Verified') statusColor = Colors.green;
    if (status == 'Rejected') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: status == 'Verified' ? 1.0 : (status == 'Rejected' ? 1.0 : 0.5),
                  backgroundColor: Colors.grey.shade100,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unread indicator dot
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isUnread ? const Color(0xFF3B48F6) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF0F2547),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildNotificationCard(
                  title: 'Document Verified',
                  description: 'Q4 2025 Expense Report has been verified by the COSC Society auditor.',
                  time: '2h ago',
                  isUnread: true,
                ),
                _buildNotificationCard(
                  title: 'New Submission',
                  description: 'Maria Reyes submitted Tech Summit 2026 Budget Proposal for review.',
                  time: '5h ago',
                  isUnread: true,
                ),
                _buildNotificationCard(
                  title: 'Audit Reminder',
                  description: 'Monthly financial audit for COSC Society is due on March 30, 2026.',
                  time: '1d ago',
                  isUnread: false,
                ),
                _buildNotificationCard(
                  title: 'Hash Integrity Alert',
                  description: 'SSC-COSC Sponsorship Agreement flagged for hash mismatch. Manual review required.',
                  time: '2d ago',
                  isUnread: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

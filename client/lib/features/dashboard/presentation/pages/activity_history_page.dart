import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/document_analysis/presentation/providers/document_provider.dart';

class ActivityLogEntry {
  final String title;
  final String detail;
  final String time;
  final String status;
  final String actionType; // 'upload', 'state_change', 'update'

  const ActivityLogEntry({
    required this.title,
    required this.detail,
    required this.time,
    required this.status,
    required this.actionType,
  });
}

class ActivityHistoryPage extends StatelessWidget {
  const ActivityHistoryPage({super.key});

  IconData _getIconData(String actionType) {
    switch (actionType) {
      case 'upload':
        return Icons.cloud_upload_outlined;
      case 'state_change':
        return Icons.check_circle_outline;
      case 'update':
        return Icons.update;
      default:
        return Icons.history;
    }
  }

  Widget _buildStatusPill(String status, bool isDark) {
    Color bg;
    Color text;
    final String label = status.toUpperCase();

    if (label == 'APPROVED' || label == 'ACTIVE') {
      bg = isDark ? const Color(0xFF022C22) : const Color(0xFFDCFCE7);
      text = isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
    } else if (label == 'FLAGGED') {
      bg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      text = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
    } else { // PENDING
      bg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
      text = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: text.withValues(alpha: 0.2), width: 1) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Dynamic look up of logged in officer's organization
    final docProvider = Provider.of<DocumentProvider>(context);
    final orgBudget = docProvider.organizationBudget;
    final String orgName = orgBudget?.organization.orgName ?? 'ACES';

    final List<ActivityLogEntry> entries = [
      ActivityLogEntry(
        title: 'Pauline Pauline (Treasurer) uploaded Budget Proposal',
        detail: '${orgName}_Week_Budget.pdf',
        time: 'June 15, 2026 • 02:15 PM',
        status: 'PENDING',
        actionType: 'upload',
      ),
      ActivityLogEntry(
        title: 'System Operation changed state to Active',
        detail: '$orgName status updated by Administrator',
        time: 'June 14, 2026 • 11:00 AM',
        status: 'ACTIVE',
        actionType: 'state_change',
      ),
      ActivityLogEntry(
        title: 'John Doe (Auditor) submitted Audit Certificate',
        detail: '${orgName}_EOY_Clearance.pdf',
        time: 'June 12, 2026 • 09:45 AM',
        status: 'APPROVED',
        actionType: 'upload',
      ),
      ActivityLogEntry(
        title: 'Pauline Pauline (Treasurer) updated Receipt / Invoice',
        detail: '${orgName}_Catering_Invoice.png',
        time: 'June 10, 2026 • 04:30 PM',
        status: 'FLAGGED',
        actionType: 'update',
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B192C) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2547),
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF152238) : const Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Activity Logs',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Full audit trail for your organization's financial actions.",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF152238) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                width: 1.5,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Component 1 (Icon Badge)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B192C) : const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(entry.actionType),
                    color: isDark ? Colors.blue.shade400 : const Color(0xFF2563EB),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Component 2 (Text Content Cluster)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.detail,
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.time,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8).withValues(alpha: 0.6) : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Component 3 (Right-Aligned Status Pill)
                _buildStatusPill(entry.status, isDark),
              ],
            ),
          );
        },
      ),
    );
  }
}

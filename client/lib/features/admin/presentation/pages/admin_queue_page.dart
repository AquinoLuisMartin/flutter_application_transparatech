import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_queue_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/admin_notification_bell.dart';

class AdminQueueScreen extends StatefulWidget {
  const AdminQueueScreen({super.key});

  @override
  State<AdminQueueScreen> createState() => _AdminQueueScreenState();
}

class _AdminQueueScreenState extends State<AdminQueueScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDateFilterDialog(BuildContext context, AdminQueueProvider queueProvider) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4), // Dim backdrop
      builder: (BuildContext context) {
        return _DateFilterDialog(queueProvider: queueProvider);
      },
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required String action,
    required VoidCallback onConfirm,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isApprove = action == 'approve';
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isApprove ? 'Confirm Approval' : 'Confirm Rejection',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          content: Text(
            isApprove 
                ? 'Do you want to approve this submission?' 
                : 'Do you want to reject this submission?',
            style: GoogleFonts.inter(
              fontSize: 14, 
              color: themeProvider.isDarkMode ? Colors.grey.shade300 : VeriFiColors.textGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, 
                  color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApprove ? VeriFiColors.success : VeriFiColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStatusMessage(BuildContext context, String newStatus) {
    final String message = newStatus == 'APPROVED' 
        ? 'Submission approved successfully' 
        : 'Submission rejected';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              newStatus == 'APPROVED' ? Icons.check_circle : Icons.cancel, 
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: newStatus == 'APPROVED' ? VeriFiColors.success : VeriFiColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final queueProvider = Provider.of<AdminQueueProvider>(context);

    // Filtered submissions list from global provider
    final filteredSubmissions = queueProvider.getFilteredSubmissions();

    // Counts from global provider
    final pendingCount = queueProvider.submissions.where((s) => s.status == 'PENDING').length;
    final approvedCount = queueProvider.submissions.where((s) => s.status == 'APPROVED').length;
    final rejectedCount = queueProvider.submissions.where((s) => s.status == 'REJECTED').length;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 1. Layout Structure & Header (Top View)
          _buildHeader(context, themeProvider, queueProvider, pendingCount, approvedCount, rejectedCount),
          
          // 2. Search & Filter Controls (Mid View)
          _buildSearchAndFilters(context, queueProvider),
          
          // 3. Dynamic Submissions Feed
          Expanded(
            child: _buildSubmissionsFeed(filteredSubmissions, queueProvider),
          ),
        ],
      ),
    );
  }

  // Header Widget
  Widget _buildHeader(
    BuildContext context, 
    ThemeProvider themeProvider, 
    AdminQueueProvider queueProvider,
    int pending, 
    int approved, 
    int rejected
  ) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final String fullName = (user != null && '${user.firstName} ${user.lastName}'.trim().isNotEmpty && '${user.firstName} ${user.lastName}' != 'admin admin')
        ? '${user.firstName} ${user.lastName}'
        : 'luis luis';

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2547), // Deep navy blue
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Iskolar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fullName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Controls
              Row(
                children: [
                  const AdminNotificationBell(),
                  const SizedBox(width: 12),
                  // Circular Shield Profile Avatar Button
                  GestureDetector(
                    onTap: () {
                      showProfileDropdown(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Metric Counter Row (Static, flat overview counters)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.access_time_filled,
                  iconColor: const Color(0xFFFFB020),
                  countText: '$pending',
                  label: 'Pending Review',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF2E7D32),
                  countText: '$approved',
                  label: 'Approved',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cancel,
                  iconColor: const Color(0xFFC62828),
                  countText: '$rejected',
                  label: 'Rejected',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Semi-transparent Metric Card Widget (Flat and static summary counter)
  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String countText,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                countText,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFFA5B4FC),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Search & Date Filters Row
  Widget _buildSearchAndFilters(BuildContext context, AdminQueueProvider queueProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search Bar
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB), 
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      queueProvider.setSearchQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.inter(
                        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Button
              GestureDetector(
                onTap: () => _showDateFilterDialog(context, queueProvider),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: queueProvider.selectedDateRange != null 
                              ? const Color(0xFF3B48F6) 
                              : (themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.filter_alt_outlined, 
                        color: queueProvider.selectedDateRange != null 
                            ? const Color(0xFF3B48F6) 
                            : (themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey), 
                        size: 20
                      ),
                    ),
                    if (queueProvider.selectedDateRange != null)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B48F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Active Date Range Chip
          if (queueProvider.selectedDateRange != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDCE4FF)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: const Color(0xFF3B48F6)),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatDateCompact(queueProvider.selectedDateRange!.start)} - ${_formatDateCompact(queueProvider.selectedDateRange!.end)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B48F6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          queueProvider.setSelectedDateRange(null);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFF3B48F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  // Format date kompak helper
  String _formatDateCompact(DateTime date) {
    return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
  }

  // Submissions Feed Main List
  Widget _buildSubmissionsFeed(List<QueueSubmission> list, AdminQueueProvider queueProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    final String label;
    if (queueProvider.selectedStatusFilter == 'PENDING') {
      label = 'Pending Submissions (${list.length})';
    } else if (queueProvider.selectedStatusFilter == 'APPROVED') {
      label = 'Approved Submissions (${list.length})';
    } else {
      label = 'Rejected Submissions (${list.length})';
    }

    return Container(
      width: double.infinity,
      color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interactive Title Selector Button
          PopupMenuButton<String>(
            offset: const Offset(0, 32),
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tooltip: 'Filter Submissions',
            onSelected: (String val) {
              queueProvider.setSelectedStatusFilter(val);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'PENDING',
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: queueProvider.selectedStatusFilter == 'PENDING'
                        ? const Color(0xFFEFF6FF) // Faint blue background highlight tint
                        : Colors.transparent,
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, color: Colors.grey, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'Pending Review',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF0F2547),
                            fontWeight: queueProvider.selectedStatusFilter == 'PENDING'
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<String>(
                  value: 'APPROVED',
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: queueProvider.selectedStatusFilter == 'APPROVED'
                        ? const Color(0xFFEFF6FF)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'Approved',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF0F2547),
                            fontWeight: queueProvider.selectedStatusFilter == 'APPROVED'
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<String>(
                  value: 'REJECTED',
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: queueProvider.selectedStatusFilter == 'REJECTED'
                        ? const Color(0xFFEFF6FF)
                        : Colors.transparent,
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Color(0xFFC62828), size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'Rejected',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF0F2547),
                            fontWeight: queueProvider.selectedStatusFilter == 'REJECTED'
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF0F2547),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF0F2547),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Scrollable Stack
          Expanded(
            child: list.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _buildSubmissionCard(context, item, queueProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Empty state placeholder
  Widget _buildEmptyState(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 48,
              color: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No submissions found',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your search query or filters',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Submission Card Component
  Widget _buildSubmissionCard(BuildContext context, QueueSubmission item, AdminQueueProvider queueProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        _showDocumentDetailsOverlay(context, item, queueProvider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFEEF2FF), 
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Card Row: Icon, Title, Chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Light Blue Sheet Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF0F2547) : const Color(0xFFEFF6FF), // soft blue
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF3B48F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Text Stack
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.organization} | ${item.senderName} | ${item.documentType}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Chevron icon
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
              ],
            ),
            
            // Show Buttons ONLY for Pending Items
            if (item.status == 'PENDING') ...[
              const SizedBox(height: 16),
              // Isolated gesture detector row to prevent event bubbling
              GestureDetector(
                onTap: () {}, // Blocks bubble-up tap triggers
                child: Row(
                  children: [
                    // Approve Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showConfirmationDialog(
                            context: context,
                            action: 'approve',
                            onConfirm: () {
                              queueProvider.updateSubmissionStatus(item.id, 'APPROVED');
                              _showStatusMessage(context, 'APPROVED');
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9), // Soft green
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.thumb_up_outlined,
                                color: Color(0xFF2E7D32),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Approve',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Reject Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showConfirmationDialog(
                            context: context,
                            action: 'reject',
                            onConfirm: () {
                              queueProvider.updateSubmissionStatus(item.id, 'REJECTED');
                              _showStatusMessage(context, 'REJECTED');
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE), // Soft coral
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.thumb_down_outlined,
                                color: Color(0xFFC62828),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Reject',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              // Visual badge indicating processed state
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == 'APPROVED' 
                          ? const Color(0xFFE8F5E9) 
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.status,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.status == 'APPROVED' 
                            ? const Color(0xFF2E7D32) 
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Document Details Dialog Overlay
  void _showDocumentDetailsOverlay(BuildContext context, QueueSubmission item, AdminQueueProvider queueProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5), // Dim the background
      builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header with Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Document Details',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Divider(height: 24, color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                    
                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Metadata list
                    _buildModalMetaItem(context, Icons.business_outlined, 'Organization', item.organization),
                    const SizedBox(height: 8),
                    _buildModalMetaItem(context, Icons.calendar_today_outlined, 'Upload Date', _formatFullDate(item.uploadDate)),
                    const SizedBox(height: 8),
                    _buildModalMetaItem(context, Icons.insert_drive_file_outlined, 'File Size', item.fileSize),
                    const SizedBox(height: 8),
                    _buildModalMetaItem(context, Icons.person_outline, 'Sender', item.senderName),
                    const SizedBox(height: 16),

                    // Description Label
                    Text(
                      'Description',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Description text box with AI flags
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4F6FF), // soft blue tint
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFDCE4FF), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AI Verification',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3B48F6),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: item.accuracy >= 90 
                                      ? const Color(0xFFE8F5E9) 
                                      : const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${item.accuracy}% Accuracy',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: item.accuracy >= 90 
                                        ? const Color(0xFF2E7D32) 
                                        : const Color(0xFFE65100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.description,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF4B5563),
                              height: 1.4,
                            ),
                          ),
                          // Display AI Warning Flags
                          if (item.flags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Divider(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFDCE4FF), thickness: 1),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Warning Flags Detected:',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...item.flags.map((flag) => Padding(
                              padding: const EdgeInsets.only(left: 22, bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('• ', style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey.shade500 : const Color(0xFF6B7280))),
                                  Expanded(
                                    child: Text(
                                      flag,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: themeProvider.isDarkMode ? Colors.grey.shade300 : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ] else ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'All checks passed by AI extractor.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full-width buttons: Preview & Download
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening file preview for "${item.title}"...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Preview Document'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B48F6), // system blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading file "${item.title}" (${item.fileSize})...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Download Original'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: themeProvider.isDarkMode ? Colors.white : const Color(0xFF3B48F6),
                          side: BorderSide(color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF3B48F6)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    // Final Approve/Reject decisions row (Approve left, Reject right)
                    if (item.status == 'PENDING') ...[
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Approve Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _showConfirmationDialog(
                                  context: context,
                                  action: 'approve',
                                  onConfirm: () {
                                    queueProvider.updateSubmissionStatus(item.id, 'APPROVED');
                                    _showStatusMessage(context, 'APPROVED');
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.thumb_up_outlined, color: Color(0xFF2E7D32), size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Approve',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Reject Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _showConfirmationDialog(
                                  context: context,
                                  action: 'reject',
                                  onConfirm: () {
                                    queueProvider.updateSubmissionStatus(item.id, 'REJECTED');
                                    _showStatusMessage(context, 'REJECTED');
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.thumb_down_outlined, color: Color(0xFFC62828), size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Reject',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFC62828),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalMetaItem(BuildContext context, IconData icon, String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF9CA3AF), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.9) : VeriFiColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Format full date helper
  String _formatFullDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[date.month - 1];
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    return '$month ${date.day}, ${date.year} at $hour:$minute $ampm';
  }
}

class _DateFilterDialog extends StatefulWidget {
  final AdminQueueProvider queueProvider;
  const _DateFilterDialog({required this.queueProvider});

  @override
  State<_DateFilterDialog> createState() => _DateFilterDialogState();
}

class _DateFilterDialogState extends State<_DateFilterDialog> {
  late DateTime _activeMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  String _activeTarget = 'START';
  bool _slideRight = false;

  @override
  void initState() {
    super.initState();
    final currentRange = widget.queueProvider.selectedDateRange;
    if (currentRange != null) {
      _startDate = currentRange.start;
      _endDate = currentRange.end;
    }
    
    final baseDate = _startDate ?? DateTime.now();
    _activeMonth = DateTime(baseDate.year, baseDate.month, 1);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatSummaryDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  bool _isBetween(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return d.isAfter(s) && d.isBefore(e);
  }

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(_activeMonth.year, _activeMonth.month, 1);
    final offset = firstOfMonth.weekday % 7; // Sunday=0, Monday=1, ..., Saturday=6
    final lastOfMonth = DateTime(_activeMonth.year, _activeMonth.month + 1, 0);
    final totalDaysToShow = offset + lastOfMonth.day;
    final totalCells = totalDaysToShow <= 35 ? 35 : 42;
    final gridStartDate = firstOfMonth.subtract(Duration(days: offset));

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pop-up Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by Date',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F2547),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date-Range Summary Display
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'START',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _activeTarget == 'START' ? const Color(0xFF3B48F6) : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _startDate != null ? _formatSummaryDate(_startDate!) : '—',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F2547),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 32,
                  width: 1,
                  color: const Color(0xFFE5E7EB),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'END',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _activeTarget == 'END' ? const Color(0xFF3B48F6) : const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _endDate != null ? _formatSummaryDate(_endDate!) : '—',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F2547),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Selection Target Row Toggle
            GestureDetector(
              onTap: () {
                setState(() {
                  _activeTarget = _activeTarget == 'START' ? 'END' : 'START';
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B48F6), width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF3B48F6), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _activeTarget == 'START' ? 'START DATE' : 'END DATE',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B48F6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Month Selection Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _slideRight = true;
                      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month - 1, 1);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_left, color: Color(0xFF374151), size: 20),
                  ),
                ),
                Text(
                  '${_getMonthName(_activeMonth.month)} ${_activeMonth.year}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F2547),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _slideRight = false;
                      _activeMonth = DateTime(_activeMonth.year, _activeMonth.month + 1, 1);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_right, color: Color(0xFF374151), size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Days of the Week Header
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // 7-Column Day Matrix Grid wrapped in Slide Animation
            SizedBox(
              height: 250,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offset = _slideRight
                      ? Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                        )
                      : Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
                          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                        );
                  return ClipRect(
                    child: SlideTransition(
                      position: offset,
                      child: child,
                    ),
                  );
                },
                child: GridView.builder(
                  key: ValueKey<DateTime>(_activeMonth),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCells,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final cellDate = DateTime(
                      gridStartDate.year,
                      gridStartDate.month,
                      gridStartDate.day + index,
                    );
                    
                    final isStart = _startDate != null &&
                        cellDate.year == _startDate!.year &&
                        cellDate.month == _startDate!.month &&
                        cellDate.day == _startDate!.day;
                    
                    final isEnd = _endDate != null &&
                        cellDate.year == _endDate!.year &&
                        cellDate.month == _endDate!.month &&
                        cellDate.day == _endDate!.day;

                    final isBetween = _startDate != null && _endDate != null && _isBetween(cellDate, _startDate!, _endDate!);
                    final isCurrentMonth = cellDate.month == _activeMonth.month;

                    // Decoration styling
                    BoxDecoration? cellDecoration;
                    Color textColor;

                    if (isStart || isEnd) {
                      cellDecoration = const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3B48F6),
                      );
                      textColor = Colors.white;
                    } else if (isBetween) {
                      cellDecoration = const BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Color(0xFFE3F2FD),
                      );
                      textColor = const Color(0xFF374151);
                    } else {
                      cellDecoration = const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      );
                      textColor = isCurrentMonth
                          ? const Color(0xFF374151)
                          : Colors.grey.shade300;
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_activeTarget == 'START') {
                            _startDate = cellDate;
                            _endDate = null;
                            _activeTarget = 'END';
                          } else {
                            if (_startDate == null) {
                              _startDate = cellDate;
                              _endDate = null;
                              _activeTarget = 'END';
                            } else {
                              final cellDateOnly = DateTime(cellDate.year, cellDate.month, cellDate.day);
                              final startDateOnly = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
                              if (cellDateOnly.isBefore(startDateOnly)) {
                                _startDate = cellDate;
                                _endDate = null;
                                _activeTarget = 'END';
                              } else {
                                _endDate = cellDate;
                              }
                            }
                          }
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: cellDecoration,
                        child: (isStart || isEnd || isBetween)
                            ? Text(
                                '${cellDate.day}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: (isStart || isEnd) ? FontWeight.bold : FontWeight.w500,
                                  color: textColor,
                                ),
                              )
                            : Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: const Color(0xFFEFF6FF),
                                  onTap: () {
                                    setState(() {
                                      if (_activeTarget == 'START') {
                                        _startDate = cellDate;
                                        _endDate = null;
                                        _activeTarget = 'END';
                                      } else {
                                        if (_startDate == null) {
                                          _startDate = cellDate;
                                          _endDate = null;
                                          _activeTarget = 'END';
                                        } else {
                                          final cellDateOnly = DateTime(cellDate.year, cellDate.month, cellDate.day);
                                          final startDateOnly = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
                                          if (cellDateOnly.isBefore(startDateOnly)) {
                                            _startDate = cellDate;
                                            _endDate = null;
                                            _activeTarget = 'END';
                                          } else {
                                            _endDate = cellDate;
                                          }
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${cellDate.day}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: isCurrentMonth ? FontWeight.w500 : FontWeight.normal,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Confirmation Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'CANCEL',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B48F6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: (_startDate == null || _endDate == null)
                      ? null
                      : () {
                          final startDateTime = DateTime(
                            _startDate!.year,
                            _startDate!.month,
                            _startDate!.day,
                            0,
                            0,
                            0,
                          );
                          final endDateTime = DateTime(
                            _endDate!.year,
                            _endDate!.month,
                            _endDate!.day,
                            23,
                            59,
                            59,
                          );
                          widget.queueProvider.setSelectedDateRange(
                            DateTimeRange(
                              start: startDateTime,
                              end: endDateTime,
                            ),
                          );
                          Navigator.pop(context);
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'OK',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: (_startDate == null || _endDate == null)
                            ? const Color(0xFF3B48F6).withValues(alpha: 0.4)
                            : const Color(0xFF3B48F6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

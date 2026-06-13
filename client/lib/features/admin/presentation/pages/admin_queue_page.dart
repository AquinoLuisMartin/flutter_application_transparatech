import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_queue_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';

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

  // Date range picker helper (Standard Light Redesign)
  Future<void> _selectDateRange(BuildContext context, AdminQueueProvider queueProvider) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: queueProvider.selectedDateRange,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B48F6), // Selected highlight system blue
              onPrimary: Colors.white,
              surface: Colors.white, // Modal background
              onSurface: Color(0xFF1F2937), // Inactive dates and headers high-contrast dark grey
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1F2937),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1F2937)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B48F6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      queueProvider.setSelectedDateRange(picked);
    }
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
    final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'admin admin';

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
                  // Light/Dark mode toggle
                  Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (val) {
                      themeProvider.toggleTheme();
                    },
                    activeThumbColor: const Color(0xFF3B48F6),
                    activeTrackColor: Colors.white.withValues(alpha: 0.2),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  // Notification bell with badge
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
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
          // Metric Counter Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.access_time_filled,
                  iconColor: const Color(0xFFFFB020),
                  count: pending,
                  label: 'Pending Review',
                  isActive: queueProvider.selectedStatusFilter == 'PENDING',
                  onTap: () {
                    queueProvider.setSelectedStatusFilter('PENDING');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF2E7D32),
                  count: approved,
                  label: 'Approved',
                  isActive: queueProvider.selectedStatusFilter == 'APPROVED',
                  onTap: () {
                    queueProvider.setSelectedStatusFilter('APPROVED');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cancel,
                  iconColor: const Color(0xFFC62828),
                  count: rejected,
                  label: 'Rejected',
                  isActive: queueProvider.selectedStatusFilter == 'REJECTED',
                  onTap: () {
                    queueProvider.setSelectedStatusFilter('REJECTED');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Semi-transparent Metric Card Widget
  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? Colors.white.withValues(alpha: 0.15) 
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive 
                ? Colors.white.withValues(alpha: 0.4) 
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
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
                  '$count',
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
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
                onTap: () => _selectDateRange(context, queueProvider),
                child: Container(
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
    return Container(
      width: double.infinity,
      color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List Title
          Text(
            'Submissions (${list.length})',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
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

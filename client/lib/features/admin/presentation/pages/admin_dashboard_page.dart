import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_queue_page.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_queue_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_analytics_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_organizations_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_users_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_notification_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/admin_notification_bell.dart';

class AdminDashboardPage extends StatefulWidget {
  final int initialIndex;
  const AdminDashboardPage({super.key, this.initialIndex = 0});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late int _selectedIndex;
  String? _organizationSearchQuery;
  String? _usersRoleFilter;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<AdminNotificationProvider>(context);

    if (notificationProvider.navigateToTab != null) {
      final tabIndex = notificationProvider.navigateToTab!;
      final orgFilter = notificationProvider.orgFilter;
      final roleFilter = notificationProvider.roleFilter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _selectedIndex = tabIndex;
          if (orgFilter != null) {
            _organizationSearchQuery = orgFilter;
          }
          if (roleFilter != null) {
            _usersRoleFilter = roleFilter;
          }
        });
        notificationProvider.clearNavigation();
      });
    }

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
      body: _buildActiveTab(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              if (index != 3) {
                _organizationSearchQuery = null;
              }
              _usersRoleFilter = null;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white, // Solid white bar locked fixed
          selectedItemColor: const Color(0xFF3B48F6),
          unselectedItemColor: const Color(0xFF9CA3AF), // Muted gray inactive format
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.queue_outlined),
              activeIcon: Icon(Icons.queue),
              label: 'Queue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              activeIcon: Icon(Icons.business),
              label: 'Organization',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Users',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_selectedIndex) {
      case 0:
        return AdminHomeScreen(
          onNavigateToTab: (index, {statusFilter, highlightQuery}) {
            setState(() {
              _selectedIndex = index;
            });
            final queueProvider = Provider.of<AdminQueueProvider>(context, listen: false);
            if (statusFilter != null) {
              queueProvider.setSelectedStatusFilter(statusFilter);
            }
            if (highlightQuery != null) {
              queueProvider.setSearchQuery(highlightQuery);
            } else {
              queueProvider.setSearchQuery('');
            }
            queueProvider.setSelectedDateRange(null); // Clear active date filters
          },
        );
      case 1:
        return const AdminQueueScreen();
      case 2:
        return AdminAnalyticsScreen(
          onNavigateToTab: (index, {orgFilter}) {
            setState(() {
              _selectedIndex = index;
              _organizationSearchQuery = orgFilter;
            });
          },
        );
      case 3:
        return AdminOrganizationsScreen(initialSearchQuery: _organizationSearchQuery);
      case 4:
        return AdminUsersScreen(initialRoleFilter: _usersRoleFilter);
      default:
        return AdminHomeScreen(
          onNavigateToTab: (index, {statusFilter, highlightQuery}) {
            setState(() {
              _selectedIndex = index;
            });
          },
        );
    }
  }
}

class AdminHomeScreen extends StatelessWidget {
  final Function(int index, {String? statusFilter, String? highlightQuery})? onNavigateToTab;
  const AdminHomeScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final queueProvider = Provider.of<AdminQueueProvider>(context);

    // Dynamic database lists based on status filter
    final pendingSubmissions = queueProvider.submissions.where((s) => s.status == 'PENDING').toList();
    pendingSubmissions.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    final recentPending = pendingSubmissions.take(4).toList();

    final approvedSubmissions = queueProvider.submissions.where((s) => s.status == 'APPROVED').toList();
    approvedSubmissions.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    final recentApproved = approvedSubmissions.take(4).toList();

    return Column(
      children: [
        // 1. Fixed Top Header Module
        _buildHeader(context, themeProvider),
        
        // 2. Scrollable content feed area
        Expanded(
          child: Container(
            color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A. Pending Submissions Section Header
                  Text(
                    'Pending Submissions (${pendingSubmissions.length})',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // AnimatedSwitcher for smooth fade transition when processed
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: recentPending.isEmpty
                        ? _buildEmptyState(context, isPending: true)
                        : Column(
                            key: ValueKey('pending_${recentPending.map((e) => e.id).join(',')}'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...recentPending.map((item) => _buildSubmissionCard(context, item, queueProvider, isPending: true)),
                              const SizedBox(height: 12),
                              _buildSeeMoreButton(() {
                                onNavigateToTab?.call(1, statusFilter: 'PENDING');
                              }),
                            ],
                          ),
                  ),

                  const SizedBox(height: 28),

                  // B. Recent Approvals Section Header
                  Text(
                    'Recent Approvals (${approvedSubmissions.length})',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: recentApproved.isEmpty
                        ? _buildEmptyState(context, isPending: false)
                        : Column(
                            key: ValueKey('approved_${recentApproved.map((e) => e.id).join(',')}'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...recentApproved.map((item) => _buildSubmissionCard(context, item, queueProvider, isPending: false)),
                              const SizedBox(height: 12),
                              _buildSeeMoreButton(() {
                                onNavigateToTab?.call(1, statusFilter: 'APPROVED');
                              }),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Centered See More Button Row
  Widget _buildSeeMoreButton(VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'See More',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  // Header banner layout with deep navy background
  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    // Fallback profile title is forced to "luis luis"
    final String fullName = (user != null && '${user.firstName} ${user.lastName}'.trim().isNotEmpty && '${user.firstName} ${user.lastName}' != 'admin admin')
        ? '${user.firstName} ${user.lastName}'
        : 'luis luis';

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2547), // Solid Deep Navy Blue
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Greeting Text Column
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
          // Controls (Switch / toggle completely removed)
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
    );
  }

  // Clean flat submission / approval card component
  Widget _buildSubmissionCard(
    BuildContext context,
    QueueSubmission item,
    AdminQueueProvider queueProvider, {
    required bool isPending,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Clickable body: does not overlap chevron boundary
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Highlight entry inside Queue tab by status & search title
                onNavigateToTab?.call(1, statusFilter: item.status, highlightQuery: item.title);
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // Left side light blue/green badge box container
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPending
                          ? (themeProvider.isDarkMode ? const Color(0xFF0F2547) : const Color(0xFFEFF6FF)) // light blue
                          : (themeProvider.isDarkMode ? const Color(0xFF064E3B) : const Color(0xFFE8F5E9)), // light green
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPending ? Icons.description_outlined : Icons.check_circle_outline,
                      color: isPending ? const Color(0xFF3B48F6) : const Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Center Metadata text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.organization} | ${item.senderName} | Submission type: ${isPending ? 'Pending' : 'Approved'}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Chevron indicator opens detailed overlay sheet
          GestureDetector(
            onTap: () {
              _showDocumentDetailsOverlay(context, item, queueProvider);
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 18,
              ),
            ),
          ),
        ],
      ),
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

  void _showDocumentDetailsOverlay(BuildContext context, QueueSubmission item, AdminQueueProvider queueProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
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

                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildModalMetaItem(context, Icons.business_outlined, 'Organization', item.organization),
                    const SizedBox(height: 8),
                    _buildModalMetaItem(context, Icons.calendar_today_outlined, 'Upload Date', _formatFullDate(item.uploadDate)),
                    const SizedBox(height: 8),
                    _buildModalMetaItem(context, Icons.insert_drive_file_outlined, 'File Size', item.fileSize),
                    const SizedBox(height: 8),
                    _buildModalMetaItem(context, Icons.person_outline, 'Sender', item.senderName),
                    const SizedBox(height: 16),

                    Text(
                      'Description',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF4F6FF),
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

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showAlertDialog(
                            context: context,
                            title: 'Preview Document',
                            message: 'Opening file preview for "${item.title}"...',
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Preview Document'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B48F6),
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
                          showAlertDialog(
                            context: context,
                            title: 'Download Started',
                            message: 'Downloading file "${item.title}" (${item.fileSize})...',
                            isSuccess: true,
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

                    if (item.status == 'PENDING') ...[
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
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

  Widget _buildEmptyState(BuildContext context, {required bool isPending}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 40,
              color: themeProvider.isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              isPending ? 'No pending submissions' : 'No recent approvals',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
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

  void _showStatusMessage(BuildContext context, String newStatus) {
    final String message = newStatus == 'APPROVED'
        ? 'Submission approved successfully'
        : 'Submission rejected';

    showAlertDialog(
      context: context,
      title: newStatus == 'APPROVED' ? 'Submission Approved' : 'Submission Rejected',
      message: message,
      isSuccess: newStatus == 'APPROVED',
      isError: newStatus != 'APPROVED',
    );
  }
}

class AdminPlaceholderScreen extends StatelessWidget {
  final String title;
  const AdminPlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: Container(
            color: const Color(0xFFF8F9FB),
            child: Center(
              child: Text(
                '$title Screen (Placeholder)',
                style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      child: Row(
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
              // Notification bell with red numeric badge
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
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F2547), width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '3',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
    );
  }
}

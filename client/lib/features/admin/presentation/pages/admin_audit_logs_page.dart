import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_dashboard_page.dart';

class AuditLogItem {
  final String actorRole; // 'Officer' or 'Admin'
  final String actorName;
  final String action; // 'uploaded', 'approved', 'rejected', 'updated'
  final String fileName;
  final String taxType; // 'Budget Proposal', 'Invoice', 'Expense Report', 'Receipt'
  final String timestamp;

  AuditLogItem({
    required this.actorRole,
    required this.actorName,
    required this.action,
    required this.fileName,
    required this.taxType,
    required this.timestamp,
  });
}

class AdminAuditLogsScreen extends StatefulWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  State<AdminAuditLogsScreen> createState() => _AdminAuditLogsScreenState();
}

class _AdminAuditLogsScreenState extends State<AdminAuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Uploaded', 'Approved', 'Rejected', 'Updated'

  // Audit logs - to be fetched from server when activity_logs API is implemented
  final List<AuditLogItem> _logs = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reactive filtering depending on Search Query and Filter Option
  List<AuditLogItem> get _filteredLogs {
    final query = _searchController.text.toLowerCase().trim();
    
    return _logs.where((log) {
      // 1. Text Search query matching
      final matchesSearch = query.isEmpty ||
          log.actorName.toLowerCase().contains(query) ||
          log.fileName.toLowerCase().contains(query) ||
          log.actorRole.toLowerCase().contains(query) ||
          log.taxType.toLowerCase().contains(query);

      // 2. Filter Category matching
      if (!matchesSearch) return false;
      if (_selectedFilter == 'All') return true;
      return log.action.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  // Centered anchored context selection menu
  void _showFilterMenu(BuildContext context, Offset tapPosition) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx - 120, // offset left
        tapPosition.dy,
        tapPosition.dx,
        tapPosition.dy + 120,
      ),
      color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      items: <String>['All', 'Uploaded', 'Approved', 'Rejected', 'Updated'].map((String choice) {
        final bool isSelected = _selectedFilter == choice;
        return PopupMenuItem<String>(
          value: choice,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFFE3F2FD) // Soft blue active tint
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              choice,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF1E3A8A) // deep navy blue
                    : (themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark),
              ),
            ),
          ),
        );
      }).toList(),
    ).then((String? newValue) {
      if (newValue != null) {
        setState(() {
          _selectedFilter = newValue;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 1. Fixed Top Header Module
          _buildHeader(context),

          // 2. Search & Filter Bar (Mid View)
          _buildSearchAndFilters(context, themeProvider),

          // 3. Main Body Scroll View
          Expanded(
            child: _filteredLogs.isEmpty
                ? _buildEmptyState(themeProvider)
                : ListView.builder(
                    itemCount: _filteredLogs.length,
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 24),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _filteredLogs[index];
                      return _buildAuditLogCard(context, item, themeProvider);
                    },
                  ),
          ),
        ],
      ),
      // 4. Fixed Bottom Navigation Bar (Muted inactive states)
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
          currentIndex: 0,
          onTap: (index) {
            // Redirect back to dashboard
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardPage(initialIndex: index)),
              (route) => false,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          selectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400, // forced inactive color
          unselectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400, // forced inactive color
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.queue_outlined),
              label: 'Queue',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined),
              label: 'Organization',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Users',
            ),
          ],
        ),
      ),
    );
  }

  // Navy banner header
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2547), // Solid Deep Navy Blue
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, // vertical alignment constraint with content cards
        right: 20,
        bottom: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular back chevron button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Audit Logs',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View system activity and user actions',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter input and funnel button controls
  Widget _buildSearchAndFilters(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      child: Column(
        children: [
          Row(
            children: [
              // Search Input Box
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
                    onChanged: (value) {
                      setState(() {});
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
              // Funnel filter button
              GestureDetector(
                onTapDown: (TapDownDetails details) => _showFilterMenu(context, details.globalPosition),
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedFilter != 'All'
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
                    color: _selectedFilter != 'All'
                        ? const Color(0xFF3B48F6)
                        : (themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          // Active filter selection chip tag
          if (_selectedFilter != 'All') ...[
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
                      const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF3B48F6)),
                      const SizedBox(width: 6),
                      Text(
                        'Filter: $_selectedFilter',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B48F6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'All';
                          });
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
          ],
        ],
      ),
    );
  }

  // Audit event feed card builder
  Widget _buildAuditLogCard(BuildContext context, AuditLogItem item, ThemeProvider themeProvider) {
    // Determine colors/icons depending on Action State
    Color statusBgColor;
    Color statusIconColor;
    IconData statusIcon;
    Color tagBgColor;
    Color tagTextColor;

    switch (item.action) {
      case 'uploaded':
        statusBgColor = const Color(0xFFE0F2FE); // sky blue background
        statusIconColor = const Color(0xFF0284C7); // bold blue
        statusIcon = Icons.cloud_upload_outlined; // up tray icon
        tagBgColor = const Color(0xFFEFF6FF); // soft system blue matching typography color
        tagTextColor = const Color(0xFF3B48F6);
        break;
      case 'approved':
        statusBgColor = const Color(0xFFDCFCE7); // soft mint green background
        statusIconColor = const Color(0xFF15803D); // bold green
        statusIcon = Icons.check_circle_outline; // green circular checkmark icon
        tagBgColor = const Color(0xFFDCFCE7); // light emerald green
        tagTextColor = const Color(0xFF15803D); // dark green text
        break;
      case 'rejected':
        statusBgColor = const Color(0xFFFEE2E2); // soft coral/red background
        statusIconColor = const Color(0xFFDC2626); // dark red
        statusIcon = Icons.thumb_down_outlined; // dark red thumbs-down icon
        tagBgColor = const Color(0xFFFFEBEE); // light pastel red
        tagTextColor = const Color(0xFFC62828); // dark red text
        break;
      case 'updated':
        statusBgColor = const Color(0xFFF3E8FF); // soft pastel purple background
        statusIconColor = const Color(0xFF7E22CE); // purple
        statusIcon = Icons.edit_note_outlined; // purple edit pencil icon
        tagBgColor = const Color(0xFFF3E8FF); // muted lavender
        tagTextColor = const Color(0xFF7E22CE); // dark purple text
        break;
      default:
        statusBgColor = const Color(0xFFF1F5F9);
        statusIconColor = const Color(0xFF64748B);
        statusIcon = Icons.info_outline;
        tagBgColor = const Color(0xFFF1F5F9);
        tagTextColor = const Color(0xFF64748B);
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left status badge icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusIconColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Center Log Details Stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Statement
                Text(
                  '${item.actorRole} ${item.actorName} ${item.action} a document',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),

                // File Name
                Text(
                  item.fileName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),

                // Context Tag Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.taxType,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tagTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Timeline Stamp
                Text(
                  item.timestamp,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Audit Logs Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Adjust filter choice or query terms.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

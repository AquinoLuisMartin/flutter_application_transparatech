import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  int _activeTooltipIndex = -1;

  // Chart data definitions
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> _activityValues = [110, 130, 95, 140, 160, 85, 70];
  final int _maxActivity = 200;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Standard Light calendar filter dialog
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
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
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDateCompact(DateTime date) {
    return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
  }

  // Expanded detailed statistics popup modal
  void _showOrgDetailsDialog(BuildContext context, String org, int count) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business, color: Color(0xFF3B48F6), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '$org Statistics',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPopupDetailRow(context, 'Total Submissions', '$count requests'),
              const SizedBox(height: 8),
              _buildPopupDetailRow(context, 'Verification Accuracy', '${(92.0 + (count % 7)).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              _buildPopupDetailRow(context, 'Auto-Approve Rate', '${(78.5 + (count % 9)).toStringAsFixed(1)}%'),
              const SizedBox(height: 8),
              _buildPopupDetailRow(context, 'Average Audit Time', '${(1.5 + (count % 3) * 0.5)} days'),
              const SizedBox(height: 16),
              Divider(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              Text(
                'Department records show steady activity without critical delays. Data extraction models continue verifying receipts against budgets.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: themeProvider.isDarkMode ? Colors.grey.shade300 : VeriFiColors.textGrey,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B48F6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopupDetailRow(BuildContext context, String label, String value) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
          ),
        ),
      ],
    );
  }

  // Flag issues confirmation prompt modal
  void _showFlagIssuesDialog(BuildContext context, String org) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirm Flagging',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          content: Text(
            'Do you want to flag issues for $org?',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('$org flagged successfully.', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    backgroundColor: VeriFiColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VeriFiColors.error,
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 1. Layout Structure & Header Section (Top View)
          _buildHeader(context, themeProvider),

          // 2. Search & Controls Section (Mid View)
          _buildSearchAndFilters(context, themeProvider),

          // 3. Main Body: Scroll Area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // A. User Activity Card Block
                  _buildUserActivityCard(themeProvider),
                  const SizedBox(height: 16),

                  // B. Requests by Organization Card Block
                  _buildRequestsByOrgCard(themeProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Platform consistent Navy Header
  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting Text (Left)
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
              // Controls (Right)
              Row(
                children: [
                  // Light/Dark Toggle switch pill
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
                  // Notification bell with red badge
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
                  // Shield avatar button
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
          // Metric Summary Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.access_time_filled,
                  iconColor: const Color(0xFFFFB020), // Yellow clock
                  countText: '12,842',
                  label: 'Total Users',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF2E7D32), // Green checkmark
                  countText: '1,204',
                  label: 'Active Sessions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cancel,
                  iconColor: const Color(0xFFC62828), // Red X
                  countText: '310',
                  label: 'Requests',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Semi-transparent Navy Metric Card
  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String countText,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
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
                countText,
                style: GoogleFonts.inter(
                  fontSize: 16,
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

  // Search and calendar filter row
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
              // Filter Action Trigger
              GestureDetector(
                onTap: () => _selectDateRange(context),
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedDateRange != null
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
                    color: _selectedDateRange != null
                        ? const Color(0xFF3B48F6)
                        : (themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          // Active Date Chip
          if (_selectedDateRange != null) ...[
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
                      const Icon(Icons.calendar_today, size: 12, color: Color(0xFF3B48F6)),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatDateCompact(_selectedDateRange!.start)} - ${_formatDateCompact(_selectedDateRange!.end)}',
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
                            _selectedDateRange = null;
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
          ]
        ],
      ),
    );
  }

  // A. User Activity Card Block
  Widget _buildUserActivityCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Activity over 7 Days',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                ),
              ),
              // Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Last 7 Days',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.grey.shade300 : VeriFiColors.textGrey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bar Chart Grid Area
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_days.length, (index) {
                return Expanded(
                  child: _buildBarColumn(index, themeProvider),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build an individual bar column with interactive tooltip
  Widget _buildBarColumn(int index, ThemeProvider themeProvider) {
    final String day = _days[index];
    final int value = _activityValues[index];
    final double barHeight = (value / _maxActivity) * 120.0;
    final bool isTooltipActive = _activeTooltipIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_activeTooltipIndex == index) {
            _activeTooltipIndex = -1; // Toggle off
          } else {
            _activeTooltipIndex = index;
          }
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Tooltip container (drawn above the bar, transparent placeholder when inactive)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isTooltipActive ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF374151), // Dark gray tooltip
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$day: $value Users',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Visual Bar Container
          Container(
            height: barHeight,
            width: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF93C5FD), // Light blue vertical column
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Solid cap line at the top
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B48F6), // Darker accent blue cap
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Day label text
          Text(
            day,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // B. Requests by Organization Card Block
  Widget _buildRequestsByOrgCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Header
          Text(
            'Requests by Org',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          
          // Organization rows
          _buildOrgRow(context, 'ACES', 842, 0.85, themeProvider),
          _buildOrgRow(context, 'iSITE', 612, 0.70, themeProvider),
          _buildOrgRow(context, 'AFT', 429, 0.55, themeProvider),
          _buildOrgRow(context, 'DOMT', 310, 0.40, themeProvider),
          _buildOrgRow(context, 'JPCS', 188, 0.25, themeProvider),
        ],
      ),
    );
  }

  // Progress Bar and Actions Row for Department
  Widget _buildOrgRow(BuildContext context, String org, int count, double percentage, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left portion: labels and progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      org,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      ),
                    ),
                    Text(
                      '$count',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Horizontal Progress Bar
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B48F6), // System blue fill
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right portion: Pill Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View Details
              GestureDetector(
                onTap: () => _showOrgDetailsDialog(context, org, count),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // emerald green tint
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_outlined, color: Color(0xFF2E7D32), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Details',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Flag Issues
              GestureDetector(
                onTap: () => _showFlagIssuesDialog(context, org),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE), // coral tint
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_down_outlined, color: Color(0xFFC62828), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Flag',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC62828),
                        ),
                      ),
                    ],
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

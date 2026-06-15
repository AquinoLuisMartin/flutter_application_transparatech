import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/admin_notification_bell.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  final Function(int index, {String? orgFilter})? onNavigateToTab;
  const AdminAnalyticsScreen({super.key, this.onNavigateToTab});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class BarChartData {
  final String day;
  final int approved;
  final int rejected;
  final int reviewTimeMin;

  BarChartData({
    required this.day,
    required this.approved,
    required this.rejected,
    required this.reviewTimeMin,
  });

  int get total => approved + rejected;
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _activeFilter = 'Last 7 Days';
  int _activeTooltipIndex = -1;

  final Map<String, List<BarChartData>> _filterChartData = {
    'Last 7 Days': [
      BarChartData(day: 'Mon', approved: 12, rejected: 2, reviewTimeMin: 18),
      BarChartData(day: 'Tue', approved: 15, rejected: 3, reviewTimeMin: 21),
      BarChartData(day: 'Wed', approved: 14, rejected: 1, reviewTimeMin: 19),
      BarChartData(day: 'Thu', approved: 18, rejected: 4, reviewTimeMin: 22),
      BarChartData(day: 'Fri', approved: 22, rejected: 2, reviewTimeMin: 17),
      BarChartData(day: 'Sat', approved: 8, rejected: 1, reviewTimeMin: 15),
      BarChartData(day: 'Sun', approved: 6, rejected: 0, reviewTimeMin: 14),
    ],
    'Last 30 Days': [
      BarChartData(day: 'W1', approved: 58, rejected: 12, reviewTimeMin: 20),
      BarChartData(day: 'W2', approved: 65, rejected: 8, reviewTimeMin: 18),
      BarChartData(day: 'W3', approved: 72, rejected: 15, reviewTimeMin: 19),
      BarChartData(day: 'W4', approved: 80, rejected: 10, reviewTimeMin: 17),
    ],
    'This Year': [
      BarChartData(day: 'Q1', approved: 220, rejected: 35, reviewTimeMin: 19),
      BarChartData(day: 'Q2', approved: 245, rejected: 40, reviewTimeMin: 20),
      BarChartData(day: 'Q3', approved: 210, rejected: 28, reviewTimeMin: 18),
      BarChartData(day: 'Q4', approved: 280, rejected: 50, reviewTimeMin: 17),
    ],
    'All Time': [
      BarChartData(day: '23', approved: 450, rejected: 85, reviewTimeMin: 22),
      BarChartData(day: '24', approved: 620, rejected: 95, reviewTimeMin: 20),
      BarChartData(day: '25', approved: 840, rejected: 110, reviewTimeMin: 19),
      BarChartData(day: '26', approved: 980, rejected: 130, reviewTimeMin: 18),
    ],
  };

  String _getVelocityTitle() {
    switch (_activeFilter) {
      case 'Last 7 Days':
        return 'Processing Velocity over 7 Days';
      case 'Last 30 Days':
        return 'Processing Velocity over 30 Days';
      case 'This Year':
        return 'Processing Velocity this Year';
      case 'All Time':
        return 'Processing Velocity All Time';
      default:
        return 'Processing Velocity over 7 Days';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final activeData = _filterChartData[_activeFilter] ?? _filterChartData['Last 7 Days']!;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 1. Fixed Top Header Module
          _buildHeader(context, themeProvider),

          // 2. Main Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // A. Processing Velocity Widget
                  _buildProcessingVelocityWidget(context, themeProvider, activeData),
                  const SizedBox(height: 20),

                  // B. Requests by Org Directory list
                  _buildRequestsByOrgWidget(context, themeProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
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
                  const AdminNotificationBell(),
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
          
          // Performance KPI Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.access_time_filled,
                  iconColor: const Color(0xFFFFB020),
                  countText: '82',
                  label: 'Total Submissions',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF2E7D32),
                  countText: '18 min',
                  label: 'Avg. Review Time',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cancel,
                  iconColor: const Color(0xFFC62828),
                  countText: '21',
                  label: 'Pending Backlog',
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

  Widget _buildProcessingVelocityWidget(BuildContext context, ThemeProvider themeProvider, List<BarChartData> data) {
    final double maxVal = data.map((e) => e.total).reduce((a, b) => a > b ? a : b).toDouble();
    final double limit = maxVal > 0 ? maxVal * 1.2 : 30.0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getVelocityTitle(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                offset: const Offset(0, 36),
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (String val) {
                  setState(() {
                    _activeFilter = val;
                    _activeTooltipIndex = -1;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Last 7 Days',
                    child: Text(
                      'Last 7 Days',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1F2937), fontWeight: FontWeight.w500),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'Last 30 Days',
                    child: Text(
                      'Last 30 Days',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1F2937), fontWeight: FontWeight.w500),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'This Year',
                    child: Text(
                      'This Year',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1F2937), fontWeight: FontWeight.w500),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'All Time',
                    child: Text(
                      'All Time',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF1F2937), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _activeFilter,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 190,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double chartWidth = constraints.maxWidth;
                final int barCount = data.length;
                final double colWidth = chartWidth / barCount;
                final double tooltipWidth = 136.0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(barCount, (index) {
                        final item = data[index];
                        final double barHeight = limit > 0 ? (item.total / limit) * 110.0 : 0.0;
                        final bool isSelected = _activeTooltipIndex == index;
                        final bool isDimmed = _activeTooltipIndex != -1 && _activeTooltipIndex != index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_activeTooltipIndex == index) {
                                  _activeTooltipIndex = -1;
                                } else {
                                  _activeTooltipIndex = index;
                                }
                              });
                            },
                            child: Opacity(
                              opacity: isDimmed ? 0.5 : 1.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    height: barHeight + 4,
                                    width: colWidth * 0.65 > 36 ? 36 : colWidth * 0.65,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF93C5FD),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF3B48F6) : Colors.transparent,
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 4,
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF3B48F6),
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
                                  Text(
                                    item.day,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    if (_activeTooltipIndex != -1 && _activeTooltipIndex < barCount) ...[
                      Positioned(
                        left: (() {
                          double leftPos = _activeTooltipIndex * colWidth + (colWidth - tooltipWidth) / 2;
                          if (leftPos < 0) leftPos = 0;
                          if (leftPos > chartWidth - tooltipWidth) leftPos = chartWidth - tooltipWidth;
                          return leftPos;
                        })(),
                        bottom: (() {
                          final item = data[_activeTooltipIndex];
                          final double barHeight = limit > 0 ? (item.total / limit) * 110.0 : 0.0;
                          return barHeight + 40.0;
                        })(),
                        child: Container(
                          width: tooltipWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${data[_activeTooltipIndex].day} Details',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F2547),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Approved: ${data[_activeTooltipIndex].approved}',
                                style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF4B5563), fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rejected: ${data[_activeTooltipIndex].rejected}',
                                style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF4B5563), fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Review Time: ${data[_activeTooltipIndex].reviewTimeMin} min',
                                style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF4B5563), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsByOrgWidget(BuildContext context, ThemeProvider themeProvider) {
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
          Text(
            'Requests by Org',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),

          _buildOrgRow('ACES', 200, 50, 300, themeProvider),
          const SizedBox(height: 16),
          _buildOrgRow('iSITE', 140, 40, 220, themeProvider),
          const SizedBox(height: 16),
          _buildOrgRow('AFT', 100, 30, 180, themeProvider),
          const SizedBox(height: 16),
          _buildOrgRow('DOMT', 70, 20, 120, themeProvider),
          const SizedBox(height: 16),
          _buildOrgRow('JPCS', 50, 15, 90, themeProvider),
        ],
      ),
    );
  }

  Widget _buildOrgRow(String acronym, int approved, int flagged, int totalCount, ThemeProvider themeProvider) {
    final int maxCap = 300;
    final int remaining = maxCap - approved - flagged;

    return GestureDetector(
      onTap: () {
        widget.onNavigateToTab?.call(3, orgFilter: acronym);
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: Text(
                acronym,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    if (approved > 0)
                      Expanded(
                        flex: approved,
                        child: Container(
                          color: const Color(0xFF3B48F6),
                        ),
                      ),
                    if (flagged > 0)
                      Expanded(
                        flex: flagged,
                        child: Container(
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    if (remaining > 0)
                      Expanded(
                        flex: remaining,
                        child: const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),

            Text(
              '$totalCount',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.grey.shade300 : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

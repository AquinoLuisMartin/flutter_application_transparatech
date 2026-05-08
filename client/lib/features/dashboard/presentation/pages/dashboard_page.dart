import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifications_page.dart';
import 'settings_page.dart';

import 'package:flutter_application_transparatech/features/auth/presentation/pages/auth_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildDocumentCard({
    required String title,
    required String date,
    required String hash,
    bool isNew = false,
    bool showChevron = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.blue.shade600,
              size: 24,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.tag,
                      size: 10,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        hash,
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isNew) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA7F3D0).withValues(alpha: 0.5), // Light green tint
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'New',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF059669), // Emerald
                ),
              ),
            ),
          ],
          if (showChevron) ...[
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ]
        ],
      ),
    );
  }

  Widget _buildBar(double expensesHeight, double budgetHeight, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 120, // Max height of the bar area
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expenses Bar (Green)
              Container(
                width: 12,
                height: 120 * expensesHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399), // Emerald
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 4),
              // Budget Bar (Blue)
              Container(
                width: 12,
                height: 120 * budgetHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF60A5FA), // Blue
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({bool roundedBottom = true, Widget? bottomContent}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF132A42), // Very dark blue
        borderRadius: roundedBottom
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              )
            : null,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20, 
        left: 24, 
        right: 24, 
        bottom: roundedBottom ? 40 : 24
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, Iskolar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Juan Santos',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  // Notification Bell
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '3',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF3B48F6), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://ui-avatars.com/api/?name=Juan+Santos&background=0D8ABC&color=fff'), // Placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (bottomContent != null) ...[
            const SizedBox(height: 24),
            bottomContent,
          ],
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(roundedBottom: true),

          // Main Content Area
          Transform.translate(
              offset: const Offset(0, -20), // Pull banner up slightly over header
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transparency Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trending_up, color: Colors.blue.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Transparency Dashboard',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Access verified financial documents, audit reports, and organizational transparency metrics',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Recent Documents Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Recent Documents',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'View All',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF3B48F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Documents List
                    _buildDocumentCard(
                      title: 'COSC Society Q4 2025 Expense Report',
                      date: 'Mar 15, 2026',
                      hash: 'a3f2...c8b1',
                    ),
                    _buildDocumentCard(
                      title: 'Tech Summit 2026 Event Budget Proposal',
                      date: 'Mar 14, 2026',
                      hash: 'b7d9...e4a2',
                    ),
                    _buildDocumentCard(
                      title: 'COSC Membership Fee Collection - S.Y. 2025-2026',
                      date: 'Mar 12, 2026',
                      hash: 'c105...f5d3',
                    ),
                    const SizedBox(height: 32),

                    // Financial Overview Header
                    Text(
                      'Financial Overview',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latest 6 months',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Financial Chart Setup (Custom Built to avoid dependencies)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Custom Bar Chart Area
                          SizedBox(
                            height: 160, // Chart overall height
                            child: Stack(
                              children: [
                                // Grid Lines
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(5, (index) {
                                    final labels = ['100k', '80k', '60k', '40k', '20k', '0'];
                                    return Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          child: Text(
                                            labels[index],
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: Colors.grey.shade100,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                                // Bars
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0), // offset for Y-axis labels
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildBar(0.65, 0.55, 'Oct'),
                                      _buildBar(0.35, 0.65, 'Nov'),
                                      _buildBar(0.10, 0.75, 'Dec'),
                                      _buildBar(0.60, 0.80, 'Jan'),
                                      _buildBar(0.15, 0.45, 'Feb'),
                                      _buildBar(0.45, 0.35, 'Mar'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: 8, height: 8, color: const Color(0xFF34D399)),
                              const SizedBox(width: 6),
                              Text('Expenses', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                              const SizedBox(width: 24),
                              Container(width: 8, height: 8, color: const Color(0xFF60A5FA)),
                              const SizedBox(width: 6),
                              Text('Budget', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildSummaryHeaderCard(IconData icon, String amount, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
            const SizedBox(height: 12),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            roundedBottom: false,
            bottomContent: Row(
              children: [
                _buildSummaryHeaderCard(Icons.account_balance_wallet_outlined, 'P150,000', 'Total Budget'),
                const SizedBox(width: 8),
                _buildSummaryHeaderCard(Icons.receipt_long_outlined, 'P87,500', 'Total Expenses'),
                const SizedBox(width: 8),
                _buildSummaryHeaderCard(Icons.savings_outlined, 'P62,500', 'Remaining Funds'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transparency Report Button Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.description_outlined, color: Colors.blue.shade600, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transparency Report',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Latest 6 months',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.file_download_outlined, color: Colors.grey.shade600, size: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Chart Header
                Text(
                  'Budget vs Expenses',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Financial flow overtime (Latest 6 months)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),

                // Expanded Detailed Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(8, (index) {
                                final labels = ['300k', '200k', '100k', '80k', '60k', '40k', '20k', '0'];
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: Text(
                                        labels[index],
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.grey.shade100,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildBar(0.65, 0.55, 'Oct'),
                                  _buildBar(0.35, 0.65, 'Nov'),
                                  _buildBar(0.10, 0.75, 'Dec'),
                                  _buildBar(0.60, 0.80, 'Jan'),
                                  _buildBar(0.15, 0.45, 'Feb'),
                                  _buildBar(0.45, 0.35, 'Mar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 8, height: 8, color: const Color(0xFF34D399)),
                          const SizedBox(width: 6),
                          Text('Expenses', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                          const SizedBox(width: 24),
                          Container(width: 8, height: 8, color: const Color(0xFF60A5FA)),
                          const SizedBox(width: 6),
                          Text('Budget', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Expense Breakdown
                Text(
                  'Expense Breakdown',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Where the money goes',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildExpenseRow('Tanglaw', '31.5% of total', 'P27,562', const Color(0xFF3B82F6), 0.7),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.grey.shade100, height: 1),
                      ),
                      _buildExpenseRow('Foundation Week', '25.3% of total', 'P22,137', const Color(0xFF8B5CF6), 0.5),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.grey.shade100, height: 1),
                      ),
                      _buildExpenseRow('IT Days', '16.2% of total', 'P14,175', const Color(0xFF06B6D4), 0.3),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Colors.grey.shade100, height: 1),
                      ),
                      _buildExpenseRow('IT Night', '27% of total', 'P23,625', const Color(0xFF10B981), 0.6),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Expenses',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            'P87,500',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(String title, String subtitle, String amount, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section without rounded border
        _buildHeader(roundedBottom: false),

        // Rest of body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search & Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(Icons.filter_list, color: Colors.grey.shade600, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'All Documents',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                // Documents List with variations
                _buildDocumentCard(
                  title: 'COSC Society Q4 2025 Expense Report',
                  date: 'Mar 15, 2026',
                  hash: 'a3f2...c8b1',
                  showChevron: true,
                ),
                _buildDocumentCard(
                  title: 'Tech Summit 2026 Event Budget Proposal',
                  date: 'Mar 14, 2026',
                  hash: 'b7d9...e4a2',
                  showChevron: true,
                ),
                _buildDocumentCard(
                  title: 'COSC Membership Fee Collection - S.Y. 2025-2026',
                  date: 'Mar 12, 2026',
                  hash: 'c1e8...f5d3',
                  showChevron: true,
                ),
                _buildDocumentCard(
                  title: 'SSC-COSC Joint Sponsorship Agreement',
                  date: 'Mar 10, 2026',
                  hash: 'd4f7...a6c4',
                  isNew: true,
                  showChevron: true,
                ),
                _buildDocumentCard(
                  title: 'COSC Membership Fee Collection - S.Y. 2025-2026',
                  date: 'Mar 12, 2026',
                  hash: 'c1e8...f5d3',
                  showChevron: true,
                ),
                _buildDocumentCard(
                  title: 'SSC-COSC Joint Sponsorship Agreement',
                  date: 'Mar 10, 2026',
                  hash: 'd4f7...a6c4',
                  isNew: true,
                  showChevron: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String body,
    required String date,
    required String time,
    bool isPinned = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (isPinned) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.push_pin, color: const Color(0xFF3B48F6), size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$date • $time',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(roundedBottom: false),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search & Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(Icons.filter_list, color: Colors.grey.shade600, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Pinned Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.push_pin_outlined, size: 18, color: Color(0xFF1F2937)),
                    const SizedBox(width: 8),
                    Text(
                      'Pinned',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildAnnouncementCard(
                  title: 'COSC Society Q4 2025 Expense Report',
                  body: 'All Q4 2025 COSC Society financial documents analyzed. 94.5% data extraction accuracy achieved. 1 sponsorship agreement flagged for hash mismatch - manual review recommended.',
                  date: 'March 15, 2026',
                  time: '11:59 PM',
                  isPinned: true,
                ),
                _buildAnnouncementCard(
                  title: 'New Document Submission Deadline',
                  body: 'All organizations must submit Q1 2026 financial reports by April 15, 2026. Late submissions may affect compliance scores.',
                  date: 'March 15, 2026',
                  time: '11:59 PM',
                  isPinned: true,
                ),

                const SizedBox(height: 24),

                // All Announcements Section
                Text(
                  'All Announcements',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                _buildAnnouncementCard(
                  title: 'COSC Society Q4 2025 Expense Report',
                  body: 'All Q4 2025 COSC Society financial documents analyzed. 94.5% data extraction accuracy achieved. 1 sponsorship agreement flagged for hash mismatch - manual review recommended.',
                  date: 'March 15, 2026',
                  time: '11:59 PM',
                ),
                _buildAnnouncementCard(
                  title: 'New Document Submission Deadline',
                  body: 'All organizations must submit Q1 2026 financial reports by April 15, 2026. Late submissions may affect compliance scores.',
                  date: 'March 15, 2026',
                  time: '11:59 PM',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, Color color, {bool isDestructive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDestructive ? Colors.red.shade100 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isDestructive ? FontWeight.bold : FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: isDestructive ? Colors.red.shade300 : Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Column(
      children: [
        _buildHeader(roundedBottom: false),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B48F6), Color(0xFF0EA5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'JS',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Name and Email
                Text(
                  'Juan Dela Cruz Santos',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'juan.santos@iskolarngbayan.pup.edu.ph',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 12),

                // Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.blue.shade600, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Authorized Member',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Student ID', '2023-00001-SM-0'),
                      Divider(color: Colors.grey.shade100, height: 1),
                      _buildInfoRow('Organization', 'ISITE'),
                      Divider(color: Colors.grey.shade100, height: 1),
                      _buildInfoRow('Campus', 'PUP Sta. Maria, Bulacan'),
                      Divider(color: Colors.grey.shade100, height: 1),
                      _buildInfoRow('Role', 'Student'),
                      Divider(color: Colors.grey.shade100, height: 1),
                      _buildInfoRow('Member Since', 'September 2023'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                  child: _buildActionRow(Icons.settings_outlined, 'Account Settings', const Color(0xFF1F2937)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                      (route) => false,
                    );
                  },
                  child: _buildActionRow(Icons.logout, 'Log Out', Colors.redAccent, isDestructive: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF3B48F6),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Documents'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Announcements'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
      body: _selectedIndex == 0 
          ? _buildHomeTab() 
          : _selectedIndex == 1 
              ? _buildDocumentsTab() 
              : _selectedIndex == 2 
                  ? _buildReportsTab() 
                  : _selectedIndex == 3
                      ? _buildAnnouncementsTab()
                      : _selectedIndex == 4
                          ? _buildProfileTab()
                          : Center(
                              child: Text(
                                'Coming Soon',
                                style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
                              ),
                            ),
    );
  }
}

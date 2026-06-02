import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/providers/officer_provider.dart';
import 'package:flutter_application_transparatech/features/officer/data/models/officer_models.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/pages/officer_dashboard_page.dart';

class OfficerHomePage extends StatelessWidget {
  const OfficerHomePage({super.key});

  static const Color primaryBlue = Color(0xFF3B48F6);
  static const Color navyDark = Color(0xFF132A42);
  static const Color bgSoft = Color(0xFFF8FAFC);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF64748B);

  void _navigateToVault(BuildContext context) {
    final state = context.findAncestorStateOfType<State<OfficerDashboardPage>>();
    if (state != null) {
      // Accessing private _onItemTapped via a hack or public method
      // Better: Use a controller or provider for dashboard index
      // For now, let's assume we can navigate to Vault
      final dashboardState = state as dynamic;
      try {
        dashboardState.onItemTapped(1);
      } catch (e) {
        // Fallback or ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final officerProvider = Provider.of<OfficerProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final stats = officerProvider.stats;
    final docs = officerProvider.documents;

    return Scaffold(
      backgroundColor: bgSoft,
      body: officerProvider.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final token = authProvider.token;
                if (token != null) {
                  await officerProvider.fetchStats(token);
                  await officerProvider.fetchDocuments(token);
                }
              },
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, user?.firstName ?? 'Officer'),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeHeader(user?.firstName ?? 'Officer'),
                          const SizedBox(height: 32),
                          _buildStatsGrid(stats),
                          const SizedBox(height: 40),
                          _buildSectionHeader('Priority Actions', () {}),
                          const SizedBox(height: 16),
                          _buildPriorityActions(context),
                          const SizedBox(height: 40),
                          _buildSectionHeader('Recent Submissions', () => _navigateToVault(context)),
                          const SizedBox(height: 16),
                          _buildRecentSubmissions(docs),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String name) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: navyDark,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Text(
          'Command Center',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [navyDark, navyDark.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'O',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good morning, $name',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textMain,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is what is happening with your organization today.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textLight,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(OfficerStats? stats) {
    String pendingCount = '0';
    if (stats != null) {
      for (var s in stats.byStatus) {
        if (s.status == 'PENDING') pendingCount = s.count.toString();
      }
    }

    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildCompactStatCard('Pending Review', pendingCount, Icons.pending_actions_rounded, Colors.orange),
        _buildCompactStatCard('Compliance', '${stats?.complianceScore ?? 0}%', Icons.verified_user_rounded, Colors.green),
        _buildCompactStatCard('Active Docs', '${stats?.totalActive ?? 0}', Icons.description_rounded, primaryBlue),
        _buildCompactStatCard('Org Score', '${stats?.transparencyIndex ?? 0}', Icons.star_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildCompactStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textMain,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
            textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildPriorityActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildActionCard(
            'New Submission',
            'Finalize the Q1 report',
            Icons.add_task_rounded,
            primaryBlue,
            onTap: () {
               final state = context.findAncestorStateOfType<State<OfficerDashboardPage>>();
               if (state != null) {
                 final dashboardState = state as dynamic;
                 try {
                   dashboardState.onItemTapped(2); // Index 2 is submission
                 } catch (e) {}
               }
            }
          ),
          const SizedBox(width: 16),
          _buildActionCard(
            'Review Audit',
            '3 files need your attention',
            Icons.rate_review_rounded,
            Colors.purple,
            onTap: () {
              // TODO: Navigate to reviews/reports
            }
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSubmissions(List<OfficerDocument> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No recent submissions', style: GoogleFonts.inter(color: textLight)),
        ),
      );
    }

    final recentDocs = docs.take(5).toList();

    return Column(
      children: recentDocs.map((doc) {
        Color statusColor = Colors.orange;
        if (doc.status == 'APPROVED') statusColor = Colors.green;
        if (doc.status == 'REJECTED') statusColor = Colors.red;
        if (doc.status == 'ARCHIVED') statusColor = Colors.grey;
        if (doc.status == 'DRAFT') statusColor = Colors.blueGrey;
        
        String timeStr = '${doc.createdAt.day}/${doc.createdAt.month}/${doc.createdAt.year}';

        return _buildSubmissionTile(doc.title, timeStr, doc.status, statusColor);
      }).toList(),
    );
  }

  Widget _buildSubmissionTile(String title, String time, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.description_outlined, color: navyDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textMain,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


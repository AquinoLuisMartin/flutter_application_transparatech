import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/providers/officer_provider.dart';
import 'package:flutter_application_transparatech/features/officer/data/models/officer_models.dart';

class OfficerReportPage extends StatelessWidget {
  const OfficerReportPage({super.key});

  static const Color primaryBlue = Color(0xFF3B48F6);
  static const Color navyDark = Color(0xFF132A42);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF64748B);
  static const Color bgSoft = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final officerProvider = Provider.of<OfficerProvider>(context);
    final stats = officerProvider.stats;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Strategic Insights',
          style: GoogleFonts.inter(
            color: textMain,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: officerProvider.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumScoreCard(stats?.transparencyIndex ?? 0),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Operational Metrics'),
                  const SizedBox(height: 16),
                  _buildMetricGrid(stats),
                  const SizedBox(height: 40),
                  _buildSectionTitle('Compliance Distribution'),
                  const SizedBox(height: 16),
                  _buildChartPlaceholder(),
                  const SizedBox(height: 40),
                  _buildDownloadAction(),
                ],
              ),
            ),
    );
  }

  Widget _buildPremiumScoreCard(double score) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navyDark, Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: navyDark.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transparency Index',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '+2.4%',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text(
            score > 80 
                ? 'Excellent transparency standing in the organization.'
                : 'Maintain consistent submissions to improve score.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textMain,
      ),
    );
  }

  Widget _buildMetricGrid(OfficerStats? stats) {
    return Column(
      children: [
        Row(
          children: [
            _buildMetricTile('Submission Rate', '${stats?.complianceScore ?? 0}%', Icons.file_upload_outlined, Colors.blue),
            const SizedBox(width: 16),
            _buildMetricTile('Accuracy', '96%', Icons.fact_check_rounded, Colors.purple),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildMetricTile('Total Active', '${stats?.totalActive ?? 0}', Icons.timer_outlined, Colors.orange),
            const SizedBox(width: 16),
            _buildMetricTile('Compliance', 'Pass', Icons.verified_outlined, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgSoft,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
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
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_rounded, size: 64, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              'Distribution analytics arriving soon',
              style: GoogleFonts.inter(
                color: textLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadAction() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.file_download_rounded, color: Colors.white),
        label: Text(
          'Generate Comprehensive PDF',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: navyDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}


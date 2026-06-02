import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/officer/presentation/providers/officer_provider.dart';

class OfficerProfilePage extends StatelessWidget {
  const OfficerProfilePage({super.key});

  static const Color navyDark = Color(0xFF132A42);
  static const Color primaryBlue = Color(0xFF3B48F6);
  static const Color bgSoft = Color(0xFFF8FAFC);
  static const Color textMain = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final officerProvider = Provider.of<OfficerProvider>(context);
    final user = authProvider.currentUser;
    final stats = officerProvider.stats;

    return Scaffold(
      backgroundColor: bgSoft,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHeader(user, stats),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Account Management'),
                  const SizedBox(height: 16),
                  _buildProfileOption(Icons.person_outline_rounded, 'Personal Credentials', 'ID: ${user?.studentId ?? "N/A"}'),
                  _buildProfileOption(Icons.business_center_outlined, 'Organization Profile', 'Role ID: ${user?.roleId}'),
                  _buildProfileOption(Icons.security_rounded, 'Security Settings', 'Biometrics, PIN & Password'),
                  const SizedBox(height: 32),
                  _buildSectionTitle('System & Support'),
                  const SizedBox(height: 16),
                  _buildProfileOption(Icons.notifications_none_rounded, 'Communication Prefs', 'Alerts & updates'),
                  _buildProfileOption(Icons.help_outline_rounded, 'Knowledge Base', 'Tutorials & documentation'),
                  _buildProfileOption(
                    Icons.logout_rounded, 
                    'Sign Out', 
                    'Securely exit application', 
                    isDestructive: true,
                    onTap: () {
                      authProvider.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(dynamic user, dynamic stats) {
    String fullName = '${user?.firstName ?? "Officer"} ${user?.lastName ?? ""}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 80, 32, 48),
      decoration: const BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: Text(
                    user?.firstName?.isNotEmpty == true ? user!.firstName[0].toUpperCase() : 'O',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: navyDark, width: 3),
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            fullName,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'AUTHORIZED OFFICER',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderStat('${stats?.totalActive ?? 0}', 'Submissions'),
              Container(width: 1, height: 24, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 32)),
              _buildHeaderStat('${stats?.complianceScore ?? 0}%', 'Accuracy'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, {bool isDestructive = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : primaryBlue).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: isDestructive ? Colors.red : primaryBlue, size: 22),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDestructive ? Colors.red : textMain,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}


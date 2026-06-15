import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';

class AdminPersonalInfoScreen extends StatelessWidget {
  const AdminPersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    // Theme-derived styles and colors
    final Color backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB);
    final Color headerColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF374151);
    final Color textSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final Color textLabel = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);
    final Color rowDividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);

    const Color systemBlue = Color(0xFF3B48F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Sub-Screen Header Navigation Bar
            Container(
              height: 56,
              color: headerColor,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.arrow_back,
                              color: textPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Personal Information',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Ultra-thin divider under header
            Container(
              height: 1,
              color: dividerColor,
            ),

            // Main body scrollable view
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // 2. Core Profile Avatar Stack
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2547), // Dark navy blue
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: systemBlue, // Bright blue border outline
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'LL',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile Text Information Stack
                    Text(
                      'luis luis',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'luis@iskolarngbayan.pup.edu.ph',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Clearance Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: systemBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.security_outlined, // Subtle shield line-art vector icon
                            color: systemBlue,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Authorized Administrator',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: systemBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 3. Symmetrical Signup-Aligned Details Dossier Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            _buildDossierRow(
                              label: 'Admin ID',
                              value: '2023-00001-SM-A',
                              labelColor: textLabel,
                              valueColor: textPrimary,
                            ),
                            Container(
                              height: 1,
                              color: rowDividerColor,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            _buildDossierRow(
                              label: 'Scope/Station',
                              value: 'HQ - Central Administration',
                              labelColor: textLabel,
                              valueColor: textPrimary,
                            ),
                            Container(
                              height: 1,
                              color: rowDividerColor,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            _buildDossierRow(
                              label: 'Campus',
                              value: 'PUP Sta. Maria, Bulacan',
                              labelColor: textLabel,
                              valueColor: textPrimary,
                            ),
                            Container(
                              height: 1,
                              color: rowDividerColor,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            _buildDossierRow(
                              label: 'Role',
                              value: 'Administrator',
                              labelColor: textLabel,
                              valueColor: textPrimary,
                            ),
                            Container(
                              height: 1,
                              color: rowDividerColor,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            _buildDossierRow(
                              label: 'Member Since',
                              value: 'June 2026',
                              labelColor: textLabel,
                              valueColor: textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierRow({
    required String label,
    required String value,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Margin Label: Light gray regular text
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: labelColor,
            ),
          ),
          const SizedBox(width: 16),
          // Right Margin Label: Dark gray/white medium text
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_roles_permissions_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_audit_logs_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_general_settings_page.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 1. Fixed Top Header Module
          _buildHeader(context),

          // Main Body content (Scroll Area)
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Category Labels & Sub-headers
                  Text(
                    'System Configuration and Administration',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Header: User & Access Management
                  Text(
                    'USER & ACCESS MANAGEMENT',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Group A Cards
                  _buildSettingsCard(
                    context: context,
                    title: 'Roles & Permissions',
                    description: 'Manage user roles and access rights',
                    icon: Icons.shield_outlined,
                    themeProvider: themeProvider,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminRolesPermissionsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(
                    context: context,
                    title: 'Audit Log',
                    description: 'View system activity and user actions',
                    icon: Icons.history,
                    themeProvider: themeProvider,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminAuditLogsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section Header: System Configuration
                  Text(
                    'SYSTEM CONFIGURATION',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Group B Cards
                  _buildSettingsCard(
                    context: context,
                    title: 'General Settings',
                    description: 'Configure system preferences',
                    icon: Icons.settings_outlined,
                    themeProvider: themeProvider,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminGeneralSettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      // 4. Fixed Bottom Navigation Bar (Inactive state representation)
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
          currentIndex: 0, // Inactive visual state logic
          onTap: (index) {
            // Functional redirect back to active tab
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardPage(initialIndex: index)),
              (route) => false,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          selectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400, // force inactive muted color
          unselectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400, // force inactive muted color
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

  // Header banner layout with deep navy background
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2547), // Solid Deep Navy Blue
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, // vertical alignment constraint with content blocks
        right: 20,
        bottom: 20,
      ),
      child: Row(
        children: [
          // Circular back button
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
          // Title String
          Text(
            'Admin Settings',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Settings Category option card component
  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required ThemeProvider themeProvider,
    bool disabled = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: disabled
          ? () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$title has moved to Account Settings.',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF3B48F6),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          : (onTap ?? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text('Opening $title details...', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  backgroundColor: const Color(0xFF3B48F6),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }),
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
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
          children: [
            // Left purple background badge container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF3B0764).withValues(alpha: 0.3) : const Color(0xFFF3E8FF), // soft purple
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: themeProvider.isDarkMode ? const Color(0xFFC084FC) : const Color(0xFF7E22CE), // dark purple outline icon
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Center Option Information stack
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Right Chevron hint icon
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 18,
            ),
          ],
        ),
      ),
    ),
  );
  }
}

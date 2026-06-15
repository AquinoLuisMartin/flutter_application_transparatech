import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_personal_info_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_notification_settings_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_security_privacy_page.dart';

class AdminAccountSettingsScreen extends StatefulWidget {
  const AdminAccountSettingsScreen({super.key});

  @override
  State<AdminAccountSettingsScreen> createState() => _AdminAccountSettingsScreenState();
}

class _AdminAccountSettingsScreenState extends State<AdminAccountSettingsScreen> {
  // Translate current themeMode to friendly string representation
  String _getThemeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Helper method to trigger the Appearance Theme Selection bottom drawer
  void _showAppearanceDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4), // transparent gray mask overlay
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const AppearanceSelectionDrawer();
      },
    );
  }

  // Standard helper to show alerts for not implemented settings options
  void _showNotImplementedAlert(BuildContext context, String featureName) {
    showAlertDialog(
      context: context,
      title: 'Under Construction',
      message: '$featureName settings are not implemented yet.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final String activeThemeText = _getThemeText(themeProvider.themeMode);

    return Scaffold(
      backgroundColor: Colors.white, // Clear, solid white (#FFFFFF) background panel layout
      body: SafeArea(
        child: Column(
          children: [
            // 2. Fixed Top Navigation Header
            _buildHeader(context),

            // 3. Settings Options Directory List (Scroll Area)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Personal Information option
                    _buildSettingsRow(
                      context: context,
                      label: 'Personal information',
                      icon: Icons.person_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPersonalInfoScreen(),
                          ),
                        );
                      },
                    ),

                    // Appearance option (Interactive Theme Selection Trigger)
                    _buildSettingsRow(
                      context: context,
                      label: 'Appearance',
                      icon: Icons.palette_outlined,
                      specialValue: activeThemeText,
                      onTap: () => _showAppearanceDrawer(context),
                    ),

                    // Translation option
                    _buildSettingsRow(
                      context: context,
                      label: 'Translation',
                      iconWidget: _buildTranslationIcon(const Color(0xFF374151)),
                      onTap: () => _showNotImplementedAlert(context, 'Translation'),
                    ),

                    // Notifications option
                    _buildSettingsRow(
                      context: context,
                      label: 'Notifications',
                      icon: Icons.notifications_none_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminNotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),

                    // Privacy and sharing option
                    _buildSettingsRow(
                      context: context,
                      label: 'Privacy and sharing',
                      icon: Icons.lock_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminSecurityPrivacyScreen(),
                          ),
                        );
                      },
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

  // Header banner builder
  Widget _buildHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bounding box for navigation arrow aligns perfectly with left margin
              GestureDetector(
                onTap: () => Navigator.pop(context),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFF374151), // Dark gray
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Account settings',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500, // Medium-weight
                  color: const Color(0xFF374151), // Dark gray
                ),
              ),
            ],
          ),
        ),
        // Faint, ultra-thin light gray horizontal divider line
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE5E7EB),
        ),
      ],
    );
  }

  // Helper builder for flat settings row options
  Widget _buildSettingsRow({
    required BuildContext context,
    required String label,
    IconData? icon,
    Widget? iconWidget,
    String? specialValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            // Left Element Column: Outline line-art icon
            iconWidget ?? Icon(
              icon,
              color: const Color(0xFF374151), // Dark gray outline icon
              size: 22,
            ),
            const SizedBox(width: 16),

            // Center Typography: Preference name string
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400, // Regular font
                  color: const Color(0xFF374151), // Dark gray
                ),
              ),
            ),

            // Special Value layout (e.g. System, Light, Dark tracking token)
            if (specialValue != null) ...[
              Text(
                specialValue,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF), // Muted gray text token
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Right Action Hint: chevron arrow (>)
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF), // Soft gray chevron
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // Draw Two layered uppercase 'A' characters symbolizing multi-language translation
  Widget _buildTranslationIcon(Color color) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        children: [
          // Background 'A' (offset top-left, slightly smaller & muted)
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              'A',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.4),
                height: 1.0,
              ),
            ),
          ),
          // Foreground 'A' (offset bottom-right, standard color)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              color: Colors.white, // background mask to prevent background blending
              child: Text(
                'A',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Appearance Theme selection Drawer
class AppearanceSelectionDrawer extends StatelessWidget {
  const AppearanceSelectionDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Color activeColor = const Color(0xFF3B48F6); // System blue active token color
    final Color textDark = const Color(0xFF1F2937);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), // Heavily rounded top corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drawer Header
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 16),
            child: Text(
              'Appearance',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold, // Bold dark gray title
                color: textDark,
              ),
            ),
          ),

          // Light Mode Option
          _buildSelectionRow(
            context: context,
            label: 'Light',
            icon: Icons.wb_sunny_outlined, // Sun with rays outline icon
            isSelected: themeProvider.themeMode == ThemeMode.light,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(context); // Dismiss drawer on choice selection
            },
            activeColor: activeColor,
            textDark: textDark,
          ),

          const Divider(height: 8, color: Color(0xFFF3F4F6)),

          // Dark Mode Option
          _buildSelectionRow(
            context: context,
            label: 'Dark',
            icon: Icons.nightlight_round_outlined, // Crescent moon outline icon
            isSelected: themeProvider.themeMode == ThemeMode.dark,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(context); // Dismiss drawer on choice selection
            },
            activeColor: activeColor,
            textDark: textDark,
          ),

          const Divider(height: 8, color: Color(0xFFF3F4F6)),

          // System Default Option
          _buildSelectionRow(
            context: context,
            label: 'System',
            iconWidget: _buildDesktopCloudIcon(const Color(0xFF4B5563)),
            isSelected: themeProvider.themeMode == ThemeMode.system,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(context); // Dismiss drawer on choice selection
            },
            activeColor: activeColor,
            textDark: textDark,
          ),
        ],
      ),
    );
  }

  // Draw selection row list component
  Widget _buildSelectionRow({
    required BuildContext context,
    required String label,
    IconData? icon,
    Widget? iconWidget,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color textDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          children: [
            // Left icon representation
            iconWidget ?? Icon(
              icon,
              color: const Color(0xFF374151), // Dark gray outline line-art icon
              size: 22,
            ),
            const SizedBox(width: 14),

            // Center typography option label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: textDark,
                ),
              ),
            ),

            // Right Radio indicator badge selection
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                color: isSelected ? activeColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to construct Desktop screen monitor outline with Cloud symbol inside
  Widget _buildDesktopCloudIcon(Color color) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: DesktopCloudIconPainter(color: color),
      ),
    );
  }
}

// Custom painter to draw exact desktop screen monitor + cloud outline symbol
class DesktopCloudIconPainter extends CustomPainter {
  final Color color;
  DesktopCloudIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final double screenHeight = size.height * 0.65;
    final double screenWidth = size.width;

    // Monitor outer frame rect
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 1, screenWidth, screenHeight),
      const Radius.circular(3),
    );
    canvas.drawRRect(screenRect, paint);

    // Stand link line to base
    canvas.drawLine(
      Offset(screenWidth * 0.5, screenHeight + 1),
      Offset(screenWidth * 0.5, size.height - 2),
      paint,
    );

    // Base horizontal bar line
    canvas.drawLine(
      Offset(screenWidth * 0.25, size.height - 2),
      Offset(screenWidth * 0.75, size.height - 2),
      paint,
    );

    // Cloud outline symbol inside screen
    final double cx = screenWidth / 2;
    final double cy = screenHeight / 2 + 1;

    final cloudPath = Path();
    cloudPath.moveTo(cx - 4.5, cy + 2.0);
    cloudPath.lineTo(cx + 4.5, cy + 2.0);

    // Right loop arc
    cloudPath.arcToPoint(
      Offset(cx + 4.5, cy - 1.2),
      radius: const Radius.circular(1.6),
      clockwise: false,
    );

    // Main top header arc
    cloudPath.arcToPoint(
      Offset(cx - 1.8, cy - 1.8),
      radius: const Radius.circular(3.0),
      clockwise: false,
    );

    // Left loop arc
    cloudPath.arcToPoint(
      Offset(cx - 4.5, cy + 2.0),
      radius: const Radius.circular(1.8),
      clockwise: false,
    );

    canvas.drawPath(cloudPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

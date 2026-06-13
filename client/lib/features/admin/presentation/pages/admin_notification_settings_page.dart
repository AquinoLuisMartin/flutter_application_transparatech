import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_dashboard_page.dart';

class AdminNotificationSettingsScreen extends StatefulWidget {
  const AdminNotificationSettingsScreen({super.key});

  @override
  State<AdminNotificationSettingsScreen> createState() => _AdminNotificationSettingsScreenState();
}

class _AdminNotificationSettingsScreenState extends State<AdminNotificationSettingsScreen> {
  // Toggle states
  bool _realTimePush = true;
  bool _headerBadge = true;

  // Checkbox states
  bool _alertNewDoc = true;
  bool _alertStatusChange = true;
  bool _alertSystemUpdate = false;

  // Track if any modification has been made (to trigger discard warning)
  bool _isModified = false;

  void _markModified() {
    if (!_isModified) {
      setState(() {
        _isModified = true;
      });
    }
  }

  // Custom Toggle switch builder (smooth animated knob slide)
  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
        _markModified();
      },
      child: Container(
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  // Custom Checkbox builder with scale/fade animations and system blue background
  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
        _markModified();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox block
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF3B48F6) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value 
                      ? const Color(0xFF3B48F6) 
                      : (themeProvider.isDarkMode ? const Color(0xFF475569) : const Color(0xFF9CA3AF)),
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Text Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                  color: value
                      ? (themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark)
                      : (themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF4B5563)),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Centered Save success micro-modal overlay
  void _showSaveSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5), // dim overlay background
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // heavily rounded
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular green checkmark badge
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF22C55E),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Notification Preferences Saved Successfully',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your alert routing and email trigger configurations have been locked and updated in the system files.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // System blue OK button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // close modal
                        Navigator.pop(this.context); // redirect to Settings directory page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B48F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Cancel discard warning micro-modal overlay
  void _showCancelWarningModal(BuildContext context) {
    if (!_isModified) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5), // dim overlay background
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular yellow exclamation warning badge
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Discard Changes?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to leave? Any pending modifications made to the notification preferences will be permanently lost.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Side-by-side action buttons
                  Row(
                    children: [
                      // Keep Configuring
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context), // exit modal
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4B5563),
                            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Keep Configuring',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Discard Changes (coral red)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close modal
                            Navigator.pop(this.context); // return immediately to Settings page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Discard',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
          // 1. Fixed Top Header Module (standardised layout matching settings pages)
          _buildHeader(context),

          // Scroll area
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Configuration Cards System
                  // Card Block A: Application Alerts
                  _buildCardBlockA(themeProvider),
                  const SizedBox(height: 20),

                  // Card Block B: Automated Email Triggers
                  _buildCardBlockB(themeProvider),
                  const SizedBox(height: 32),

                  // 3. Primary Form Actions (Base Buttons)
                  _buildBaseActionButtons(themeProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      // Fixed bottom navigation bar in inactive muted state representation
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardPage(initialIndex: index)),
              (route) => false,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          selectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
          unselectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
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
        left: 20, // vertical alignment constraint with content block cards
        right: 20,
        bottom: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular back chevron button
          GestureDetector(
            onTap: () => _showCancelWarningModal(context),
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
          // Title String & Subtitle Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Configure system alert routing and email routing preferences',
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

  // Card Block A: Application Alerts
  Widget _buildCardBlockA(ThemeProvider themeProvider) {
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
            'Application Alerts',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Row 1: Real-Time Push Notifications
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Real-Time Push Notifications',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.grey.shade200 : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Receive immediate browser and device alert banners',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildToggleSwitch(
                value: _realTimePush,
                onChanged: (val) {
                  setState(() {
                    _realTimePush = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1, color: Color(0xFFEEF2FF)),
          // Row 2: Header Badge Counters
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Header Badge Counters',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.grey.shade200 : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enable numeric red notification counters on the master bell icon',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildToggleSwitch(
                value: _headerBadge,
                onChanged: (val) {
                  setState(() {
                    _headerBadge = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card Block B: Automated Email Triggers
  Widget _buildCardBlockB(ThemeProvider themeProvider) {
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
            'Email Notifications',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Checkbox List options
          _buildCheckboxRow(
            label: 'Alert when a new document is submitted to the queue',
            value: _alertNewDoc,
            onChanged: (val) {
              setState(() {
                _alertNewDoc = val;
              });
            },
            themeProvider: themeProvider,
          ),
          const Divider(height: 16, thickness: 1, color: Color(0xFFEEF2FF)),
          _buildCheckboxRow(
            label: 'Alert when a document status changes (Approved/Rejected)',
            value: _alertStatusChange,
            onChanged: (val) {
              setState(() {
                _alertStatusChange = val;
              });
            },
            themeProvider: themeProvider,
          ),
          const Divider(height: 16, thickness: 1, color: Color(0xFFEEF2FF)),
          _buildCheckboxRow(
            label: 'Alert on system updates and scheduled downtime logs',
            value: _alertSystemUpdate,
            onChanged: (val) {
              setState(() {
                _alertSystemUpdate = val;
              });
            },
            themeProvider: themeProvider,
          ),
        ],
      ),
    );
  }

  // Base Panel Save/Cancel Action buttons
  Widget _buildBaseActionButtons(ThemeProvider themeProvider) {
    return Column(
      children: [
        // SAVE BUTTON
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _showSaveSuccessModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B48F6), // system blue
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'SAVE NOTIFICATION CONFIGURATION',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // CANCEL BUTTON
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _showCancelWarningModal(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: themeProvider.isDarkMode ? Colors.white : const Color(0xFF4B5563),
              backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              side: BorderSide(
                color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

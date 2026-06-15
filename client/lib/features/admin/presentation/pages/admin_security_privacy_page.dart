import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';


class AdminSecurityPrivacyScreen extends StatefulWidget {
  const AdminSecurityPrivacyScreen({super.key});

  @override
  State<AdminSecurityPrivacyScreen> createState() => _AdminSecurityPrivacyScreenState();
}

class _AdminSecurityPrivacyScreenState extends State<AdminSecurityPrivacyScreen> {
  // Toggle states
  bool _mfaRequired = true;
  bool _auditLogHashing = false;

  // Dropdown states
  String _sessionTimeout = '30 Minutes';
  String _passwordExpiry = '90 Days';

  // Track if any modification has been made
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

  // Show vertical popup selection menu directly below dropdown button
  void _showDropdownMenu(
    BuildContext context, 
    String currentVal, 
    List<String> choices, 
    ValueChanged<String> onSelected, 
    Offset tapPos
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(tapPos.dx - 120, tapPos.dy, tapPos.dx + 120, tapPos.dy + 120),
      color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      items: choices.map((String choice) {
        final isSelected = choice == currentVal;
        return PopupMenuItem<String>(
          value: choice,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent, // soft blue highlight
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              choice,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? const Color(0xFF3B48F6) 
                    : (themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark),
              ),
            ),
          ),
        );
      }).toList(),
    ).then((String? newValue) {
      if (newValue != null) {
        onSelected(newValue);
        _markModified();
      }
    });
  }

  // Dropdown trigger layout
  Widget _buildDropdownField({
    required String value,
    required List<String> choices,
    required ValueChanged<String> onSelected,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showDropdownMenu(context, value, choices, onSelected, details.globalPosition);
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280),
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
                    'Security Controls Updated',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'All authentication mechanisms and data integrity configurations have been enforced.',
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
                    'Discard Security Updates?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to leave? Any pending modifications made to the security settings will be permanently lost.',
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
          // 1. Fixed Top Header Module
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
                  // Card Block A: Access & Authentication
                  _buildCardBlockA(themeProvider),
                  const SizedBox(height: 20),

                  // Card Block B: Data Privacy & Integrity
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
    );
  }

  // Header banner layout with synchronized white layout
  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final Color headerColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF374151);
    final Color textSecondary = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final Color dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      color: headerColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 72,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => _showCancelWarningModal(context),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 56),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Security & Privacy',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage system authentication controls, sessions, and data safety parameters',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: dividerColor,
          ),
        ],
      ),
    );
  }

  // Card Block A: Access & Authentication
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
            'Access & Authentication',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Row 1: MFA Enforcer
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mandate Two-Factor Authentication (2FA)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.grey.shade200 : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Require an extra security verification code for all Admin and Officer roles upon logging in',
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
                value: _mfaRequired,
                onChanged: (val) {
                  setState(() {
                    _mfaRequired = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1, color: Color(0xFFEEF2FF)),
          // Row 2: Session Timeout
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automatic Session Timeout',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.grey.shade200 : VeriFiColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Log out idle administrative sessions after a specific period of complete inactivity',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                ),
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                value: _sessionTimeout,
                choices: const ['15 Minutes', '30 Minutes', '1 Hour', 'Never'],
                onSelected: (val) {
                  setState(() {
                    _sessionTimeout = val;
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

  // Card Block B: Data Privacy & Integrity
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
            'Data Privacy & Integrity',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // Row 1: Password Expiry Frequency
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password Expiry Frequency',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.grey.shade200 : VeriFiColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Force administrative accounts to refresh security credentials periodically',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                ),
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                value: _passwordExpiry,
                choices: const ['60 Days', '90 Days', '180 Days', 'Never'],
                onSelected: (val) {
                  setState(() {
                    _passwordExpiry = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
          const Divider(height: 32, thickness: 1, color: Color(0xFFEEF2FF)),
          // Row 2: Audit Log Hashing
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Automated Audit Log Hashing',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.grey.shade200 : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encrypt and mask personal identification strings in archived records after 365 days',
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
                value: _auditLogHashing,
                onChanged: (val) {
                  setState(() {
                    _auditLogHashing = val;
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
              'ENFORCE SECURITY UPDATES',
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
              foregroundColor: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.6) : const Color(0xFF9CA3AF),
              backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              side: BorderSide(
                color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
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

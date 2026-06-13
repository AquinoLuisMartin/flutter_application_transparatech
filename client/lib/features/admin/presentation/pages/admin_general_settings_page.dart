import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_dashboard_page.dart';

class AdminGeneralSettingsScreen extends StatefulWidget {
  const AdminGeneralSettingsScreen({super.key});

  @override
  State<AdminGeneralSettingsScreen> createState() => _AdminGeneralSettingsScreenState();
}

class _AdminGeneralSettingsScreenState extends State<AdminGeneralSettingsScreen> {
  // Input Controllers
  final TextEditingController _orgNameController = TextEditingController(text: 'TransparaTech Inc.');
  final TextEditingController _emailController = TextEditingController(text: 'settings@transparatech.org');

  // Input Error states
  String? _orgNameError;
  String? _emailError;

  // Dropdown states
  String _fileSizeLimit = '5 MB';
  String _archivePeriod = '90 Days';

  // Checkbox states
  final Map<String, bool> _allowedFormats = {
    '.pdf': true,
    '.docx': true,
    '.xlsx': false,
    '.png': false,
  };

  // Slider State (0.0 to 100.0)
  double _aiSensitivity = 85.0;

  @override
  void initState() {
    super.initState();
    // Add text listeners for validation check
    _orgNameController.addListener(_validateOrgName);
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Real-time Organization name validation
  void _validateOrgName() {
    final text = _orgNameController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _orgNameError = 'Field cannot be blank';
      } else {
        _orgNameError = null;
      }
    });
  }

  // Real-time Email validation
  void _validateEmail() {
    final text = _emailController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _emailError = 'Field cannot be blank';
      } else if (!text.contains('@')) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  // Dropdown list overlay triggers
  void _showDropdownMenu(BuildContext context, String currentVal, List<String> choices, ValueChanged<String> onSelected, Offset tapPos) {
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
      }
    });
  }

  // Centered confirmation success micro-modal
  void _showSaveSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5), // Dim layout background view
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 36),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24), // heavily rounded corners
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
                  // Circular green badge checkmark
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
                    'Configuration Saved',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Global environment preferences have been updated successfully.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Full-width blue action button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close modal
                        Navigator.pop(this.context); // Redirect to settings page
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

  // Discard warning micro-modal layout
  void _showCancelWarningModal(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5), // dim background
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
                  // Circular yellow warning badge exclamation point
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
                    'Discard Settings Updates?',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to leave? Any pending modifications made to the system preferences will be permanently lost.',
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
                      // Left Button: Keep Configuring
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context), // close warning modal
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4B5563),
                            side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Keep Configuring',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right Button: Discard Changes
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close warning modal
                            Navigator.pop(this.context); // Redirect immediately back to settings screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444), // Solid coral/red
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            'Discard Changes',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
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

  // Validate form and save preferences action
  void _savePreferences() {
    _validateOrgName();
    _validateEmail();

    if (_orgNameError == null && _emailError == null) {
      _showSaveSuccessModal(context);
    }
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
                  Text(
                    'System Preferences & Configuration',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // A. Institutional Profile Section
                  _buildSectionTitle('INSTITUTIONAL PROFILE', themeProvider),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Organization Name',
                    controller: _orgNameController,
                    hintText: 'e.g. TransparaTech Inc.',
                    errorText: _orgNameError,
                    themeProvider: themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Contact Email',
                    controller: _emailController,
                    hintText: 'e.g. settings@transparatech.org',
                    errorText: _emailError,
                    themeProvider: themeProvider,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  // B. Dropdown Choice Pickers Section
                  _buildSectionTitle('FILE SIZE & ARCHIVE RULES', themeProvider),
                  const SizedBox(height: 12),
                  _buildDropdownRow(themeProvider),
                  const SizedBox(height: 24),

                  // C. Allowed File Formats Checkbox Row
                  _buildSectionTitle('ALLOWED FILE FORMATS', themeProvider),
                  const SizedBox(height: 12),
                  _buildFileFormatRow(themeProvider),
                  const SizedBox(height: 24),

                  // D. AI Engine Sensitivity Slider
                  _buildSectionTitle('AI ENGINE SENSITIVITY', themeProvider),
                  const SizedBox(height: 12),
                  _buildSensitivitySlider(themeProvider),
                  const SizedBox(height: 32),

                  // E. Base Action buttons
                  _buildBaseActionButtons(themeProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      // 5. Fixed Bottom Navigation Bar (Inactive state representation)
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
            // Functional redirect back to main dashboard
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboardPage(initialIndex: index)),
              (route) => false,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          selectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400, // forced inactive color
          unselectedItemColor: themeProvider.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400, // forced inactive color
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

  // Navy banner header
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2547), // Solid Deep Navy Blue
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, // vertical alignment constraint with content cards
        right: 20,
        bottom: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular back button chevron
          GestureDetector(
            onTap: () => _showCancelWarningModal(context), // Cancel check overlay before backing out
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
            'General Settings',
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

  Widget _buildSectionTitle(String text, ThemeProvider themeProvider) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
      ),
    );
  }

  // Custom text input with focus border outlines and validation errors
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? errorText,
    required ThemeProvider themeProvider,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError 
                  ? const Color(0xFFEF4444) // light red border error state
                  : (themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Focus(
            onFocusChange: (hasFocus) {
              // Trigger outline change upon focus via decoration container borders
            },
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFF3B48F6), width: 1.5), // Active focus system blue border outline
                ),
                errorBorder: InputBorder.none,
                focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEF4444), // red warning subtext
            ),
          ),
        ],
      ],
    );
  }

  // Side-by-side dropdown pickers row
  Widget _buildDropdownRow(ThemeProvider themeProvider) {
    return Row(
      children: [
        // Picker 1: File Size Limit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File Size Limit',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTapDown: (TapDownDetails details) {
                  _showDropdownMenu(
                    context, 
                    _fileSizeLimit, 
                    ['5 MB', '10 MB', '20 MB', '50 MB'], 
                    (val) {
                      setState(() {
                        _fileSizeLimit = val;
                      });
                    }, 
                    details.globalPosition,
                  );
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
                        _fileSizeLimit,
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
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Picker 2: Auto-Archive Period
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auto-Archive Period',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTapDown: (TapDownDetails details) {
                  _showDropdownMenu(
                    context, 
                    _archivePeriod, 
                    ['30 Days', '90 Days', '180 Days', '365 Days'], 
                    (val) {
                      setState(() {
                        _archivePeriod = val;
                      });
                    }, 
                    details.globalPosition,
                  );
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
                        _archivePeriod,
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Allowed Format custom Checkboxes Row
  Widget _buildFileFormatRow(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFEEF2FF),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _allowedFormats.keys.map((String key) {
          final isChecked = _allowedFormats[key] ?? false;

          return GestureDetector(
            onTap: () {
              setState(() {
                _allowedFormats[key] = !isChecked;
              });
            },
            child: Row(
              children: [
                // Checkbox Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isChecked 
                        ? const Color(0xFF3B48F6) // Solid active blue
                        : Colors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked 
                          ? const Color(0xFF3B48F6) 
                          : (themeProvider.isDarkMode ? const Color(0xFF475569) : const Color(0xFF9CA3AF)), // neutral unselected gray
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 16, color: Colors.white) // white checkmark icon
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  key,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                    color: isChecked
                        ? (themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark)
                        : (themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280)), // neutral unselected gray text
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Sensitivity Scrub Slider
  Widget _buildSensitivitySlider(ThemeProvider themeProvider) {
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
              Text(
                'Sensitivity Level',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                ),
              ),
              // Floating Digital Value indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B48F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_aiSensitivity.round()}%',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal Track slider knob
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF3B48F6), // trailing blue progress track
              inactiveTrackColor: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              thumbColor: Colors.white, // white circular handle knob
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 3),
              overlayColor: const Color(0xFF3B48F6).withValues(alpha: 0.12),
              trackHeight: 6,
            ),
            child: Slider(
              value: _aiSensitivity,
              min: 0.0,
              max: 100.0,
              divisions: 20,
              onChanged: (double value) {
                setState(() {
                  _aiSensitivity = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Base Panel Save/Cancel Action buttons
  Widget _buildBaseActionButtons(ThemeProvider themeProvider) {
    return Column(
      children: [
        // SAVE PREFERENCES Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _savePreferences,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B48F6), // system blue
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'SAVE PREFERENCES',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // CANCEL Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _showCancelWarningModal(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: themeProvider.isDarkMode ? Colors.white : const Color(0xFF4B5563),
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
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

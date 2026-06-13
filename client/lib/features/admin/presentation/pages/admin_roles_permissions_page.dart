import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';

class AdminRolesPermissionsScreen extends StatefulWidget {
  const AdminRolesPermissionsScreen({super.key});

  @override
  State<AdminRolesPermissionsScreen> createState() => _AdminRolesPermissionsScreenState();
}

class _AdminRolesPermissionsScreenState extends State<AdminRolesPermissionsScreen> {
  // Role selection state for each module card
  String _accountsRole = 'STUDENT';
  String _activityRole = 'ADMIN';
  String _appsRole = 'ADMIN';
  String _assetsRole = 'OFFICERS';

  // Toggle state for accounts deactivate switch
  bool _isDeactivateActive = true;

  // Options list for dropdown menus
  final List<String> _roleOptions = ['STUDENT', 'OFFICERS', 'ADMIN'];

  // Custom Dropdown Picker menu trigger
  void _showRolePicker(BuildContext context, String currentRole, ValueChanged<String> onSelected, Offset tapPosition) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(tapPosition.dx, tapPosition.dy, tapPosition.dx + 50, tapPosition.dy + 50),
      color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: _roleOptions.map((String option) {
        final isSelected = option == currentRole;
        return PopupMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? const Color(0xFF3B48F6) 
                  : (themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // 2. Security Tier Overview Sub-header
                  _buildSecurityTierOverview(themeProvider),
                  const SizedBox(height: 24),

                  // 3. Permissions Matrix Cards (Scroll Area)
                  _buildAccountsCard(themeProvider),
                  const SizedBox(height: 16),
                  _buildActivityLogsCard(themeProvider),
                  const SizedBox(height: 16),
                  _buildAppsCard(themeProvider),
                  const SizedBox(height: 16),
                  _buildAssetsCard(themeProvider),
                  const SizedBox(height: 24),

                  // 4. Primary Form Actions
                  _buildFormActions(context, themeProvider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Deep Navy blue Header
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular touch target back button
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
          // Title stack (aligns with cards)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roles & Permissions',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Define user roles and access rights',
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

  // Security Tier Overview Sub-header
  Widget _buildSecurityTierOverview(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Title Centered
        Center(
          child: Text(
            'Admin Permissions Matrix',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Sub-header Row Left Aligned
        Text(
          'SECURITY TIER',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Small green status dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Administrator',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.grey.shade300 : VeriFiColors.textDark,
                  ),
                ),
              ],
            ),
            // Right status badge mint green
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7), // Mint green
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ACTIVE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF15803D), // dark green
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Description block
        Text(
          'Full unrestricted access to all organizational resources, system settings, and user management modules.',
          style: GoogleFonts.inter(
            fontSize: 12,
            height: 1.45,
            color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
          ),
        ),
      ],
    );
  }

  // Helper builder for Roles drop-down trigger button
  Widget _buildDropdownTrigger({
    required BuildContext context,
    required String value,
    required ValueChanged<String> onSelected,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _showRolePicker(context, value, onSelected, details.globalPosition);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  // Core icon badge builder depending on state and shape
  Widget _buildIconBadge({
    required IconData icon,
    required bool isEnabled,
    required bool isCircular,
    required ThemeProvider themeProvider,
  }) {
    if (isEnabled) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF3B48F6), // Filled active system blue
          borderRadius: BorderRadius.circular(10), // rounded square
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );
    } else {
      // Disabled/Inactive state
      if (isCircular) {
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: themeProvider.isDarkMode ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: themeProvider.isDarkMode ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
            size: 20,
          ),
        );
      } else {
        // Muted gray rounded square background block
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: themeProvider.isDarkMode ? Colors.grey.shade500 : const Color(0xFF9CA3AF),
            size: 20,
          ),
        );
      }
    }
  }

  // Toggle pill layout widget
  Widget _buildCustomTogglePill({
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 42,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1), // green when active, gray when inactive
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
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

  // Matrix Card Grid item wrapper
  Widget _buildGridItem({
    required Widget badge,
    required String label,
    required bool isEnabled,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isEnabled
                ? const Color(0xFF3B48F6) // highlighted system blue
                : (themeProvider.isDarkMode ? Colors.grey.shade500 : const Color(0xFF9CA3AF)), // muted gray
          ),
        ),
      ],
    );
  }

  // Card 1: Accounts layout
  Widget _buildAccountsCard(ThemeProvider themeProvider) {
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accounts',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'USER RECORDS & PROFILES',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDropdownTrigger(
                context: context,
                value: _accountsRole,
                onSelected: (val) {
                  setState(() {
                    _accountsRole = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom Grid Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.add, isEnabled: false, isCircular: true, themeProvider: themeProvider),
                label: 'CREATE',
                isEnabled: false,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.visibility, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'READ',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.edit, isEnabled: false, isCircular: true, themeProvider: themeProvider),
                label: 'EDIT',
                isEnabled: false,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildCustomTogglePill(
                  value: _isDeactivateActive,
                  onChanged: (val) {
                    setState(() {
                      _isDeactivateActive = val;
                    });
                  },
                  themeProvider: themeProvider,
                ),
                label: 'DEACTIVATE',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: Activity Logs layout
  Widget _buildActivityLogsCard(ThemeProvider themeProvider) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Logs',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AUDIT TRAILS & SYSTEM EVENTS',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDropdownTrigger(
                context: context,
                value: _activityRole,
                onSelected: (val) {
                  setState(() {
                    _activityRole = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom Grid Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.login, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'ACCESS',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.visibility, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'READ',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.flag, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'FLAGGED',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.inventory_2_outlined, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'ARCHIVE',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 3: Apps layout
  Widget _buildAppsCard(ThemeProvider themeProvider) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Apps',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'THIRD-PARTY INTEGRATIONS',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDropdownTrigger(
                context: context,
                value: _appsRole,
                onSelected: (val) {
                  setState(() {
                    _appsRole = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom Grid Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.add, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'ADD',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.visibility, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'READ',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.edit, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'EDIT',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.undo, isEnabled: false, isCircular: false, themeProvider: themeProvider),
                label: 'ROLLBACK',
                isEnabled: false,
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 4: Assets layout
  Widget _buildAssetsCard(ThemeProvider themeProvider) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assets',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PHYSICAL & DIGITAL RESOURCES',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDropdownTrigger(
                context: context,
                value: _assetsRole,
                onSelected: (val) {
                  setState(() {
                    _assetsRole = val;
                  });
                },
                themeProvider: themeProvider,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom Grid Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.add, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'CREATE',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.visibility, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'READ',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.edit, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'EDIT',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
              _buildGridItem(
                badge: _buildIconBadge(icon: Icons.delete_outline, isEnabled: true, isCircular: false, themeProvider: themeProvider),
                label: 'ARCHIVE',
                isEnabled: true,
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Primary Form Actions (Save / Cancel Stack)
  Widget _buildFormActions(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFEEF2FF),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Role changes saved successfully.', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    backgroundColor: VeriFiColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B48F6), // Solid active system blue
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'SAVE ROLE CHANGES',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
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
      ),
    );
  }
}

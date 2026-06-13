import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';

class OrganizationItem {
  final String fullName;
  final String acronym;
  final int memberCount;
  final String status;
  final IconData icon;

  OrganizationItem({
    required this.fullName,
    required this.acronym,
    required this.memberCount,
    this.status = 'ACTIVE',
    required this.icon,
  });
}

class AdminOrganizationsScreen extends StatefulWidget {
  const AdminOrganizationsScreen({super.key});

  @override
  State<AdminOrganizationsScreen> createState() => _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  // Mock initial organizations data list
  final List<OrganizationItem> _allOrganizations = [
    OrganizationItem(
      fullName: 'Integrated Students in Information Technology Education',
      acronym: 'iSITE',
      memberCount: 409,
      icon: Icons.lan_outlined,
    ),
    OrganizationItem(
      fullName: 'Alliance of Computer Engineering Students',
      acronym: 'ACES',
      memberCount: 231,
      icon: Icons.group_work_outlined,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reactive filtering using local search text
  List<OrganizationItem> get _filteredOrganizations {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      return _allOrganizations;
    }
    return _allOrganizations.where((org) {
      return org.fullName.toLowerCase().contains(query) ||
          org.acronym.toLowerCase().contains(query);
    }).toList();
  }

  // High-contrast Date Selection picker modal
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(useMaterial3: true).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B48F6), // Selected highlight system blue
              onPrimary: Colors.white,
              surface: Colors.white, // Modal background
              onSurface: Color(0xFF1F2937), // Inactive dates and headers high-contrast dark grey
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1F2937),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1F2937)),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B48F6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDateCompact(DateTime date) {
    return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
  }

  // Create/Add new institutional entry form modal
  void _showAddOrgDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final acronymController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add New Organization',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Full Name of Department',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name' : null,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Alliance of Computer Engineering Students',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B48F6), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Acronym',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: acronymController,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please enter an acronym' : null,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. ACES',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                    ),
                    filled: true,
                    fillColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3B48F6), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final String newName = nameController.text.trim();
                  final String newAcronym = acronymController.text.trim();
                  
                  setState(() {
                    _allOrganizations.add(
                      OrganizationItem(
                        fullName: newName,
                        acronym: newAcronym,
                        memberCount: 100 + (newName.length * 5) % 350,
                        icon: Icons.lan_outlined,
                      ),
                    );
                  });

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Added $newAcronym successfully!', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      backgroundColor: VeriFiColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B48F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Create',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final activeGroupsCount = _allOrganizations.length;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrgDialog(context),
        backgroundColor: const Color(0xFF3B48F6),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          // 1. Header Section (Top View)
          _buildHeader(context, themeProvider, activeGroupsCount),

          // 2. Search & Filter Bar (Mid View)
          _buildSearchAndFilters(context, themeProvider),

          // 3. Institutional Feed Cards (Scroll Area)
          Expanded(
            child: _filteredOrganizations.isEmpty
                ? _buildEmptyState(themeProvider)
                : ListView.builder(
                    itemCount: _filteredOrganizations.length,
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 80),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _filteredOrganizations[index];
                      return _buildOrganizationCard(context, item, themeProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Header Block layout with navy background
  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider, int activeGroups) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'admin admin';

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2547), // Deep navy blue background
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting Text (Left)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning, Iskolar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fullName,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Controls Row (Right)
              Row(
                children: [
                  Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 18,
                  ),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (val) {
                      themeProvider.toggleTheme();
                    },
                    activeThumbColor: const Color(0xFF3B48F6),
                    activeTrackColor: Colors.white.withValues(alpha: 0.2),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  // Notification bell with red badge
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Circular Shield avatar button
                  GestureDetector(
                    onTap: () => showProfileDropdown(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Metric Summary Cards Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.access_time_filled,
                  iconColor: const Color(0xFFFFB020), // Yellow clock icon
                  countText: '6', // Pending tasks e.g. 6
                  label: 'Pending Review',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF2E7D32), // Green checkmark icon
                  countText: '$activeGroups', // Total systems
                  label: 'Active Groups',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cancel,
                  iconColor: const Color(0xFFC62828), // Red X icon
                  countText: '0', // Exceptions tracking e.g. 0
                  label: 'Flagged Roles',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String countText,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                countText,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Search, filter UI controls bar
  Widget _buildSearchAndFilters(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      child: Column(
        children: [
          Row(
            children: [
              // Search Input Box
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.inter(
                        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Action Button
              GestureDetector(
                onTap: () => _selectDateRange(context),
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedDateRange != null
                          ? const Color(0xFF3B48F6)
                          : (themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
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
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: _selectedDateRange != null
                        ? const Color(0xFF3B48F6)
                        : (themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          // Active Date Range Filter Tag
          if (_selectedDateRange != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDCE4FF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Color(0xFF3B48F6)),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatDateCompact(_selectedDateRange!.start)} - ${_formatDateCompact(_selectedDateRange!.end)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3B48F6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDateRange = null;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Color(0xFF3B48F6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  // Individual Institutional Feed Card Builder
  Widget _buildOrganizationCard(BuildContext context, OrganizationItem item, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Top Component Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge wrapper around Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: const Color(0xFF3B48F6), // blue line-art category icon
                  size: 20,
                ),
              ),
              // Status Tag (ACTIVE)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // light green background
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15803D), // dark green text
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Middle Text Block
          Text(
            item.fullName,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.acronym,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3B48F6), // system blue font code
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Component Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Members Tally (Left Side)
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item.memberCount} Members',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textLight,
                    ),
                  ),
                ],
              ),
              // Action Button (Right Side)
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Navigating to manage ${item.acronym} portal...', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                        ],
                      ),
                      backgroundColor: const Color(0xFF3B48F6),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B48F6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Manage',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.domain_disabled,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Organizations Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try widening your search keywords.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

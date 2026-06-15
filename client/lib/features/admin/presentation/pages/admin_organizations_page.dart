import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/admin_notification_bell.dart';
import 'package:flutter_application_transparatech/core/network/http_client.dart';


class MockOfficer {
  final String role;
  final String name;
  final String contact;

  const MockOfficer({
    required this.role,
    required this.name,
    required this.contact,
  });
}

class MockDocument {
  final String title;
  final String date;
  final String status; // 'APPROVED' or 'REJECTED'

  const MockDocument({
    required this.title,
    required this.date,
    required this.status,
  });
}

class OrganizationItem {
  final String fullName;
  final String acronym;
  final int memberCount;
  String status;
  final IconData icon;
  final List<MockOfficer> officers;
  final List<MockDocument> documents;

  OrganizationItem({
    required this.fullName,
    required this.acronym,
    required this.memberCount,
    this.status = 'ACTIVE',
    required this.icon,
    required this.officers,
    required this.documents,
  });
}

class AdminOrganizationsScreen extends StatefulWidget {
  final String? initialSearchQuery;
  const AdminOrganizationsScreen({super.key, this.initialSearchQuery});

  @override
  State<AdminOrganizationsScreen> createState() => _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  List<OrganizationItem> _allOrganizations = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _searchController.text = widget.initialSearchQuery!;
    }
    _fetchOrganizations();
  }

  @override
  void didUpdateWidget(covariant AdminOrganizationsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSearchQuery != oldWidget.initialSearchQuery) {
      setState(() {
        _searchController.text = widget.initialSearchQuery ?? '';
      });
    }
  }

  Future<void> _fetchOrganizations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ApiClient();
      final response = await client.get('/api/admin/organizations');
      if (response.isSuccess) {
        final List<dynamic> data = response.data ?? [];
        setState(() {
          _allOrganizations = data.map((o) {
            IconData icon = Icons.business_outlined;
            final acronym = o['acronym'] ?? '';
            switch (acronym) {
              case 'ACES':
                icon = Icons.memory;
                break;
              case 'iSITE':
                icon = Icons.lan_outlined;
                break;
              case 'AFT':
                icon = Icons.book_outlined;
                break;
              case 'HMSOC':
                icon = Icons.room_service_outlined;
                break;
              case 'CEM':
                icon = Icons.business_center_outlined;
                break;
              case 'JPIA':
                icon = Icons.calculate_outlined;
                break;
              case 'DOMT':
                icon = Icons.folder_open_outlined;
                break;
            }


            final List<dynamic> officersData = o['officers'] ?? [];
            final List<dynamic> docsData = o['documents'] ?? [];

            return OrganizationItem(
              fullName: o['fullName'] ?? '',
              acronym: acronym,
              memberCount: o['memberCount'] ?? 0,
              status: o['status'] ?? 'ACTIVE',
              icon: icon,
              officers: officersData.map((off) => MockOfficer(
                role: off['role'] ?? 'Officer',
                name: off['name'] ?? '',
                contact: off['contact'] ?? '',
              )).toList(),
              documents: docsData.map((d) => MockDocument(
                title: d['title'] ?? '',
                date: d['date'] ?? '',
                status: d['status'] ?? 'PENDING',
              )).toList(),
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.data['error'] ?? 'Failed to fetch organizations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

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
                        officers: [
                          const MockOfficer(role: 'President', name: 'TBD', contact: 'N/A'),
                          const MockOfficer(role: 'VP', name: 'TBD', contact: 'N/A'),
                          const MockOfficer(role: 'Treasurer', name: 'TBD', contact: 'N/A'),
                        ],
                        documents: [],
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(color: Colors.red),
                        ),
                      )
                    : _filteredOrganizations.isEmpty
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
    final String fullName = (user != null && '${user.firstName} ${user.lastName}'.trim().isNotEmpty && '${user.firstName} ${user.lastName}' != 'admin admin')
        ? '${user.firstName} ${user.lastName}'
        : 'luis luis';

    final int activeCount = _allOrganizations.where((org) => org.status == 'ACTIVE').length;
    final int flaggedCount = _allOrganizations.where((org) => org.status == 'FLAGGED').length;

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
                  const AdminNotificationBell(),
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
                  iconColor: const Color(0xFFF59E0B), // Amber clock asset
                  iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  countText: '1,539', // Total Members
                  label: 'Total Members',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF10B981), // Green check asset
                  iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                  countText: '$activeCount', // Active Orgs
                  label: 'Active Orgs',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.cancel,
                  iconColor: const Color(0xFFEF4444), // Red cross asset
                  iconBgColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  countText: '$flaggedCount', // Flagged Groups
                  label: 'Flagged Groups',
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
    required Color iconBgColor,
    required String countText,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04), // share same dark blue accent container fill
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                countText,
                style: GoogleFonts.inter(
                  fontSize: 18,
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
              color: const Color(0xFFA5B4FC), // regular-weight muted blue-gray typography string
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

  void _showManageOverlay(BuildContext context, OrganizationItem item) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage ${item.acronym}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.fullName,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              color: const Color(0xFF9CA3AF),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1, color: Color(0xFFF3F4F6)),

                        // 1. Document History Logs Archive
                        Text(
                          'Document History Logs Archive',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (item.documents.isEmpty)
                          Text(
                            'No documents found.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF9CA3AF),
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          Column(
                            children: item.documents.map((doc) {
                              final isApp = doc.status == 'APPROVED';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF374151),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            doc.date,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isApp ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        doc.status,
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isApp ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 16),

                        // 2. Core Executive Officers Directory
                        Text(
                          'Core Executive Officers Directory',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: item.officers.map((off) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEDE7F6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Color(0xFF3B48F6),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          off.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF374151),
                                          ),
                                        ),
                                        Text(
                                          '${off.role} | ${off.contact}',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // 3. System Operations Override Switch
                        Text(
                          'System Operations Override Switch',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFD1D5DB), // light gray border
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: item.status,
                              isExpanded: true,
                              dropdownColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF374151),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'ACTIVE',
                                  child: Text('ACTIVE'),
                                ),
                                DropdownMenuItem(
                                  value: 'FLAGGED',
                                  child: Text('FLAGGED'),
                                ),
                              ],
                              onChanged: (String? newStatus) {
                                if (newStatus != null) {
                                  // Update status in the item
                                  setState(() {
                                    item.status = newStatus;
                                  });
                                  setDialogState(() {
                                    item.status = newStatus;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Individual Institutional Feed Card Builder
  Widget _buildOrganizationCard(BuildContext context, OrganizationItem item, ThemeProvider themeProvider) {
    final isFlagged = item.status == 'FLAGGED';
    final Color pillBg = isFlagged ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7);
    final Color pillText = isFlagged ? const Color(0xFFB91C1C) : const Color(0xFF15803D);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE7F6), // soft lavender circle container
                  shape: BoxShape.circle,
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
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: pillText,
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
              color: const Color(0xFF2563EB), // system brand blue (#2563EB)
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
                      color: const Color(0xFF9CA3AF), // muted gray font
                    ),
                  ),
                ],
              ),
              // Action Button (Right Side)
              ElevatedButton(
                onPressed: () => _showManageOverlay(context, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // solid system brand blue
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

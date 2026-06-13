import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';

class UserItem {
  String fullName;
  String email;
  String role; // 'Admin', 'Officers', or 'Student'
  String organization; // 'JPIA', 'iSITE', 'ACES', 'AFT', 'CEM', 'HMSOC'
  String lastLogin;
  bool isActive;

  UserItem({
    required this.fullName,
    required this.email,
    required this.role,
    required this.organization,
    this.lastLogin = 'Last login: April 23, 2025',
    this.isActive = true,
  });
}

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  // Initial set of 18 users (2 Admins, 4 Officers, 12 Students/Members)
  final List<UserItem> _allUsers = [
    UserItem(fullName: 'Princess Dianne Pastrana', email: 'princesspastrana@gmail.com', role: 'Officers', organization: 'JPIA'),
    UserItem(fullName: 'Ellayssa Aguilar', email: 'ellayssaaguilar@gmail.com', role: 'Officers', organization: 'iSITE'),
    UserItem(fullName: 'Bob Johnson', email: 'bobjohnson@gmail.com', role: 'Officers', organization: 'CEM'),
    UserItem(fullName: 'Emily Davis', email: 'emilydavis@gmail.com', role: 'Officers', organization: 'iSITE'),
    UserItem(fullName: 'John Doe', email: 'johndoe@gmail.com', role: 'Admin', organization: 'ACES'),
    UserItem(fullName: 'Alice Williams', email: 'alicewilliams@gmail.com', role: 'Admin', organization: 'HMSOC'),
    UserItem(fullName: 'Jane Smith', email: 'janesmith@gmail.com', role: 'Student', organization: 'AFT'),
    UserItem(fullName: 'Michael Brown', email: 'michaelbrown@gmail.com', role: 'Student', organization: 'JPIA'),
    UserItem(fullName: 'David Miller', email: 'davidmiller@gmail.com', role: 'Student', organization: 'ACES'),
    UserItem(fullName: 'Sarah Wilson', email: 'sarahwilson@gmail.com', role: 'Student', organization: 'AFT'),
    UserItem(fullName: 'James Taylor', email: 'jamestaylor@gmail.com', role: 'Student', organization: 'CEM'),
    UserItem(fullName: 'Jessica Thomas', email: 'jessicathomas@gmail.com', role: 'Student', organization: 'HMSOC'),
    UserItem(fullName: 'Robert Anderson', email: 'robertanderson@gmail.com', role: 'Student', organization: 'JPIA'),
    UserItem(fullName: 'Jennifer Jackson', email: 'jenniferjackson@gmail.com', role: 'Student', organization: 'iSITE'),
    UserItem(fullName: 'William White', email: 'williamwhite@gmail.com', role: 'Student', organization: 'ACES'),
    UserItem(fullName: 'Linda Harris', email: 'lindaharris@gmail.com', role: 'Student', organization: 'AFT'),
    UserItem(fullName: 'Richard Martin', email: 'richardmartin@gmail.com', role: 'Student', organization: 'CEM'),
    UserItem(fullName: 'Patricia Garcia', email: 'patriciagarcia@gmail.com', role: 'Student', organization: 'HMSOC'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reactive filtering using search text
  List<UserItem> get _filteredUsers {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      return _allUsers;
    }
    return _allUsers.where((u) {
      return u.fullName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
    }).toList();
  }

  // Header metric counters (dynamic calculations)
  int get _totalUsersCount => _allUsers.length;
  int get _activeUsersCount => _allUsers.where((u) => u.isActive).length;
  int get _officersCount => _allUsers.where((u) => u.role == 'Officers').length;
  int get _adminCount => _allUsers.where((u) => u.role == 'Admin').length;

  // Calendar modal for filtering date range
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
              primary: Color(0xFF3B48F6), // Selected highlight blue
              onPrimary: Colors.white,
              surface: Colors.white, // Modal background
              onSurface: Color(0xFF1F2937), // Inactive dates high-contrast dark grey
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

  // Main custom Modal for Adding or Editing user data
  void _showUserFormModal(BuildContext context, {UserItem? existingUser, int? editIndex}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existingUser?.fullName ?? '');
    final emailController = TextEditingController(text: existingUser?.email ?? '');
    String selectedRole = existingUser?.role == 'Student' ? 'Officers' : (existingUser?.role ?? 'Officers');
    String selectedOrg = existingUser?.organization ?? 'JPIA';

    final isEdit = existingUser != null;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Center(
              child: SingleChildScrollView(
                child: AlertDialog(
                  backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.all(24),
                  titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit User' : '+ Add User',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(
                          Icons.close,
                          color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF9CA3AF),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: 320,
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Input
                          Text(
                            'Full Name',
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
                              hintText: 'e.g. Juan Dela Cruz Santos',
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

                          // Email Input
                          Text(
                            'Email Address',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. princessdianne@gmail.com',
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

                          // Two-column dropdown layout
                          Row(
                            children: [
                              // Left Column: Roles
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Roles',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedRole,
                                          isExpanded: true,
                                          dropdownColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                                          ),
                                          items: <String>['Admin', 'Officers'].map((String val) {
                                            return DropdownMenuItem<String>(
                                              value: val,
                                              child: Text(val),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            if (newValue != null) {
                                              setDialogState(() {
                                                selectedRole = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Right Column: Organization
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Organization',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedOrg,
                                          isExpanded: true,
                                          dropdownColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                                          ),
                                          items: <String>['JPIA', 'iSITE', 'ACES', 'AFT', 'CEM', 'HMSOC'].map((String val) {
                                            return DropdownMenuItem<String>(
                                              value: val,
                                              child: Text(val),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            if (newValue != null) {
                                              setDialogState(() {
                                                selectedOrg = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Bottom buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textGrey,
                                    side: BorderSide(color: themeProvider.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      final String newName = nameController.text.trim();
                                      final String newEmail = emailController.text.trim();

                                      setState(() {
                                        if (isEdit) {
                                          _allUsers[editIndex!] = UserItem(
                                            fullName: newName,
                                            email: newEmail,
                                            role: selectedRole,
                                            organization: selectedOrg,
                                            lastLogin: existingUser.lastLogin,
                                            isActive: existingUser.isActive,
                                          );
                                        } else {
                                          _allUsers.add(
                                            UserItem(
                                              fullName: newName,
                                              email: newEmail,
                                              role: selectedRole,
                                              organization: selectedOrg,
                                            ),
                                          );
                                        }
                                      });

                                      Navigator.pop(dialogContext);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.white),
                                              const SizedBox(width: 8),
                                              Text(
                                                isEdit ? 'Updated $newName successfully!' : 'Added $newName successfully!',
                                                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                                              ),
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
                                    backgroundColor: const Color(0xFFEEF2FF), // Soft blue fill
                                    foregroundColor: const Color(0xFF3B48F6), // Solid blue text
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    isEdit ? 'Edit changes' : 'Add user',
                                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // Delete User confirmation dialog overlay
  void _showDeleteUserDialog(BuildContext context, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final targetUser = _allUsers[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          content: Text(
            'Do you want to delete profile record for ${targetUser.fullName}?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: themeProvider.isDarkMode ? Colors.grey.shade300 : VeriFiColors.textGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                final deletedName = targetUser.fullName;
                setState(() {
                  _allUsers.removeAt(index);
                });
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('$deletedName deleted successfully.', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    backgroundColor: VeriFiColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VeriFiColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'Confirm',
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
    final totalCount = _filteredUsers.length;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 1. Header banner layout (Top View)
          _buildHeader(context, themeProvider),

          // 2. Control bar (Mid View)
          _buildSearchAndFilters(context, themeProvider),

          // Section Header & Action Trigger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Users ($totalCount)',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUserFormModal(context),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: Text(
                    'Add users',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B48F6), // Vibrant system blue
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          // 3. User Feed List (Scroll Area)
          Expanded(
            child: _filteredUsers.isEmpty
                ? _buildEmptyState(themeProvider)
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 24),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _filteredUsers[index];
                      // Find real index in complete list for modifications
                      final realIndex = _allUsers.indexOf(item);
                      return _buildUserCard(context, item, realIndex, themeProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Top banner with navy background
  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'admin admin';

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F2547), // Deep navy blue
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
              // Controls (Right)
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
                  // Avatar trigger
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
          // Metric Summary Cards Row (4 cards)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF93C5FD), // Light blue person icon
                  countText: '$_totalUsersCount',
                  label: 'Total Users',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.person,
                  iconColor: const Color(0xFF86EFAC), // Light green active person icon
                  countText: '$_activeUsersCount',
                  label: 'Active Users',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFFFDE047), // Light yellow shield icon
                  countText: '$_officersCount',
                  label: 'Officers',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard(
                  icon: Icons.group_outlined,
                  iconColor: const Color(0xFFD8B4FE), // Light purple group icon
                  countText: '$_adminCount',
                  label: 'Admin',
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(
                countText,
                style: GoogleFonts.inter(
                  fontSize: 15,
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
              fontSize: 9,
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

  // Search filter tools
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
          // Selected Date Tag
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

  // Individual User card listing
  Widget _buildUserCard(BuildContext context, UserItem item, int realIndex, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Element Column
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF0F2547) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF3B48F6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Middle Information Stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fullName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                // Metadata Row: Role Badge & Last Login
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildRoleBadge(item.role),
                    Text(
                      item.lastLogin,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode ? Colors.grey.shade500 : VeriFiColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Management Action Icons
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showUserFormModal(context, existingUser: item, editIndex: realIndex),
                    child: Icon(
                      Icons.edit_note_outlined,
                      size: 20,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showDeleteUserDialog(context, realIndex),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    if (role == 'Officers') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9), // Mint green
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Officer',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2E7D32),
          ),
        ),
      );
    } else if (role == 'Admin') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E5F5), // Pastel purple
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Admin',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7B1FA2),
          ),
        ),
      );
    }
    // Default student/member role (render nothing or simple badge)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Gray
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Student',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : VeriFiColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search criteria.',
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

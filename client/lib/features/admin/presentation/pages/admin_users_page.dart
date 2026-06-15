import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/profile_dropdown.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/providers/admin_queue_provider.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/widgets/admin_notification_bell.dart';

class AdminUsersScreen extends StatefulWidget {
  final String? initialRoleFilter;
  const AdminUsersScreen({super.key, this.initialRoleFilter});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _selectedRoleFilter = widget.initialRoleFilter;
  }

  @override
  void didUpdateWidget(covariant AdminUsersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoleFilter != oldWidget.initialRoleFilter) {
      setState(() {
        _selectedRoleFilter = widget.initialRoleFilter;
      });
    }
  }

  List<UserItem> get _allUsers => Provider.of<AdminQueueProvider>(context, listen: false).rawUsers;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Reactive filtering using search text & role filter
  List<UserItem> get _filteredUsers {
    final query = _searchController.text.toLowerCase().trim();
    var list = Provider.of<AdminQueueProvider>(context).activeUsers;

    // 1. Role Filter
    if (_selectedRoleFilter != null) {
      final String roleTarget = _selectedRoleFilter == 'Students'
          ? 'Student'
          : (_selectedRoleFilter == 'Admins' ? 'Admin' : 'Officers');
      list = list.where((u) => u.role == roleTarget).toList();
    }

    // 2. Search query filter
    if (query.isNotEmpty) {
      list = list.where((u) {
        return u.fullName.toLowerCase().contains(query) ||
            u.email.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  // Header metric counters (dynamic calculations)
  int get _totalUsersCount => _allUsers.length;
  int get _activeUsersCount => _allUsers.where((u) => u.isActive).length;
  int get _officersCount => _allUsers.where((u) => u.role == 'Officers').length;
  int get _adminCount => _allUsers.where((u) => u.role == 'Admin').length;



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

                                      final queueProvider = Provider.of<AdminQueueProvider>(context, listen: false);
                                      if (isEdit) {
                                        queueProvider.updateUser(editIndex!, UserItem(
                                          fullName: newName,
                                          email: newEmail,
                                          role: selectedRole,
                                          organization: selectedOrg,
                                          lastLogin: existingUser.lastLogin,
                                          isActive: existingUser.isActive,
                                          systemFlag: existingUser.systemFlag,
                                        ));
                                      } else {
                                        queueProvider.addUser(UserItem(
                                          fullName: newName,
                                          email: newEmail,
                                          role: selectedRole,
                                          organization: selectedOrg,
                                        ));
                                      }

                                      Navigator.pop(dialogContext);

                                      showAlertDialog(
                                        context: context,
                                        title: isEdit ? 'User Updated' : 'User Added',
                                        message: isEdit ? 'Updated $newName successfully!' : 'Added $newName successfully!',
                                        isSuccess: true,
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

  // Archive User confirmation dialog overlay
  void _showArchiveUserDialog(BuildContext context, UserItem targetUser, int realIndex) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final queueProvider = Provider.of<AdminQueueProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Header
                Text(
                  'Confirm Archive',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                // Body Explainer Label
                Text(
                  'Are you sure you want to archive the profile record for ${targetUser.fullName}? This user will lose active system access rights, and their dossier record data will be safely migrated to the administration audit logs archive folder.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: themeProvider.isDarkMode ? Colors.grey.shade300 : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 24),
                // Footer Action Buttons (Right-Aligned Array)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Link Trigger (Cancel)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right Action Button (Confirm)
                    ElevatedButton(
                      onPressed: () {
                        // Dismiss modal
                        Navigator.pop(context);

                        // Execute archive workflow
                        queueProvider.archiveUser(targetUser);

                        // SnackBar
                        showAlertDialog(
                          context: context,
                          title: 'User Archived',
                          message: '${targetUser.fullName} archived successfully.',
                          isError: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Confirm',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    final String fullName = (user != null && '${user.firstName} ${user.lastName}'.trim().isNotEmpty && '${user.firstName} ${user.lastName}' != 'admin admin')
        ? '${user.firstName} ${user.lastName}'
        : 'luis luis';

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
                  const AdminNotificationBell(),
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
                  icon: Icons.circle,
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
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
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
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
              color: const Color(0xFFA5B4FC),
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

  // Search filter tools with role selector dropdown popup
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
              // Role Filter PopupMenuButton
              PopupMenuButton<String>(
                offset: const Offset(0, 52),
                elevation: 4,
                color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (String val) {
                  setState(() {
                    if (val == 'Clear') {
                      _selectedRoleFilter = null;
                    } else {
                      _selectedRoleFilter = val;
                    }
                  });
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'Students',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedRoleFilter == 'Students'
                              ? (themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Students',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: _selectedRoleFilter == 'Students' ? FontWeight.bold : FontWeight.w500,
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Officers',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedRoleFilter == 'Officers'
                              ? (themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Officers',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: _selectedRoleFilter == 'Officers' ? FontWeight.bold : FontWeight.w500,
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Admins',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedRoleFilter == 'Admins'
                              ? (themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Admins',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: _selectedRoleFilter == 'Admins' ? FontWeight.bold : FontWeight.w500,
                            color: themeProvider.isDarkMode ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedRoleFilter != null)
                      PopupMenuItem<String>(
                        value: 'Clear',
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Clear Filter',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                  ];
                },
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedRoleFilter != null
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
                    color: _selectedRoleFilter != null
                        ? const Color(0xFF3B48F6)
                        : (themeProvider.isDarkMode ? Colors.grey.shade400 : VeriFiColors.textGrey),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
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
                    onTap: () => _showArchiveUserDialog(context, item, realIndex),
                    child: Icon(
                      Icons.archive_outlined,
                      size: 20,
                      color: themeProvider.isDarkMode ? Colors.grey.shade400 : const Color(0xFF4B5563),
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

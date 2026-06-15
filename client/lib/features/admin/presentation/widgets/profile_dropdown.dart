import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_application_transparatech/features/auth/presentation/pages/auth_page.dart' as auth;
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:flutter_application_transparatech/features/admin/presentation/pages/admin_account_settings_page.dart';

/// Triggers a clean, white-rounded dropdown dialog window overlay.
/// Contains the active Admin user details, and 3 functional menu options.
void showProfileDropdown(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final user = authProvider.currentUser;
  final String fullName = user != null ? '${user.firstName} ${user.lastName}' : 'admin admin';
  final String email = user?.email ?? 'admin@pup.edu.ph';

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.15), // light dimming
    builder: (BuildContext context) {
      return Dialog(
        alignment: Alignment.topRight,
        insetPadding: const EdgeInsets.only(top: 60, right: 20), // positions it near the avatar
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Details Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF0F2547),
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: VeriFiColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: VeriFiColors.textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE5E7EB)),
              
              // Menu Option 1: Account Settings
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF4B5563), size: 18),
                title: Text(
                  'Account Settings',
                  style: GoogleFonts.inter(
                    fontSize: 13, 
                    color: VeriFiColors.textDark, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminAccountSettingsScreen()),
                  );
                },
              ),
              
              // Menu Option 2: Admin Settings
              ListTile(
                leading: const Icon(Icons.security, color: Color(0xFF4B5563), size: 18),
                title: Text(
                  'Admin Settings',
                  style: GoogleFonts.inter(
                    fontSize: 13, 
                    color: VeriFiColors.textDark, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminSettingsScreen()),
                  );
                },
              ),
              
              const Divider(color: Color(0xFFE5E7EB)),
              
              // Menu Option 3: Log Out
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                title: Text(
                  'Log Out',
                  style: GoogleFonts.inter(
                    fontSize: 13, 
                    color: Colors.redAccent, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
                onTap: () {
                  Navigator.pop(context);
                  // Sign out logic
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                  // Re-route to login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const auth.AuthPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

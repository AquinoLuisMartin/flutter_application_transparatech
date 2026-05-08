import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _themeMode = 'System'; // Light, Dark, System

  void _showAppearanceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRadioOption('Light', Icons.light_mode_outlined, setModalState),
                  _buildRadioOption('Dark', Icons.dark_mode_outlined, setModalState),
                  _buildRadioOption('System', Icons.settings_system_daydream_outlined, setModalState),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildRadioOption(String value, IconData icon, StateSetter setModalState) {
    return InkWell(
      onTap: () {
        setModalState(() {
          _themeMode = value;
        });
        setState(() {
          _themeMode = value;
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) Navigator.pop(context);
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (_themeMode == value)
              const Icon(Icons.check_circle, color: Color(0xFF3B48F6), size: 22)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade300, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account settings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildSettingRow(
              icon: Icons.person_outline,
              title: 'Personal information',
              onTap: () {},
            ),
            Divider(color: Colors.grey.shade100, height: 1, indent: 64),
            _buildSettingRow(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              trailingText: _themeMode,
              onTap: _showAppearanceBottomSheet,
            ),
            Divider(color: Colors.grey.shade100, height: 1, indent: 64),
            _buildSettingRow(
              icon: Icons.translate,
              title: 'Translation',
              onTap: () {},
            ),
            Divider(color: Colors.grey.shade100, height: 1, indent: 64),
            _buildSettingRow(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {},
            ),
            Divider(color: Colors.grey.shade100, height: 1, indent: 64),
            _buildSettingRow(
              icon: Icons.lock_outline,
              title: 'Privacy and sharing',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

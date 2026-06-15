import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showAppearanceBottomSheet(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final activeMode = themeProvider.themeMode;
            
            Widget buildModalRow({
              required String label,
              required ThemeMode mode,
              required Widget customIcon,
            }) {
              final isSelected = activeMode == mode;
              return InkWell(
                onTap: () {
                  themeProvider.setThemeMode(mode);
                  setModalState(() {});
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
                  child: Row(
                    children: [
                      customIcon,
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 13,
                          ),
                        )
                      else
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              width: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Thin subtle top indicator line bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Appearance',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F2547),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Option rows
                  buildModalRow(
                    label: 'Light',
                    mode: ThemeMode.light,
                    customIcon: const Icon(Icons.wb_sunny_outlined, color: Color(0xFF4B5563), size: 22),
                  ),
                  Divider(color: Colors.grey.shade100, height: 1, indent: 24),
                  buildModalRow(
                    label: 'Dark',
                    mode: ThemeMode.dark,
                    customIcon: const Icon(Icons.nightlight_round_outlined, color: Color(0xFF4B5563), size: 22),
                  ),
                  Divider(color: Colors.grey.shade100, height: 1, indent: 24),
                  buildModalRow(
                    label: 'System',
                    mode: ThemeMode.system,
                    customIcon: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.desktop_windows_outlined,
                          color: Color(0xFF4B5563),
                          size: 22,
                        ),
                        Positioned(
                          top: 4,
                          child: const Icon(
                            Icons.cloud,
                            color: Color(0xFF4B5563),
                            size: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Interior bottom padding track
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    String? trailingText,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152238) : Colors.transparent,
        border: isDark
            ? Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              )
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  ),
                ),
              if (trailingText != null) const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B192C) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B192C) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account settings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSettingRow(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              trailingText: _getThemeLabel(themeProvider.themeMode),
              onTap: () {
                _showAppearanceBottomSheet(context, themeProvider);
              },
              isDark: isDark,
            ),
            if (!isDark) Divider(color: Colors.grey.shade100, height: 1, indent: 64),
            _buildSettingRow(
              icon: Icons.translate,
              title: 'Translation',
              onTap: () {},
              isDark: isDark,
            ),
            if (!isDark) Divider(color: Colors.grey.shade100, height: 1, indent: 64),
            _buildSettingRow(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {},
              isDark: isDark,
            ),
            if (!isDark) Divider(color: Colors.grey.shade100, height: 1, indent: 64),
            _buildSettingRow(
              icon: Icons.lock_outline,
              title: 'Privacy and sharing',
              onTap: () {},
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

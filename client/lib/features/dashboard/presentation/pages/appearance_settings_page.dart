import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';

class AppearanceSettingsPage extends StatelessWidget {
  const AppearanceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Color activeColor = const Color(0xFF3B48F6); // System blue active token color
    final Color textDark = const Color(0xFF1F2937);

    Widget buildSelectionRow({
      required String label,
      required IconData icon,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
          child: Row(
            children: [
              // Left interactive radio circle indicator button
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? activeColor : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: isSelected
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Option Icon
              Icon(icon, color: Colors.grey.shade700, size: 22),
              const SizedBox(width: 16),
              
              // Option Label
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
          'Appearance',
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
            buildSelectionRow(
              label: 'Light',
              icon: Icons.light_mode_outlined,
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
              },
            ),
            Divider(color: Colors.grey.shade100, height: 1, indent: 24),
            buildSelectionRow(
              label: 'Dark',
              icon: Icons.dark_mode_outlined,
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
              },
            ),
            Divider(color: Colors.grey.shade100, height: 1, indent: 24),
            buildSelectionRow(
              label: 'System',
              icon: Icons.settings_system_daydream_outlined,
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
              },
            ),
          ],
        ),
      ),
    );
  }
}

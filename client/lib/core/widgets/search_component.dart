import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';

/// A premium, reusable search component for the VeriFi Design System.
/// Features a search text input, optional filter button, and optional sort dropdown.
class VeriFiSearchComponent extends StatelessWidget {
  /// Controller for the search text field
  final TextEditingController? controller;
  
  /// Callback when search query changes
  final ValueChanged<String>? onChanged;
  
  /// Callback when filter button is pressed. If null, filter button is hidden.
  final VoidCallback? onFilterPressed;

  /// Callback when filter button is pressed, providing the local BuildContext
  final void Function(BuildContext)? onFilterPressedWithContext;

  /// Whether any filters are currently active (signals active filters with a soft blue tint)
  final bool isFilterActive;
  
  /// Hint placeholder text
  final String hintText;
  
  /// List of sorting options. If null or empty, sort button is hidden.
  final List<String>? sortOptions;
  
  /// Currently selected sort option
  final String? selectedSortOption;
  
  /// Callback when a sort option is selected
  final ValueChanged<String>? onSortChanged;

  /// Constructor for VeriFiSearchComponent
  const VeriFiSearchComponent({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterPressed,
    this.onFilterPressedWithContext,
    this.isFilterActive = false,
    this.hintText = 'Search',
    this.sortOptions,
    this.selectedSortOption,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Row(
      children: [
        // Search text input field
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(VeriFiBorderRadius.inputs),
              border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.inter(
                  color: isDark ? Colors.grey.shade500 : VeriFiColors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade400 : VeriFiColors.textLight, size: 20),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white : VeriFiColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        // Filter Button
        if (onFilterPressed != null || onFilterPressedWithContext != null) ...[
          const SizedBox(width: 12),
          Builder(
            builder: (filterContext) {
              return GestureDetector(
                onTap: () {
                  if (onFilterPressedWithContext != null) {
                    onFilterPressedWithContext!(filterContext);
                  } else if (onFilterPressed != null) {
                    onFilterPressed!();
                  }
                },
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? (isFilterActive ? const Color(0xFF0F2547) : const Color(0xFF1E1E1E))
                        : (isFilterActive ? const Color(0xFFEFF6FF) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? (isFilterActive ? const Color(0xFF3B82F6).withValues(alpha: 0.5) : const Color(0xFF2A2A2A))
                          : (isFilterActive ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : const Color(0xFFE5E7EB)),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: isDark
                        ? (isFilterActive ? const Color(0xFF60A5FA) : Colors.grey.shade400)
                        : (isFilterActive ? const Color(0xFF2563EB) : VeriFiColors.textGrey),
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],

        // Sort Button and Dropdown Menu
        if (sortOptions != null && sortOptions!.isNotEmpty) ...[
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(Icons.sort, color: isDark ? Colors.grey.shade400 : VeriFiColors.textGrey, size: 20),
            ),
            padding: EdgeInsets.zero,
            onSelected: onSortChanged,
            itemBuilder: (BuildContext context) {
              return sortOptions!.map((String option) {
                final bool isSelected = option == selectedSortOption;
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? VeriFiColors.primary : (isDark ? Colors.white : VeriFiColors.textDark),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: VeriFiColors.primary, size: 16),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ],
    );
  }
}

/// Reusable Widgets
/// 
/// Common widgets that are used across multiple features
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_transparatech/core/theme/verifi_theme.dart';
import '../constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_transparatech/core/providers/theme_provider.dart';

/// Custom app bar widget
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title
  final String title;

  /// Whether to show back button
  final bool showBackButton;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Additional actions for app bar
  final List<Widget>? actions;

  /// Constructor for AppBarWidget
  const AppBarWidget({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom loading widget
class LoadingWidget extends StatelessWidget {
  /// Optional loading message
  final String? message;

  /// Constructor for LoadingWidget
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom error widget
class ErrorWidget extends StatelessWidget {
  /// Error message to display
  final String message;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Custom label for retry button
  final String? retryLabel;

  /// Constructor for ErrorWidget
  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppDimensions.iconSizeLarge,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppDimensions.paddingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel ?? 'Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom empty state widget
class EmptyStateWidget extends StatelessWidget {
  /// Title text
  final String title;

  /// Optional description text
  final String? description;

  /// Icon to display
  final IconData icon;

  /// Action button callback
  final VoidCallback? onActionPressed;

  /// Action button label
  final String? actionLabel;

  /// Constructor for EmptyStateWidget
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          if (onActionPressed != null) ...[
            const SizedBox(height: AppDimensions.paddingLarge),
            ElevatedButton(
              onPressed: onActionPressed,
              child: Text(actionLabel ?? 'Action'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom primary button widget
class PrimaryButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button is enabled
  final bool isEnabled;

  /// Custom button width
  final double? width;

  /// Button height
  final double height;

  /// Optional icon to display
  final IconData? icon;

  /// Constructor for PrimaryButton
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 56.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = isEnabled && !isLoading && onPressed != null;
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: active ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: VeriFiColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: VeriFiColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VeriFiBorderRadius.buttons),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: VeriFiSpacing.s24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: VeriFiSpacing.s8),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Custom secondary button widget
class SecondaryButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button is enabled
  final bool isEnabled;

  /// Custom button width
  final double? width;

  /// Button height
  final double height;

  /// Optional icon to display
  final IconData? icon;

  /// Constructor for SecondaryButton
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 56.0,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = isEnabled && !isLoading && onPressed != null;
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: active ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF2563EB),
          disabledForegroundColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
          side: BorderSide(
            color: active ? const Color(0xFF60A5FA) : const Color(0xFF93C5FD).withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(VeriFiBorderRadius.buttons),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: VeriFiSpacing.s24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: VeriFiSpacing.s8),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Reusable VeriFi Card component
class VeriFiCard extends StatelessWidget {
  /// Icon displayed on the left side of the card
  final Widget icon;

  /// Title of the card
  final String title;

  /// Description / subtitle text of the card
  final String description;

  /// Optional status widget (e.g. badge or indicator)
  final Widget? status;

  /// Optional action widget (e.g. trailing chevron or button)
  final Widget? action;

  /// Optional click listener
  final VoidCallback? onTap;

  /// Constructor for VeriFiCard
  const VeriFiCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.status,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: VeriFiSpacing.s16),
        padding: const EdgeInsets.all(VeriFiSpacing.s16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : VeriFiColors.surface,
          borderRadius: BorderRadius.circular(VeriFiBorderRadius.cards),
          border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEEF2FF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(VeriFiSpacing.s8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : VeriFiColors.secondaryEE,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: isDark ? Colors.blue.shade300 : VeriFiColors.primary,
                  size: 24,
                ),
                child: icon,
              ),
            ),
            const SizedBox(width: VeriFiSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : VeriFiColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.grey.shade400 : VeriFiColors.textGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (status != null) ...[
                    const SizedBox(height: VeriFiSpacing.s8),
                    status!,
                  ],
                ],
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: VeriFiSpacing.s8),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom divider with text widget
class DividerWithText extends StatelessWidget {
  /// Text to display in center
  final String text;

  /// Padding around divider
  final EdgeInsets padding;

  /// Constructor for DividerWithText
  const DividerWithText({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.symmetric(
      vertical: AppDimensions.paddingMedium,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).dividerColor)),
        ],
      ),
    );
  }
}

/// Standard system-wide confirmation dialog for operations requiring permission or approval
void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : VeriFiColors.textDark,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.grey.shade300 : VeriFiColors.textGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              cancelText,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : VeriFiColors.textLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? VeriFiColors.error : VeriFiColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              confirmText,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

/// Standard system-wide alert dialog for displaying messages, errors, or success confirmations
void showAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  VoidCallback? onPressed,
  String buttonText = 'OK',
  bool isError = false,
  bool isSuccess = false,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      IconData iconData = Icons.info_outline;
      Color iconColor = VeriFiColors.primary;
      if (isError) {
        iconData = Icons.error_outline_rounded;
        iconColor = VeriFiColors.error;
      } else if (isSuccess) {
        iconData = Icons.check_circle_outline_rounded;
        iconColor = VeriFiColors.success;
      }

      return AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: VeriFiBorderRadius.modalsRadius,
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(VeriFiSpacing.s16),
              decoration: BoxDecoration(
                color: isError
                    ? VeriFiColors.error.withValues(alpha: 0.1)
                    : (isSuccess
                        ? VeriFiColors.success.withValues(alpha: 0.1)
                        : VeriFiColors.primary.withValues(alpha: 0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 36,
              ),
            ),
            const SizedBox(height: VeriFiSpacing.s16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : VeriFiColors.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.grey.shade300 : VeriFiColors.textGrey,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          PrimaryButton(
            label: buttonText,
            width: double.infinity,
            height: 48,
            onPressed: () {
              Navigator.pop(context);
              if (onPressed != null) {
                onPressed();
              }
            },
          ),
        ],
      );
    },
  );
}


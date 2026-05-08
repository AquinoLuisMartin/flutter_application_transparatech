/// Reusable Widgets
/// 
/// Common widgets that are used across multiple features
library;

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

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
  final VoidCallback onPressed;

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
    this.width,
    this.height = AppDimensions.buttonHeightMedium,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : icon != null
                ? Icon(icon)
                : null,
        label: Text(label),
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

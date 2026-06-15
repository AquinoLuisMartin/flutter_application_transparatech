/// Utility Extension Functions
/// 
/// Common extension methods for improved readability and reusability
library;

import 'package:flutter/material.dart';
import 'package:flutter_application_transparatech/core/widgets/widgets.dart';

/// String extensions
extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isEmpty => this.isEmpty;

  bool get isNotEmpty => this.isNotEmpty;

  /// Capitalize first letter
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';

  /// Check if string is numeric
  bool get isNumeric => num.tryParse(this) != null;

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(this);
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

/// BuildContext extensions
extension BuildContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get device padding (notch, safe area)
  EdgeInsets get devicePadding => MediaQuery.of(this).padding;

  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  /// Check if device is in landscape
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Check if device is in portrait
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  /// Get app theme
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Show snackbar (Refactored to show standard popup modal for consistency)
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showAlertDialog(
      context: this,
      title: 'Alert',
      message: message,
    );
  }

  /// Show dialog
  Future<T?> showAppDialog<T>(
    Widget content, {
    String? title,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: this,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: content,
        actions: actions,
      ),
    );
  }
}

/// Duration extensions
extension DurationExtensions on Duration {
  /// Convert duration to user-readable format
  String toReadableString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes m';
    } else if (minutes > 0) {
      return '$minutes m $seconds s';
    } else {
      return '$seconds s';
    }
  }
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Get readable date format
  String toReadableString() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${monthNames[month - 1]} $day, $year';
  }
}

/// int extensions
extension IntExtensions on int {
  /// Format large numbers with K, M, B suffixes
  String toFormattedString() {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

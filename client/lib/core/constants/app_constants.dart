/// Application Constants
/// 
/// Centralized location for all application-level constants
library;

/// Application configuration constants
class AppConstants {
  /// API Configuration
  /// Base URL for API requests
  static const String apiBaseUrl = 'http://localhost:3000/api';

  /// API timeout in seconds
  static const int apiTimeoutSeconds = 30;

  /// App Metadata
  /// Application name
  static const String appName = 'Verifi';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Application description
  static const String appDescription =
      'Digital Financial Document Verification';

  /// Feature Flags
  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// Enable analytics
  static const bool enableAnalytics = false;

  /// Storage Keys
  /// Authentication token storage key
  static const String authTokenKey = 'auth_token';

  /// User data storage key
  static const String userDataKey = 'user_data';

  /// App preferences storage key
  static const String appPreferencesKey = 'app_preferences';
}

/// Application string constants
class AppStrings {
  /// Common
  /// Application name
  static const String appName = 'Verifi';

  /// Loading message
  static const String loading = 'Loading...';

  /// Error message
  static const String error = 'An error occurred';

  /// Retry button text
  static const String retry = 'Retry';

  /// Cancel button text
  static const String cancel = 'Cancel';

  /// OK button text
  static const String ok = 'OK';
  
  /// Landing Page
  /// Landing page title
  static const String landingTitle = 'Verifi';

  /// Landing page subtitle
  static const String landingSubtitle =
      'Digital Financial Document Verification';

  /// Landing page description
  static const String landingDescription =
      'Enhance financial transparency and accountability through '
      'secure digital document submission and verification.';

  /// Get started button text
  static const String getStarted = 'Get Started';

  /// Learn more button text
  static const String learnMore = 'Learn More';
}

/// Application dimension constants
class AppDimensions {
  /// Padding & Margins
  /// Small padding value
  static const double paddingSmall = 8.0;

  /// Medium padding value
  static const double paddingMedium = 16.0;

  /// Large padding value
  static const double paddingLarge = 24.0;

  /// Extra large padding value
  static const double paddingExtraLarge = 32.0;

  /// Border Radius
  /// Small border radius
  static const double borderRadiusSmall = 4.0;

  /// Medium border radius
  static const double borderRadiusMedium = 8.0;

  /// Large border radius
  static const double borderRadiusLarge = 16.0;

  /// Icon Sizes
  /// Small icon size
  static const double iconSizeSmall = 16.0;

  /// Medium icon size
  static const double iconSizeMedium = 24.0;

  /// Large icon size
  static const double iconSizeLarge = 32.0;

  /// Button Sizes
  /// Small button height
  static const double buttonHeightSmall = 36.0;

  /// Medium button height
  static const double buttonHeightMedium = 48.0;

  /// Large button height
  static const double buttonHeightLarge = 56.0;
}

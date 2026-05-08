/// Build Configuration
/// 
/// Configuration constants for different build environments
library;

/// Build environment enum
enum BuildEnvironment {
  /// Development environment
  development,
  /// Staging environment
  staging,
  /// Production environment
  production,
}

/// Build configuration class
class BuildConfig {
  /// Current build environment
  static const BuildEnvironment environment = BuildEnvironment.development;
  
  /// API base URLs for each environment
  static const Map<BuildEnvironment, String> apiBaseUrls = {
    BuildEnvironment.development: 'http://localhost:3000/api',
    BuildEnvironment.staging: 'https://staging-api.verifi.app/api',
    BuildEnvironment.production: 'https://api.verifi.app/api',
  };
  
  /// Analytics configuration per environment
  static const Map<BuildEnvironment, bool> enableAnalytics = {
    BuildEnvironment.development: false,
    BuildEnvironment.staging: true,
    BuildEnvironment.production: true,
  };
  
  /// Logging configuration per environment
  static const Map<BuildEnvironment, bool> enableLogging = {
    BuildEnvironment.development: true,
    BuildEnvironment.staging: true,
    BuildEnvironment.production: false,
  };
  
  /// Get current API URL
  static String get currentApiUrl =>
      apiBaseUrls[environment] ?? 'http://localhost:3000/api';

  /// Check if analytics should be enabled
  static bool get shouldEnableAnalytics =>
      enableAnalytics[environment] ?? false;

  /// Check if logging should be enabled
  static bool get shouldEnableLogging => enableLogging[environment] ?? true;
}

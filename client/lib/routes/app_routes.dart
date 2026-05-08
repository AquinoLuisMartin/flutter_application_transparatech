/// Application Routes
/// 
/// Centralized route definitions for the application
library;

/// Application route constants
class AppRoutes {
  /// Landing page - entry point
  static const String landing = '/';

  /// Authentication routes
  /// Login page route
  static const String login = '/login';

  /// Signup page route
  static const String signup = '/signup';

  /// Password reset page route
  static const String forgotPassword = '/forgot-password';

  /// Dashboard routes
  /// Dashboard page route
  static const String dashboard = '/dashboard';

  /// User profile route
  static const String profile = '/profile';

  /// Document routes
  /// Documents list route
  static const String documentList = '/documents';

  /// Document detail route
  static const String documentDetail = '/documents/:id';

  /// Document submission route
  static const String documentSubmission = '/submit-document';

  /// Document analysis route
  static const String documentAnalysis = '/analyze-document';

  /// Verification routes
  /// Verification list route
  static const String verification = '/verification';

  /// Verification detail route
  static const String verificationDetail = '/verification/:id';

  /// Settings routes
  /// Settings page route
  static const String settings = '/settings';

  /// About page route
  static const String about = '/about';

  /// Build full path with document ID parameter
  static String getDocumentDetail(String id) => '/documents/$id';

  /// Build full path with verification ID parameter
  static String getVerificationDetail(String id) => '/verification/$id';
}

// TODO: Implement GoRouter or named routes navigation when routing package is added
// Example with GoRouter:
// final router = GoRouter(
//   routes: [
//     GoRoute(path: AppRoutes.landing, builder: ...),
//     GoRoute(path: AppRoutes.login, builder: ...),
//     // ... more routes
//   ],
// );

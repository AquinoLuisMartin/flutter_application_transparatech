/// Error Handling Exceptions
/// 
/// Custom exceptions for the application
library;

abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  /// Constructor for NetworkException
  NetworkException({
    required super.message,
    super.code,
  });
}

/// API call exception with status code
class ApiException extends AppException {
  /// HTTP status code from the API
  final int? statusCode;

  /// Constructor for ApiException
  ApiException({
    required super.message,
    super.code,
    this.statusCode,
  });
}

/// Connection timeout exception
class ConnectionTimeoutException extends NetworkException {
  /// Constructor for ConnectionTimeoutException
  ConnectionTimeoutException({String? message, super.code})
      : super(
          message: message ??
              'Connection timeout. Please check your network.',
        );
}

/// Authentication-related exceptions
class AuthenticationException extends AppException {
  /// Constructor for AuthenticationException
  AuthenticationException({
    required super.message,
    super.code,
  });
}

/// Unauthorized access exception
class UnauthorizedException extends AuthenticationException {
  /// Constructor for UnauthorizedException
  UnauthorizedException({String? message, super.code})
      : super(
          message: message ??
              'Unauthorized access. Please login again.',
        );
}

/// Data-related exceptions
class DataException extends AppException {
  /// Constructor for DataException
  DataException({
    required super.message,
    super.code,
  });
}

/// Invalid data exception
class InvalidDataException extends DataException {
  /// Constructor for InvalidDataException
  InvalidDataException({String? message, super.code})
      : super(
          message: message ??
              'Invalid data received from server.',
        );
}

/// Cache operation exception
class CacheException extends DataException {
  /// Constructor for CacheException
  CacheException({String? message, super.code})
      : super(
          message: message ?? 'Cache operation failed.',
        );
}

/// Validation-related exceptions
class ValidationException extends AppException {
  /// Constructor for ValidationException
  ValidationException({
    required super.message,
    super.code,
  });
}

/// Generic/Unknown exceptions
class UnknownException extends AppException {
  /// Constructor for UnknownException
  UnknownException({String? message, super.code})
      : super(
          message: message ?? 'An unknown error occurred.',
        );
}

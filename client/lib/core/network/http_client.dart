/// Network Configuration
/// 
/// API client and network configuration for the application
library;

// TODO: Add http package to pubspec.yaml if not already present
// import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

abstract class HttpClient {
  /// Performs a GET request
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Performs a POST request
  Future<HttpResponse> post(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Performs a PUT request
  Future<HttpResponse> put(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  });

  /// Performs a DELETE request
  Future<HttpResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  });
}

class HttpResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, String> headers;

  HttpResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isServerError => statusCode >= 500;
}

class ApiClient implements HttpClient {
  final String baseUrl;
  final Duration timeout;

  ApiClient({
    String? baseUrl,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? AppConstants.apiBaseUrl,
        timeout = timeout ??
            Duration(seconds: AppConstants.apiTimeoutSeconds);

  @override
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    throw UnimplementedError(
      'HTTP client not configured. Add http package to pubspec.yaml',
    );
  }

  @override
  Future<HttpResponse> post(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    throw UnimplementedError(
      'HTTP client not configured. Add http package to pubspec.yaml',
    );
  }

  @override
  Future<HttpResponse> put(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    throw UnimplementedError(
      'HTTP client not configured. Add http package to pubspec.yaml',
    );
  }

  @override
  Future<HttpResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    throw UnimplementedError(
      'HTTP client not configured. Add http package to pubspec.yaml',
    );
  }

  // ignore: unused_element
  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl$endpoint';
  }

  // ignore: unused_element
  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}


/// Network Configuration
/// 
/// API client and network configuration for the application
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
  final http.Client _client = http.Client();

  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator and web
  ApiClient({
    String? baseUrl,
    Duration? timeout,
  })  : baseUrl = baseUrl ?? _getDefaultBaseUrl(),
        timeout = timeout ??
            Duration(seconds: AppConstants.apiTimeoutSeconds);

  static String _getDefaultBaseUrl() {
    // If you are using a tunnel service like ngrok or localtunnel to expose your local
    // server, set the public URL here (e.g. 'https://xyz-random-domain.ngrok-free.app').
    // This will override the local/emulator IPs below.
    const String tunnelUrl = 'https://grime-selective-document.ngrok-free.dev';

    if (tunnelUrl.isNotEmpty) {
      // Clean trailing slash if present to avoid double slashes in paths
      return tunnelUrl.endsWith('/') ? tunnelUrl.substring(0, tunnelUrl.length - 1) : tunnelUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    // TODO: If you are running on a physical Android/iOS device (instead of an emulator), 
    // set your computer's local network IP address here (e.g. '192.168.1.15').
    const String physicalDeviceIp = ''; 
    
    try {
      if (Platform.isAndroid) {
        if (physicalDeviceIp.isNotEmpty) {
          return 'http://$physicalDeviceIp:3000';
        }
        return 'http://10.0.2.2:3000';
      } else {
        if (physicalDeviceIp.isNotEmpty) {
          return 'http://$physicalDeviceIp:3000';
        }
        return 'http://localhost:3000';
      }
    } catch (e) {
      return 'http://localhost:3000';
    }
  }

  Map<String, String> _buildHeaders(Map<String, String>? extraHeaders) {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  @override
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client.get(
        uri,
        headers: _buildHeaders(headers),
      ).timeout(timeout ?? this.timeout);
      
      return HttpResponse(
        statusCode: response.statusCode,
        data: response.body.isNotEmpty ? json.decode(response.body) : null,
        headers: response.headers,
      );
    } catch (e) {
      return HttpResponse(
        statusCode: 500,
        data: {'error': e.toString()},
        headers: {},
      );
    }
  }

  @override
  Future<HttpResponse> post(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client.post(
        uri,
        headers: _buildHeaders(headers),
        body: json.encode(body),
      ).timeout(timeout ?? this.timeout);
      
      return HttpResponse(
        statusCode: response.statusCode,
        data: response.body.isNotEmpty ? json.decode(response.body) : null,
        headers: response.headers,
      );
    } catch (e) {
      return HttpResponse(
        statusCode: 500,
        data: {'error': e.toString()},
        headers: {},
      );
    }
  }

  @override
  Future<HttpResponse> put(
    String endpoint, {
    required dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client.put(
        uri,
        headers: _buildHeaders(headers),
        body: json.encode(body),
      ).timeout(timeout ?? this.timeout);
      
      return HttpResponse(
        statusCode: response.statusCode,
        data: response.body.isNotEmpty ? json.decode(response.body) : null,
        headers: response.headers,
      );
    } catch (e) {
      return HttpResponse(
        statusCode: 500,
        data: {'error': e.toString()},
        headers: {},
      );
    }
  }

  @override
  Future<HttpResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client.delete(
        uri,
        headers: _buildHeaders(headers),
      ).timeout(timeout ?? this.timeout);
      
      return HttpResponse(
        statusCode: response.statusCode,
        data: response.body.isNotEmpty ? json.decode(response.body) : null,
        headers: response.headers,
      );
    } catch (e) {
      return HttpResponse(
        statusCode: 500,
        data: {'error': e.toString()},
        headers: {},
      );
    }
  }
}


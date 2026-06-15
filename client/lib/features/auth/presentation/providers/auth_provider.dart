import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/http_client.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final HttpClient _httpClient = ApiClient();
  
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSignedIn = false;
  User? _currentUser;
  String? _token;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _isSignedIn;
  User? get currentUser => _currentUser;
  String? get token => _token;

  // Sign Up
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String studentId,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _httpClient.post('/api/auth/signup', body: {
        'fullName': fullName,
        'email': email,
        'studentId': studentId,
        'password': password,
      });

      if (response.isSuccess) {
        _token = response.data['token'];
        _currentUser = User.fromJson(response.data['account']);
        _isSignedIn = true;
        _isLoading = false;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(_currentUser!.toJson()));
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['error'] ?? 'Sign up failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _httpClient.post('/api/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response.isSuccess) {
        _token = response.data['token'];
        _currentUser = User.fromJson(response.data['account']);
        _isSignedIn = true;
        _isLoading = false;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(_currentUser!.toJson()));
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get Profile
  Future<void> getProfile() async {
    if (_token == null) return;

    try {
      final response = await _httpClient.get('/api/auth/profile', headers: {
        'Authorization': 'Bearer $_token',
      });

      if (response.isSuccess) {
        _currentUser = User.fromJson(response.data);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(_currentUser!.toJson()));
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _token = null;
    _currentUser = null;
    _isSignedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    notifyListeners();
  }

  // Try Auto Sign In
  Future<bool> tryAutoSignIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey('token')) return false;

      _token = prefs.getString('token');
      final userStr = prefs.getString('user');
      if (userStr != null) {
        _currentUser = User.fromJson(json.decode(userStr));
      }

      if (_token != null && _currentUser != null) {
        _isSignedIn = true;
        notifyListeners();
        // Refresh profile in background
        getProfile();
        return true;
      }
    } catch (e) {
      debugPrint('Error in tryAutoSignIn: $e');
    }
    return false;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

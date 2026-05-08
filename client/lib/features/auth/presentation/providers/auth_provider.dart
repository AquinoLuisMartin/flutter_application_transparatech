import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSignedIn = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _isSignedIn;

  // Sign Up
  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual sign-up logic with API
      // For now, simulating a network call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success
      _isSignedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement actual sign-in logic with API
      await Future.delayed(const Duration(seconds: 2));

      _isSignedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign In
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implement Google sign-in logic
      await Future.delayed(const Duration(seconds: 2));

      _isSignedIn = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement sign-out logic
      await Future.delayed(const Duration(milliseconds: 500));

      _isSignedIn = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.light;
  Brightness _platformBrightness = Brightness.light;

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
    _platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return _platformBrightness == Brightness.dark;
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      final newBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      if (_platformBrightness != newBrightness) {
        _platformBrightness = newBrightness;
        notifyListeners();
      }
    }
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      if (mode == ThemeMode.system) {
        _platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// A decoupled ThemeProvider subclass for Officer & Admin views.
/// Locks the theme mode to light mode so that visual overrides remain anchored to guidelines.
class OfficerThemeProvider extends ThemeProvider {}

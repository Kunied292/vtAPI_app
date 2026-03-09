import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to Automatic
  final String _prefKey = 'theme_preference';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString(_prefKey);

    if (themeStr != null) {
      if (themeStr == 'Dark Theme') {
        _themeMode = ThemeMode.dark;
      } else if (themeStr == 'Light Theme') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  void setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, themeName);

    if (themeName == 'Dark Theme') {
      _themeMode = ThemeMode.dark;
    } else if (themeName == 'Light Theme') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }
}

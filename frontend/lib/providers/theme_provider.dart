import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  // Exposes the active app theme mode to MaterialApp.
  ThemeMode get themeMode => _themeMode;

  // Tells UI widgets whether dark mode is currently active.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Switches between light and dark mode and refreshes listening widgets.
  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

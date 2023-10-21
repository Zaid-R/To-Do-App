import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  ThemeProvider() : _isDarkMode = false;

  bool get isDarkMode => _isDarkMode; 
  ThemeMode get getTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

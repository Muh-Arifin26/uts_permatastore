import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;

  ThemeProvider() {
    loadTheme(); // 🔥 load saat app start
  }

  ThemeMode get themeMode =>
      isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // 🔥 LOAD DARI STORAGE
  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }

  // 🔥 SIMPAN KE STORAGE
  void toggleTheme(bool value) async {
    isDarkMode = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);

    notifyListeners();
  }
}
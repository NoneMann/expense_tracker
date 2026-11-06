import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode themeMode = ThemeMode.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    themeMode = ThemeMode.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}

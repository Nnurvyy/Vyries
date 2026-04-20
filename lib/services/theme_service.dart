import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class ThemeService extends ChangeNotifier {
  static const String _key = 'dark_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeService() {
    _load();
  }

  void _load() {
    final isDark =
        HiveService.settings.get(_key, defaultValue: false) as bool;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await HiveService.settings.put(_key, isDarkMode);
    notifyListeners();
  }
}

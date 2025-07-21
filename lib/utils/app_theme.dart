
import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  amoledBlack,
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = AppThemes.lightTheme;
  AppThemeMode _currentThemeMode = AppThemeMode.light;

  ThemeNotifier() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;
  AppThemeMode get currentThemeMode => _currentThemeMode;

  void setTheme(AppThemeMode mode) async {
    _currentThemeMode = mode;
    switch (mode) {
      case AppThemeMode.light:
        _currentTheme = AppThemes.lightTheme;
        break;
      case AppThemeMode.dark:
        _currentTheme = AppThemes.darkTheme;
        break;
      case AppThemeMode.amoledBlack:
        _currentTheme = AppThemes.amoledBlackTheme;
        break;
    }
    notifyListeners();
    _saveTheme(mode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('appThemeMode') ?? AppThemeMode.light.toString();
    AppThemeMode loadedThemeMode = AppThemeMode.values.firstWhere(
      (e) => e.toString() == themeModeString,
      orElse: () => AppThemeMode.light,
    );
    setTheme(loadedThemeMode);
  }

  Future<void> _saveTheme(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appThemeMode', mode.toString());
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData amoledBlackTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes > 0 ? (Math.log(bytes) / Math.log(1024)) : 0).floor();
    return '${(bytes / Math.pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}

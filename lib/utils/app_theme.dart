
import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  amoledBlack,
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = AppThemes.lightTheme;
  AppThemeMode _currentThemeMode = AppThemeMode.light;

  ThemeData get currentTheme => _currentTheme;
  AppThemeMode get currentThemeMode => _currentThemeMode;

  void setTheme(AppThemeMode mode) {
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
    _currentThemeMode = mode;
    notifyListeners();
  }
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    // Add more light theme properties
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blueGrey,
      foregroundColor: Colors.white,
    ),
    // Add more dark theme properties
  );

  static final ThemeData amoledBlackTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.grey,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    // Add more AMOLED black theme properties
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tema extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData display() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0XFFB12856), brightness: Brightness.light),
      textTheme: GoogleFonts.oswaldTextTheme(TextTheme(
        bodyLarge: TextStyle(fontSize: 30, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 25, color: Colors.black),
        bodySmall: TextStyle(fontSize: 16, color: Colors.black),
      )),
      scaffoldBackgroundColor: Colors.white,
      backgroundColor: Colors.white,
    );
  }

  ThemeData displaydark() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0XFFB12856), brightness: Brightness.dark),
      textTheme: GoogleFonts.inderTextTheme(TextTheme(
        bodyLarge: TextStyle(fontSize: 30, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 25, color: Colors.white),
        bodySmall: TextStyle(fontSize: 16, color: Colors.white),
      )),
      scaffoldBackgroundColor: Colors.grey[800],
      backgroundColor: Colors.grey[800],
    );
  }

  ThemeMode getThemeMode() {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

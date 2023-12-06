import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Tema extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  TextTheme teks = TextTheme(
    bodyLarge: GoogleFonts.raleway(
      fontSize: 30,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.raleway(
      fontSize: 25,
      color: Colors.black,
    ),
    bodySmall: GoogleFonts.raleway(
      fontSize: 16,
      color: Colors.black,
    ),
  );
  TextTheme teksdark = TextTheme(
    bodyLarge: GoogleFonts.raleway(
      fontSize: 30,
      color: Colors.white,
    ),
    bodyMedium: GoogleFonts.raleway(
      fontSize: 25,
      color: Colors.white,
    ),
    bodySmall: GoogleFonts.raleway(
      fontSize: 16,
      color: Colors.white,
    ),
  );

  ThemeData display() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0XFFB12856), brightness: Brightness.light),
      textTheme: teksdark,
      scaffoldBackgroundColor: Colors.white,
      backgroundColor: Colors.white,
    );
  }

  ThemeData displaydark() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0XFFB12856), brightness: Brightness.dark),
      textTheme: teks,
      scaffoldBackgroundColor: Colors.black,
      backgroundColor: Colors.black,
    );
  }

  ThemeMode getThemeMode() {
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}

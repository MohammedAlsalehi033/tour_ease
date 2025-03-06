import 'package:flutter/material.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true, // Enable Material 3 design
    colorScheme: ColorScheme.light(
      primary: Colors.blue, // Primary color
      secondary: Colors.blueAccent, // Secondary color
      surface: Colors.white, // Surface color
      background: Colors.white, // Background color
      onPrimary: Colors.white, // Text/icon color on primary
      onSecondary: Colors.white, // Text/icon color on secondary
      onSurface: Colors.black, // Text/icon color on surface
      onBackground: Colors.black, // Text/icon color on background
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.blue),
      titleTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.blue, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.blue, fontSize: 28, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14),
      titleLarge: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: BorderSide(color: Colors.blue),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    iconTheme: IconThemeData(color: Colors.blue),
    cardTheme: CardTheme(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true, // Enable Material 3 design
    colorScheme: ColorScheme.dark(
      primary: Colors.blue, // Primary color
      secondary: Colors.blueAccent, // Secondary color
      surface: Colors.grey[900]!, // Surface color
      background: Colors.black, // Background color
      onPrimary: Colors.white, // Text/icon color on primary
      onSecondary: Colors.white, // Text/icon color on secondary
      onSurface: Colors.white, // Text/icon color on surface
      onBackground: Colors.white, // Text/icon color on background
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: Colors.blue, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: Colors.blue, fontSize: 28, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
      titleLarge: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue,
        side: BorderSide(color: Colors.blue),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    cardTheme: CardTheme(
      elevation: 2,
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
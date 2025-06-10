import 'package:flutter/material.dart';

class AppTheme {
  // Using Poppins as an example, ensure it's added to pubspec.yaml and assets
  // if you want to use a custom font like Poppins, Nunito, or Inter.
  // For now, this will use system default fonts.
  // To use a custom font:
  // 1. Add font files to an `assets/fonts/` directory.
  // 2. Declare the font in `pubspec.yaml`:
  //    flutter:
  //      fonts:
  //        - family: Poppins
  //          fonts:
  //            - asset: assets/fonts/Poppins-Regular.ttf
  //            - asset: assets/fonts/Poppins-Medium.ttf
  //              weight: 500
  //            - asset: assets/fonts/Poppins-Bold.ttf
  //              weight: 700
  // For simplicity, this example will proceed without custom fonts initially.

  // Fluorescent colors for habits
  static const List<Color> fluorescentColors = [
    Color(0xFF00FF41), // Bright green
    Color(0xFF00D4FF), // Bright cyan
    Color(0xFFFF0080), // Bright pink
    Color(0xFFFFFF00), // Bright yellow
    Color(0xFFFF4000), // Bright orange
    Color(0xFF8000FF), // Bright purple
    Color(0xFF00FF80), // Bright mint
    Color(0xFFFF0040), // Bright red
    Color(0xFF4000FF), // Bright blue
    Color(0xFF80FF00), // Bright lime
  ];

  static final Color _darkPrimaryColor = Color(0xFF1A1A1A); // Darker background
  static final Color _darkAccentColor = Color(0xFF00FF41); // Bright green accent
  static final Color _darkBackgroundColor = Color(0xFF0F0F0F); // Very dark background
  static final Color _darkCardColor = Color(0xFF1E1E1E); // Card background
  static final Color _darkSurfaceColor = Color(0xFF2A2A2A); // Surface color

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: _darkAccentColor,
      secondary: _darkAccentColor,
      surface: _darkCardColor,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white, // Ensure text is white on dark background
      error: Color(0xFFFF4444),
      onError: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 8.0,
      color: _darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBackgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkAccentColor,
      foregroundColor: Colors.black,
      elevation: 8.0,
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      buttonColor: _darkAccentColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkAccentColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 4.0,
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkAccentColor,
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      labelStyle: TextStyle(color: Colors.white), // Ensure labels are visible
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: _darkAccentColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
      bodySmall: TextStyle(fontSize: 12, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white70),
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    dividerColor: Colors.grey.shade700,
    listTileTheme: ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.white,
    ),
  );

  // Light theme with better contrast
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.light(
      primary: Colors.blue.shade600,
      secondary: Colors.blue.shade400,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
    ),
    cardTheme: CardThemeData(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );
}

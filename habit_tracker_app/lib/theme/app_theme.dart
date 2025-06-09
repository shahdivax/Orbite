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

  static final Color _darkPrimaryColor = Colors.blueGrey.shade900; // Example primary
  static final Color _darkAccentColor = Colors.tealAccent.shade400; // Example accent
  static final Color _darkBackgroundColor = Color(0xFF121212); // Common dark theme background
  static final Color _darkCardColor = Color(0xFF1E1E1E); // Slightly lighter than background

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    // accentColor: _darkAccentColor, // accentColor is deprecated, use colorScheme.secondary
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      surface: _darkCardColor, // Use for cards, dialogs etc.
      background: _darkBackgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      color: _darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    appBarTheme: AppBarTheme(
      color: _darkCardColor, // Or _darkPrimaryColor
      elevation: 1.0,
      iconTheme: IconThemeData(color: _darkAccentColor),
      titleTextStyle: TextStyle(
        // fontFamily: 'Poppins', // Uncomment if using custom font
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkAccentColor,
      foregroundColor: Colors.black,
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      buttonColor: _darkAccentColor,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButton.styleFrom(
      backgroundColor: _darkAccentColor,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textButtonTheme: TextButton.styleFrom(
      foregroundColor: _darkAccentColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkCardColor, // Or a slightly different shade
      hintStyle: TextStyle(color: Colors.grey.shade500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkAccentColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: _darkBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    // fontFamily: 'Poppins', // Set default font family if using one
    textTheme: TextTheme( // Define default text styles
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white),
    ).apply(
        // fontFamily: 'Poppins', // Apply font family to all text styles
        bodyColor: Colors.white,
        displayColor: Colors.white,
    ),
    iconTheme: IconThemeData(
      color: _darkAccentColor,
    ),
    dividerColor: Colors.grey.shade800,
    // Add other theme properties as needed (e.g., textSelectionTheme)
  );

  // Define a light theme for completeness, can be expanded later
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue, // Example, customize as needed
    // accentColor: Colors.amber, // Deprecated
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.amber,
      // ... other light theme colors
    ),
    // fontFamily: 'Poppins',
    // Define other light theme properties if needed
    // For now, it's a very basic light theme
  );
}

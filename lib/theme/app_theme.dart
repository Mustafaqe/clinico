import 'package:flutter/material.dart';

class AppTheme {
  // Modern Medical Color Palette
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color cardDarkElevated = Color(0xFF2D2D2D);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color.fromARGB(255, 226, 8, 8);
  static const Color errorRed = Color(0xFFE53935);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9E9E9E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentTeal,
        surface: cardDark,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: surfaceDark,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: cardDark,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: cardDark,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDarkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primaryBlue),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(color: Colors.grey.shade800, thickness: 1),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: cardDarkElevated,
        selectedColor: primaryBlue,
        labelStyle: const TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(backgroundColor: cardDark),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDarkElevated,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardDark,
        selectedIconTheme: const IconThemeData(color: primaryBlue),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: const TextStyle(color: primaryBlue),
        unselectedLabelTextStyle: TextStyle(color: textSecondary),
      ),
    );
  }

  // Gradient decorations
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get accentCardDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentTeal.withOpacity(0.2), primaryBlue.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentTeal.withOpacity(0.3)),
      );
}

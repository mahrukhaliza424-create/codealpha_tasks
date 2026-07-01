import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Midnight Purple to Indigo
  static const Color midnightPurple = Color(0xFF1A0B2E);
  static const Color indigoAccent = Color(0xFF311B92);
  
  static const Color primaryGreen = Color(0xFF10B981); // Mastered
  static const Color primaryBlue = Color(0xFF3B82F6); // Question / Review
  static const Color surfaceColor = Color(0xFF2D1B4E);
  
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: midnightPurple,
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryGreen,
      surface: surfaceColor,
      background: midnightPurple,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
  );

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        spreadRadius: -5,
      )
    ],
  );
  
  static BoxDecoration get cardGradientBorder => BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryBlue, primaryGreen],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
  );
}

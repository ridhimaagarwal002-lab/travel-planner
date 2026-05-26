import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0A1628),
      primaryColor: const Color(0xFFF4A825),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFF4A825),
        surface: Color(0xFF0F1F3D),
        onSurface: Colors.white,
      ),
      cardColor: const Color(0xFF152847),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(color: Colors.white),
        displayMedium: GoogleFonts.playfairDisplay(color: Colors.white),
        displaySmall: GoogleFonts.playfairDisplay(color: Colors.white),
        headlineLarge: GoogleFonts.playfairDisplay(color: Colors.white),
        headlineMedium: GoogleFonts.playfairDisplay(color: Colors.white),
        headlineSmall: GoogleFonts.playfairDisplay(color: Colors.white),
        titleLarge: GoogleFonts.playfairDisplay(color: Colors.white),
        titleMedium: GoogleFonts.playfairDisplay(color: Colors.white),
        titleSmall: GoogleFonts.playfairDisplay(color: Colors.white),
        bodyLarge: GoogleFonts.inter(color: Colors.white),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFFB0BEC5)),
        bodySmall: GoogleFonts.inter(color: const Color(0xFFB0BEC5)),
        labelLarge: GoogleFonts.inter(color: Colors.white),
        labelMedium: GoogleFonts.inter(color: const Color(0xFFB0BEC5)),
        labelSmall: GoogleFonts.inter(color: const Color(0xFFB0BEC5)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF152847),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F1F3D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF4A825), width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: const Color(0xFFB0BEC5)),
        hintStyle: GoogleFonts.inter(color: const Color(0xFFB0BEC5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF4A825),
          foregroundColor: const Color(0xFF0A1628),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

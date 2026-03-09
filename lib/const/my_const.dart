import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 🎨 Base Theme Colors (Dark defaults) ---
const Color vtBackground = Color(0xFF0F172A); // สีพื้นหลัง (กรมท่าเข้ม)
const Color vtCard = Color(0xFF1E293B); // สีการ์ด (เทาอมฟ้า)
const Color vtAccent = Color(0xFF3B82F6); // สีหลัก (ฟ้าสว่าง)
const Color vtGreen = Color(0xFF10B981); // สีปลอดภัย (เขียว)
const Color vtRed = Color(0xFFEF4444); // สีอันตราย (แดง)
const Color vtTextPrimary = Colors.white;
const Color vtTextSecondary = Colors.grey;

// Light Mode equivalents
const Color vtLightBackground = Color(0xFFF1F5F9);
const Color vtLightCard = Colors.white;
const Color vtLightTextPrimary = Color(0xFF1E293B);
const Color vtLightTextSecondary = Color(0xFF64748B);

TextStyle textTitle = TextStyle(
  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
  fontWeight: FontWeight.bold,
  fontSize: 24,
);

TextStyle textLabel = TextStyle(
  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

TextStyle textDescription = TextStyle(
  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
  fontWeight: FontWeight.normal,
  fontSize: 14,
);

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: vtLightBackground,
      cardColor: vtLightCard,
      primaryColor: vtAccent,
      colorScheme: const ColorScheme.light(
        primary: vtAccent,
        secondary: vtAccent,
        surface: vtLightCard,
        error: vtRed,
        onPrimary: Colors.white,
        onSurface: vtLightTextPrimary,
        tertiary: vtGreen, // Use tertiary for safe elements
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: vtLightBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: vtLightTextPrimary),
        titleTextStyle: TextStyle(
          color: vtLightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: vtLightTextPrimary),
        bodyMedium: TextStyle(color: vtLightTextSecondary),
      ),
      iconTheme: const IconThemeData(color: vtLightTextPrimary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: vtLightCard,
        selectedItemColor: vtAccent,
        unselectedItemColor: vtLightTextSecondary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: vtBackground,
      cardColor: vtCard,
      primaryColor: vtAccent,
      colorScheme: const ColorScheme.dark(
        primary: vtAccent,
        secondary: vtAccent,
        surface: vtCard,
        error: vtRed,
        onPrimary: Colors.white,
        onSurface: vtTextPrimary,
        tertiary: vtGreen,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: vtBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: vtTextPrimary),
        titleTextStyle: TextStyle(
          color: vtTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: vtTextPrimary),
        bodyMedium: TextStyle(color: vtTextSecondary),
      ),
      iconTheme: const IconThemeData(color: vtTextPrimary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: vtCard,
        selectedItemColor: vtAccent,
        unselectedItemColor: vtTextSecondary,
      ),
    );
  }
}

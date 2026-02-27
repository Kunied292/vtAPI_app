import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 🎨 Theme Colors ---
const Color vtBackground = Color(0xFF0F172A); // สีพื้นหลัง (กรมท่าเข้ม)
const Color vtCard = Color(0xFF1E293B); // สีการ์ด (เทาอมฟ้า)
const Color vtAccent = Color(0xFF3B82F6); // สีหลัก (ฟ้าสว่าง)
const Color vtGreen = Color(0xFF10B981); // สีปลอดภัย (เขียว)
const Color vtRed = Color(0xFFEF4444); // สีอันตราย (แดง)
const Color vtTextPrimary = Colors.white;
const Color vtTextSecondary = Colors.grey;

TextStyle textTitle = TextStyle(
  color: vtTextPrimary,
  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
  fontWeight: FontWeight.bold,
  fontSize: 24,
);

TextStyle textLabel = TextStyle(
  color: vtTextPrimary,
  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

TextStyle textDescription = TextStyle(
  color: vtTextSecondary,
  fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
  fontWeight: FontWeight.normal,
  fontSize: 14,
);

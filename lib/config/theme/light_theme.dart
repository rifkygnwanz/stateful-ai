import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFFAFAFA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFAFAFA),
    foregroundColor: Color(0xFF0A0A0A),
    elevation: 1,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF0A0A0A)), // title
    bodyMedium: TextStyle(color: Color(0xFF525252)), // desc
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF039866), // bubble user
    onPrimary: Colors.white, // teks user
    surfaceContainerHighest: Color(0xFFE5F7F2), // bubble AI
    onSurface: Color(0xFF525252), // teks AI
  ),
);

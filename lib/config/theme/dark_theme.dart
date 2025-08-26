import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0A0A0A),
    foregroundColor: Color(0xFFFAFAFA),
    elevation: 1,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFFAFAFA)), // title
    bodyMedium: TextStyle(color: Color(0xFFA3A3A3)), // desc
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF039866), // bubble user
    onPrimary: Colors.white, // teks user
    surfaceContainerHighest: Color(0xFF1C1C1C), // bubble AI
    onSurface: Color(0xFFA3A3A3), // teks AI
  ),
);

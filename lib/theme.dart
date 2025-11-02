import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF4F46E5), // richer indigo
    secondary: const Color(0xFF06B6D4), // cyan accent
    surface: Colors.white,
    surfaceContainerHighest: const Color(0xFFF5F5F5),
    error: const Color(0xFFFF5B5B),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFF1A1A1A),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF8F9FA),
    foregroundColor: Color(0xFF1A1A1A),
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE8E8E8), width: 1),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4F46E5),
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF1A1A1A),
      side: const BorderSide(color: Color(0xFFE8E8E8)),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
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
      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: const Color(0xFF4F46E5),
    labelStyle: const TextStyle(color: Color(0xFF1A1A1A)),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    side: const BorderSide(color: Color(0xFFE8E8E8)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF5B7FFF)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1A1A1A)),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF666666)),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF4F46E5),
    secondary: const Color(0xFF06B6D4),
    surface: const Color(0xFF1E1E1E),
    surfaceContainerHighest: const Color(0xFF2A2A2A),
    error: const Color(0xFFFF5B5B),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFFE8E8E8),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF121212),
    foregroundColor: Color(0xFFE8E8E8),
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFF2A2A2A), width: 1),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4F46E5),
    foregroundColor: Colors.white,
    shape: CircleBorder(),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFE8E8E8),
      side: const BorderSide(color: Color(0xFF2A2A2A)),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
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
      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    selectedColor: const Color(0xFF4F46E5),
    labelStyle: const TextStyle(color: Color(0xFFE8E8E8)),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    side: const BorderSide(color: Color(0xFF2A2A2A)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF5B7FFF)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFE8E8E8)),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE8E8E8)),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFE8E8E8)),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF999999)),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
  ),
);

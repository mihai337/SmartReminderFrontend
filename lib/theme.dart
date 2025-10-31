import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF2563EB),
    secondary: const Color(0xFF3B82F6),
    surface: const Color(0xFFF8FAFC),
    surfaceContainerHighest: const Color(0xFFE8EDF2),
    error: const Color(0xFFDC2626),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFF1E293B),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF1E293B),
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFF8FAFC),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFE8EDF2), width: 1),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2563EB),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF2563EB),
      side: const BorderSide(color: Color(0xFFE8EDF2)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE8EDF2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE8EDF2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF8FAFC),
    selectedColor: const Color(0xFF2563EB),
    labelStyle: const TextStyle(color: Color(0xFF1E293B)),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    side: const BorderSide(color: Color(0xFFE8EDF2)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF2563EB)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF1E293B)),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF475569)),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF3B82F6),
    secondary: const Color(0xFF60A5FA),
    surface: const Color(0xFF1A1F26),
    surfaceContainerHighest: const Color(0xFF2A3340),
    error: const Color(0xFFEF4444),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFFE8EDF2),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF0F1419),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F1419),
    foregroundColor: Color(0xFFE8EDF2),
    elevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1A1F26),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF2A3340), width: 1),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3B82F6),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3B82F6),
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF3B82F6),
      side: const BorderSide(color: Color(0xFF2A3340)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1F26),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2A3340)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF2A3340)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1A1F26),
    selectedColor: const Color(0xFF3B82F6),
    labelStyle: const TextStyle(color: Color(0xFFE8EDF2)),
    secondaryLabelStyle: const TextStyle(color: Colors.white),
    side: const BorderSide(color: Color(0xFF2A3340)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF3B82F6)),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFE8EDF2)),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE8EDF2)),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFE8EDF2)),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF94A3B8)),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
  ),
);

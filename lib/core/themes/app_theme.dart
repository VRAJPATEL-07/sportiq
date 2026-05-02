import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: Colors.white,
    onSurface: Colors.black87,
  ),
  scaffoldBackgroundColor: Colors.grey[50],
  textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.light().textTheme).copyWith(
    bodyLarge: GoogleFonts.inter(color: Colors.black87),
    bodyMedium: GoogleFonts.inter(color: Colors.black54),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surfaceMedium,
    onSurface: AppColors.onSurface,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme).copyWith(
    bodyLarge: GoogleFonts.inter(color: AppColors.onSurface),
    bodyMedium: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: AppColors.surfaceLow,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceLow,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
);

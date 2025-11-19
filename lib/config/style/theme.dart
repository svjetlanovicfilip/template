import 'package:flutter/material.dart';
import 'colors.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.secondaryLight,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.onSecondaryLight,
    onSurface: AppColors.onSurfaceLight,
    error: AppColors.errorLight,
    primaryContainer: AppColors.elevatedButtonBackgroundLight,
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputBackgroundLight, // input background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: AppColors.inputBorderLight), // light border
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.white, fontSize: 16),
    headlineSmall: TextStyle(color: AppColors.white, fontSize: 20),
    labelMedium: TextStyle(color: AppColors.slate800, fontSize: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.amber500,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

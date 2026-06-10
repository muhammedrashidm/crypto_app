import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';

abstract class AppTheme {
  static TextStyle get _displayBalance => GoogleFonts.inter(
        fontSize: 40.0,
        fontWeight: FontWeight.bold,
        height: 48.0 / 40.0,
        letterSpacing: -0.02 * 40.0,
        color: AppColors.onBackground,
      );

  static TextStyle get _headlineLg => GoogleFonts.inter(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        height: 32.0 / 24.0,
        color: AppColors.onBackground,
      );

  static TextStyle get _headlineMd => GoogleFonts.inter(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        height: 28.0 / 20.0,
        color: AppColors.onBackground,
      );

  static TextStyle get _bodyLg => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        height: 24.0 / 16.0,
        color: AppColors.onBackground,
      );

  static TextStyle get _bodySm => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        height: 20.0 / 14.0,
        color: AppColors.onBackground.withValues(alpha: 0.7),
      );

  static TextStyle get _labelCaps => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        height: 16.0 / 12.0,
        letterSpacing: 0.05 * 12.0,
        color: AppColors.onBackground,
      );

  static TextStyle get _keypadNum => GoogleFonts.inter(
        fontSize: 28.0,
        fontWeight: FontWeight.w500,
        height: 32.0 / 28.0,
        color: AppColors.onBackground,
      );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: Colors.white,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
      ),
      textTheme: TextTheme(
        displayLarge: _displayBalance,
        displayMedium: _keypadNum,
        headlineLarge: _headlineLg,
        headlineMedium: _headlineMd,
        bodyLarge: _bodyLg,
        bodyMedium: _bodyLg,
        bodySmall: _bodySm,
        labelLarge: _labelCaps,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1.0,
        space: 1.0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
        labelStyle: _bodyLg,
        hintStyle: _bodySm,
      ),
    );
  }
}

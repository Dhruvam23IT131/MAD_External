import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.nunito(
            color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 32),
        displayMedium: GoogleFonts.nunito(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineLarge: GoogleFonts.nunito(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
        headlineMedium: GoogleFonts.nunito(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        headlineSmall: GoogleFonts.nunito(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge: GoogleFonts.inter(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: GoogleFonts.inter(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.inter(
            color: AppColors.textPrimary, fontWeight: FontWeight.normal, fontSize: 16),
        bodyMedium: GoogleFonts.inter(
            color: AppColors.textSecondary, fontWeight: FontWeight.normal, fontSize: 14),
        bodySmall: GoogleFonts.inter(
            color: AppColors.textMuted, fontWeight: FontWeight.normal, fontSize: 12),
        labelLarge: GoogleFonts.inter(
            color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
            color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primaryDark,
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.card,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

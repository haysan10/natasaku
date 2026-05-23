import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        surface: AppColors.surfaceLight,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        outlineVariant: AppColors.borderLight,
        primaryContainer: AppColors.primaryContainer,
      ),
      textTheme: AppTypography.lightTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.lightTextTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 80,
        indicatorColor: AppColors.primarySoft,
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: AppColors.surfaceLight,
        dragHandleSize: Size(40, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const darkScheme = ColorScheme.dark(
      primary:          Color(0xFF2DD4BF),
      onPrimary:        Color(0xFF003730),
      primaryContainer: Color(0xFF004D45),
      onPrimaryContainer: Color(0xFF99F6E4),

      secondary:          Color(0xFFFBBF24),
      onSecondary:        Color(0xFF3D2800),
      secondaryContainer: Color(0xFF4D3500),
      onSecondaryContainer: Color(0xFFFDE68A),

      error:          Color(0xFFFB7185),
      onError:        Color(0xFF4A0010),
      errorContainer: Color(0xFF5C0014),
      onErrorContainer: Color(0xFFFFB3C1),

      surface:          Color(0xFF0F1F1E),
      onSurface:        Color(0xFFE0F2F0),
      surfaceContainerHighest: Color(0xFF1A2E2C),
      surfaceContainerHigh:    Color(0xFF162826),
      surfaceContainer:        Color(0xFF122422),
      surfaceContainerLow:     Color(0xFF0E1E1C),

      outline:        Color(0xFF3D5C59),
      outlineVariant: Color(0xFF2A4240),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F1F1E),
      colorScheme: darkScheme,
      textTheme: AppTypography.darkTextTheme,
      cardColor: const Color(0xFF162826),
      cardTheme: CardThemeData(
        color: const Color(0xFF162826),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF2A4240), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1F1E),
        foregroundColor: Color(0xFFE0F2F0),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF122422),
        hintStyle: AppTypography.darkTextTheme.bodyMedium,
        labelStyle: AppTypography.darkTextTheme.bodyMedium,
        floatingLabelStyle: AppTypography.darkTextTheme.labelMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2A4240)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2A4240)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2DD4BF),
          foregroundColor: const Color(0xFF003730),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 80,
        backgroundColor: const Color(0xFF122422),
        indicatorColor: const Color(0xFF004D45),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: Color(0xFF99F6E4), fontSize: 11),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: Color(0xFF0F1F1E),
        dragHandleSize: Size(40, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0F1F1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppTypography.darkTextTheme.titleLarge?.copyWith(color: const Color(0xFFE0F2F0)),
        contentTextStyle: AppTypography.darkTextTheme.bodyMedium?.copyWith(color: const Color(0xFFE0F2F0)),
      ),
    );
  }
}

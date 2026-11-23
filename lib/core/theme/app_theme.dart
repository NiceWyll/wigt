import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text.dart';
import 'dimens.dart';

/// Tema oscuro de Wigt (morado + negro).
abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.onBackground,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.onBackground,
        surface: AppColors.surface,
        onSurface: AppColors.onBackground,
        surfaceContainerHighest: AppColors.surfaceHigh,
        outline: AppColors.outline,
        error: AppColors.danger,
        onError: AppColors.onBackground,
      ),
      // Texto
      textTheme: const TextTheme(
        displayLarge: AppText.displayLarge,
        displayMedium: AppText.displayMedium,
        titleLarge: AppText.titleLarge,
        titleMedium: AppText.titleMedium,
        titleSmall: AppText.titleSmall,
        bodyLarge: AppText.bodyLarge,
        bodyMedium: AppText.bodyMedium,
        bodySmall: AppText.bodySmall,
        labelMedium: AppText.labelMedium,
        labelSmall: AppText.labelSmall,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppText.titleLarge,
        centerTitle: false,
      ),
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          side: const BorderSide(color: AppColors.outline, width: AppDimens.borderWidth),
        ),
        margin: EdgeInsets.zero,
      ),
      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusField),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusField),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusField),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusField),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: AppText.bodyMedium.copyWith(color: AppColors.onMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onBackground,
          disabledBackgroundColor: AppColors.surfaceHigh,
          disabledForegroundColor: AppColors.onMuted,
          minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
          elevation: 0,
          textStyle: AppText.titleSmall,
        ),
      ),
      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppText.labelMedium,
        ),
      ),
      // BottomNav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.onMuted,
        size: AppDimens.iconSizeMd,
      ),
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: AppText.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        ),
      ),
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onBackground),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'radar_colors.dart';
import 'radar_radius.dart';
import 'radar_spacing.dart';
import 'radar_text_styles.dart';

abstract final class RadarTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: RadarColors.primary,
      primary: RadarColors.primary,
      secondary: RadarColors.indigo,
      tertiary: RadarColors.clinicalAction,
      error: RadarColors.clinicalDanger,
      surface: RadarColors.surface,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: RadarColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: RadarColors.background,
        foregroundColor: RadarColors.textPrimary,
        centerTitle: false,
        titleTextStyle: RadarTextStyles.sectionTitle,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: RadarTextStyles.screenTitle,
        headlineMedium: RadarTextStyles.sectionTitle,
        titleLarge: RadarTextStyles.question,
        titleMedium: RadarTextStyles.decision,
        bodyLarge: RadarTextStyles.body,
        bodyMedium: RadarTextStyles.secondary,
        labelSmall: RadarTextStyles.caption,
        labelMedium: RadarTextStyles.badge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: RadarColors.primary,
          foregroundColor: RadarColors.surface,
          disabledBackgroundColor: RadarColors.disabled,
          disabledForegroundColor: RadarColors.textMuted,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: RadarSpacing.lg,
            vertical: RadarSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
          ),
          textStyle: RadarTextStyles.badge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: RadarColors.clinicalAction,
          disabledForegroundColor: RadarColors.textMuted,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(
            horizontal: RadarSpacing.lg,
            vertical: RadarSpacing.md,
          ),
          side: const BorderSide(color: RadarColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadarRadius.small),
          ),
          textStyle: RadarTextStyles.badge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RadarColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RadarSpacing.lg,
          vertical: RadarSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadarRadius.small),
          borderSide: const BorderSide(color: RadarColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadarRadius.small),
          borderSide: const BorderSide(color: RadarColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadarRadius.small),
          borderSide: const BorderSide(color: RadarColors.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: RadarColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadarRadius.card),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: RadarColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

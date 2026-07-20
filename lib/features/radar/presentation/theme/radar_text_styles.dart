import 'package:flutter/material.dart';

import 'radar_colors.dart';

abstract final class RadarTextStyles {
  static const screenTitle = TextStyle(
    color: RadarColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.12,
  );

  static const sectionTitle = TextStyle(
    color: RadarColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.18,
  );

  static const question = TextStyle(
    color: RadarColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.24,
  );

  static const decision = TextStyle(
    color: RadarColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.24,
  );

  static const body = TextStyle(
    color: RadarColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.38,
  );

  static const secondary = TextStyle(
    color: RadarColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.36,
  );

  static const contextTitle = TextStyle(
    color: RadarColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.28,
  );

  static const contextSecondary = TextStyle(
    color: RadarColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const categoryLabel = TextStyle(
    color: RadarColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const action = TextStyle(
    color: RadarColors.primary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const caption = TextStyle(
    color: RadarColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.32,
  );

  static const badge = TextStyle(
    color: RadarColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Backward-compatible aliases for the current Radar presentation widgets.
  static const display = screenTitle;
  static const title = sectionTitle;
  static const muted = secondary;
  static const label = badge;
}

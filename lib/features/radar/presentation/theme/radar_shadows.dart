import 'package:flutter/material.dart';

import 'radar_colors.dart';
import 'radar_design_tokens.dart';

abstract final class RadarShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: RadarColors.textPrimary.withValues(alpha: 0.03),
      blurRadius: 20,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get navigation => [
    BoxShadow(
      color: RadarColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get loginCard => [
    BoxShadow(
      color: RadarColors.textPrimary.withValues(alpha: 0.08),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get loginButton => [
    BoxShadow(
      color: RadarComponentTokens.primaryButtonBackground.withValues(
        alpha: 0.24,
      ),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];
}

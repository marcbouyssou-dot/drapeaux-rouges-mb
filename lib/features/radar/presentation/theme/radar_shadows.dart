import 'package:flutter/material.dart';

import 'radar_colors.dart';

abstract final class RadarShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: RadarColors.textPrimary.withValues(alpha: 0.05),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get navigation => [
    BoxShadow(
      color: RadarColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];
}

import 'package:flutter/material.dart';

import 'radar_colors.dart';

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
}

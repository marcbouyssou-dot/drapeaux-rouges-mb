import 'package:flutter/material.dart';

import 'radar_colors.dart';

abstract final class RadarTextStyles {
  static const display = TextStyle(
    color: RadarColors.ink,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.08,
  );

  static const title = TextStyle(
    color: RadarColors.ink,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.18,
  );

  static const sectionTitle = TextStyle(
    color: RadarColors.ink,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );

  static const body = TextStyle(
    color: RadarColors.ink,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const muted = TextStyle(
    color: RadarColors.mutedInk,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static const label = TextStyle(
    color: RadarColors.mutedInk,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}

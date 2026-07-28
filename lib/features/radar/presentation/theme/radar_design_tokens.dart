import 'package:flutter/material.dart';

abstract final class RadarBrandTokens {
  static const primary = Color(0xFF3B82F6);
  static const secondary = Color(0xFF6366F1);
  static const accent = Color(0xFFE91E63);
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF0F172A);
  static const textMuted = Color(0xFF475569);
}

abstract final class RadarSemanticTokens {
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF22C55E);
  static const information = Color(0xFF2563EB);
  static const border = Color(0xFFE2E8F0);
  static const disabled = Color(0xFFCBD5E1);
}

abstract final class RadarComponentTokens {
  static const primaryButtonBackground = RadarBrandTokens.primary;
  static const primaryButtonText = RadarBrandTokens.surface;

  static const loginBackground = RadarBrandTokens.background;
  static const loginCardBackground = RadarBrandTokens.surface;
  static const loginFieldBackground = Color(0xFFF8FAFF);
  static const loginFieldBorder = RadarSemanticTokens.border;
  static const loginText = RadarBrandTokens.text;
  static const loginTextMuted = RadarBrandTokens.textMuted;
  static const loginAccent = RadarBrandTokens.accent;

  static const cockpitBackground = RadarBrandTokens.background;
  static const cardBackground = RadarBrandTokens.surface;
  static const destructiveAction = RadarSemanticTokens.danger;
}

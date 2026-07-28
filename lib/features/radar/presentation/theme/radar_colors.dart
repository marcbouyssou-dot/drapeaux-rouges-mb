import 'package:flutter/material.dart';

import 'radar_design_tokens.dart';

abstract final class RadarColors {
  // Identity
  static const primary = RadarBrandTokens.primary;
  static const indigo = RadarBrandTokens.secondary;
  static const slate = Color(0xFF64748B);
  static const blueGrey = Color(0xFF94A3B8);
  static const neutralGrey = Color(0xFF9CA3AF);
  static const brandBackground = Color(0xFF032052);
  static const brandAccent = RadarBrandTokens.accent;
  static const brandAccentDark = Color(0xFFC2185B);
  static const textOnBrand = Color(0xFFFFFFFF);
  static const textMutedOnBrand = Color(0xFFA9C4E8);
  static const loginFieldSurface = RadarComponentTokens.loginFieldBackground;

  // Clinical
  static const clinicalSuccess = RadarSemanticTokens.success;
  static const clinicalWarning = RadarSemanticTokens.warning;
  static const clinicalDanger = RadarSemanticTokens.danger;
  static const clinicalAction = RadarSemanticTokens.information;

  // Neutrals
  static const background = RadarBrandTokens.background;
  static const surface = RadarBrandTokens.surface;
  static const border = RadarSemanticTokens.border;
  static const divider = Color(0xFFCBD5E1);
  static const textPrimary = RadarBrandTokens.text;
  static const textSecondary = RadarBrandTokens.textMuted;
  static const textMuted = Color(0xFF64748B);
  static const disabled = RadarSemanticTokens.disabled;

  // Backward-compatible aliases for the current Radar presentation widgets.
  static const surfaceMuted = Color(0xFFEFF6FF);
  static const ink = textPrimary;
  static const mutedInk = textMuted;
  static const primaryDark = clinicalAction;
  static const accent = primary;
  static const success = clinicalSuccess;
  static const successSoft = Color(0xFFDCFCE7);
  static const warningSoft = Color(0xFFFEF3C7);
}

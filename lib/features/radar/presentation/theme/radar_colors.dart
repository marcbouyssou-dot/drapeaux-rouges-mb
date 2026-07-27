import 'package:flutter/material.dart';

abstract final class RadarColors {
  // Identity
  static const primary = Color(0xFF3B82F6);
  static const indigo = Color(0xFF6366F1);
  static const slate = Color(0xFF64748B);
  static const blueGrey = Color(0xFF94A3B8);
  static const neutralGrey = Color(0xFF9CA3AF);
  static const brandBackground = Color(0xFF032052);
  static const brandAccent = Color(0xFFE91E63);
  static const brandAccentDark = Color(0xFFC2185B);
  static const textOnBrand = Color(0xFFFFFFFF);
  static const textMutedOnBrand = Color(0xFFA9C4E8);
  static const loginFieldSurface = Color(0xFFF8FAFF);

  // Clinical
  static const clinicalSuccess = Color(0xFF22C55E);
  static const clinicalWarning = Color(0xFFF59E0B);
  static const clinicalDanger = Color(0xFFEF4444);
  static const clinicalAction = Color(0xFF2563EB);

  // Neutrals
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFCBD5E1);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textMuted = Color(0xFF64748B);
  static const disabled = Color(0xFFCBD5E1);

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

import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_colors.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_radius.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_shadows.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_spacing.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_text_styles.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadarTheme RC1', () {
    test('exposes the main RC1 color tokens', () {
      expect(RadarColors.primary, const Color(0xFF3B82F6));
      expect(RadarColors.clinicalAction, const Color(0xFF2563EB));
      expect(RadarColors.clinicalSuccess, const Color(0xFF22C55E));
      expect(RadarColors.clinicalWarning, const Color(0xFFF59E0B));
      expect(RadarColors.clinicalDanger, const Color(0xFFEF4444));
      expect(RadarColors.background, const Color(0xFFF8FAFC));
      expect(RadarColors.textPrimary, const Color(0xFF0F172A));
    });

    test('exposes the RC1 spacing and radius scales', () {
      expect(RadarSpacing.md, 12);
      expect(RadarSpacing.cardGap, 20);
      expect(RadarSpacing.xxxl, 40);
      expect(RadarRadius.small, 12);
      expect(RadarRadius.card, 16);
      expect(RadarRadius.signature, 20);
      expect(RadarRadius.pill, 999);
    });

    test('exposes the RC1 typography scale', () {
      expect(RadarTextStyles.screenTitle.fontSize, 28);
      expect(RadarTextStyles.screenTitle.fontWeight, FontWeight.bold);
      expect(RadarTextStyles.sectionTitle.fontSize, 22);
      expect(RadarTextStyles.sectionTitle.fontWeight, FontWeight.w600);
      expect(RadarTextStyles.body.fontSize, 16);
      expect(RadarTextStyles.body.fontWeight, FontWeight.w400);
      expect(RadarTextStyles.contextTitle.fontSize, 14);
      expect(RadarTextStyles.contextTitle.fontWeight, FontWeight.w600);
      expect(RadarTextStyles.contextSecondary.fontSize, 13);
      expect(RadarTextStyles.contextSecondary.fontWeight, FontWeight.w400);
      expect(RadarTextStyles.badge.fontSize, 12);
      expect(RadarTextStyles.badge.fontWeight, FontWeight.w600);
    });

    test('builds a Material 3 light theme without clinical dependencies', () {
      final theme = RadarTheme.lightTheme;

      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, RadarColors.background);
      expect(theme.colorScheme.primary, RadarColors.primary);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.cardTheme.elevation, 0);
    });

    test('exposes the subtle RC1 presentation shadows', () {
      expect(RadarShadows.card.single.blurRadius, 20);
      expect(RadarShadows.card.single.offset, const Offset(0, 2));
      expect(RadarShadows.navigation.single.blurRadius, 24);
      expect(RadarShadows.navigation.single.offset, const Offset(0, 4));
    });
  });
}

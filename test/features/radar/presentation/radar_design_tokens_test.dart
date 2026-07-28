import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_colors.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/theme/radar_design_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy Radar colors retain their values through brand tokens', () {
    expect(RadarColors.primary, RadarBrandTokens.primary);
    expect(RadarColors.indigo, RadarBrandTokens.secondary);
    expect(RadarColors.brandAccent, RadarBrandTokens.accent);
    expect(RadarColors.background, RadarBrandTokens.background);
    expect(RadarColors.surface, RadarBrandTokens.surface);
    expect(RadarColors.textPrimary, RadarBrandTokens.text);
    expect(RadarColors.textSecondary, RadarBrandTokens.textMuted);
  });

  test('legacy clinical colors retain their semantic values', () {
    expect(RadarColors.clinicalDanger, RadarSemanticTokens.danger);
    expect(RadarColors.clinicalWarning, RadarSemanticTokens.warning);
    expect(RadarColors.clinicalSuccess, RadarSemanticTokens.success);
    expect(RadarColors.clinicalAction, RadarSemanticTokens.information);
    expect(RadarColors.border, RadarSemanticTokens.border);
    expect(RadarColors.disabled, RadarSemanticTokens.disabled);
  });

  test('component tokens derive from brand and semantic roles', () {
    expect(
      RadarComponentTokens.primaryButtonBackground,
      RadarBrandTokens.primary,
    );
    expect(RadarComponentTokens.primaryButtonText, RadarBrandTokens.surface);
    expect(RadarComponentTokens.loginBackground, RadarBrandTokens.background);
    expect(RadarComponentTokens.loginCardBackground, RadarBrandTokens.surface);
    expect(RadarComponentTokens.loginText, RadarBrandTokens.text);
    expect(RadarComponentTokens.loginTextMuted, RadarBrandTokens.textMuted);
    expect(RadarComponentTokens.loginAccent, RadarBrandTokens.accent);
    expect(RadarComponentTokens.destructiveAction, RadarSemanticTokens.danger);
  });

  test('legacy visual values remain unchanged', () {
    expect(RadarColors.primary.toARGB32(), 0xFF3B82F6);
    expect(RadarColors.indigo.toARGB32(), 0xFF6366F1);
    expect(RadarColors.brandAccent.toARGB32(), 0xFFE91E63);
    expect(RadarColors.background.toARGB32(), 0xFFF8FAFC);
    expect(RadarColors.surface.toARGB32(), 0xFFFFFFFF);
    expect(RadarColors.clinicalDanger.toARGB32(), 0xFFEF4444);
    expect(RadarColors.brandBackground.toARGB32(), 0xFF032052);
    expect(RadarColors.brandAccentDark.toARGB32(), 0xFFC2185B);
  });
}

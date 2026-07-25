import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarBottomActionBar extends StatelessWidget {
  const RadarBottomActionBar({
    super.key,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    this.secondaryLabel,
    this.secondaryIcon,
    this.onSecondaryPressed,
  });

  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final IconData? secondaryIcon;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final hasSecondary =
        secondaryLabel != null &&
        secondaryIcon != null &&
        onSecondaryPressed != null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          RadarSpacing.xl,
          RadarSpacing.md,
          RadarSpacing.xl,
          RadarSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: RadarColors.surface.withValues(alpha: 0.98),
          border: const Border(top: BorderSide(color: RadarColors.border)),
          boxShadow: RadarShadows.navigation,
        ),
        child: Row(
          children: [
            if (hasSecondary) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSecondaryPressed,
                  icon: Icon(secondaryIcon),
                  label: Text(secondaryLabel!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RadarColors.textPrimary,
                    side: const BorderSide(color: RadarColors.border),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RadarRadius.card),
                    ),
                    textStyle: RadarTextStyles.badge,
                  ),
                ),
              ),
              const SizedBox(width: RadarSpacing.md),
            ],
            Expanded(
              child: FilledButton.icon(
                onPressed: onPrimaryPressed,
                icon: Icon(primaryIcon),
                label: Text(primaryLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: RadarColors.primary,
                  foregroundColor: RadarColors.surface,
                  disabledBackgroundColor: RadarColors.disabled,
                  disabledForegroundColor: RadarColors.textMuted,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadarRadius.card),
                  ),
                  textStyle: RadarTextStyles.badge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

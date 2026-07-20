import 'package:flutter/material.dart';

import '../theme/radar_colors.dart';
import '../theme/radar_radius.dart';
import '../theme/radar_shadows.dart';
import '../theme/radar_spacing.dart';
import '../theme/radar_text_styles.dart';

class RadarBottomNavigationBar extends StatelessWidget {
  const RadarBottomNavigationBar({super.key, this.currentIndex = 0});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RadarColors.surface,
        borderRadius: BorderRadius.circular(RadarRadius.signature),
        boxShadow: RadarShadows.navigation,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RadarSpacing.lg,
          vertical: RadarSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: _RadarNavigationItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Accueil',
                selected: currentIndex == 0,
              ),
            ),
            Expanded(
              child: _RadarNavigationItem(
                icon: Icons.history_outlined,
                selectedIcon: Icons.history,
                label: 'Historique',
                selected: currentIndex == 1,
              ),
            ),
            Expanded(
              child: _RadarNavigationItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Réglages',
                selected: currentIndex == 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarNavigationItem extends StatelessWidget {
  const _RadarNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? RadarColors.primary : RadarColors.textMuted;
    final labelStyle =
        (selected ? RadarTextStyles.badge : RadarTextStyles.caption).copyWith(
          color: color,
        );

    return Semantics(
      selected: selected,
      button: true,
      child: SizedBox(
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: selected
                    ? RadarColors.primary.withValues(alpha: 0.1)
                    : RadarColors.surface,
                borderRadius: BorderRadius.circular(RadarRadius.small),
              ),
              child: SizedBox.square(
                dimension: 40,
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: RadarSpacing.xs),
            Text(label, style: labelStyle, maxLines: 1),
          ],
        ),
      ),
    );
  }
}

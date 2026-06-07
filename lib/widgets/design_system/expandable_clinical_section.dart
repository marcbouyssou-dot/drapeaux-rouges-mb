import 'package:flutter/material.dart';

import '../../theme/app_design_system.dart';

class ExpandableClinicalSection extends StatelessWidget {
  const ExpandableClinicalSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.children,
    this.initiallyExpanded = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 9 : 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.softShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 18,
            vertical: compact ? 2 : 8,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            compact ? 14 : 18,
            0,
            compact ? 14 : 18,
            compact ? 12 : 18,
          ),
          leading: Container(
            width: compact ? 40 : 48,
            height: compact ? 40 : 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: compact ? 22 : 26),
          ),
          title: Text(title, style: AppTextStyles.cardTitle),
          subtitle: compact
              ? null
              : Text(subtitle, style: AppTextStyles.cardSubtitle),
          children: children,
        ),
      ),
    );
  }
}

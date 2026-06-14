import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'clinical_reasoning_section_card.dart';

class ClinicalSummaryCard extends StatelessWidget {
  const ClinicalSummaryCard({super.key, required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return ClinicalReasoningSectionCard(
      title: 'Synthèse clinique',
      icon: Icons.insights_rounded,
      color: AppColors.primary,
      children: [
        Text(
          summary,
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/clinical/clinical_models.dart';
import '../../presentation/clinical_reasoning/clinical_reasoning_presenter.dart';
import '../../theme/app_colors.dart';
import 'clinical_reasoning_section_card.dart';

class ClinicalRecommendationsCard extends StatelessWidget {
  const ClinicalRecommendationsCard({
    super.key,
    required this.recommendations,
    this.presenter = const ClinicalReasoningPresenter(),
  });

  final List<ClinicalRecommendation> recommendations;
  final ClinicalReasoningPresenter presenter;

  @override
  Widget build(BuildContext context) {
    return ClinicalReasoningSectionCard(
      title: 'Recommandations',
      icon: Icons.fact_check_outlined,
      color: AppColors.primary,
      children: recommendations
          .map(
            (recommendation) => ClinicalReasoningTextItem(
              data: presenter.recommendation(recommendation),
            ),
          )
          .toList(growable: false),
    );
  }
}

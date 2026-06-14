import 'package:flutter/material.dart';

import '../../models/clinical/clinical_models.dart';
import '../../presentation/clinical_reasoning/clinical_reasoning_presenter.dart';
import '../../theme/app_colors.dart';
import 'clinical_reasoning_section_card.dart';

class ClinicalFindingsCard extends StatelessWidget {
  const ClinicalFindingsCard({
    super.key,
    required this.findings,
    this.presenter = const ClinicalReasoningPresenter(),
  });

  final List<ClinicalFinding> findings;
  final ClinicalReasoningPresenter presenter;

  @override
  Widget build(BuildContext context) {
    return ClinicalReasoningSectionCard(
      title: 'Éléments retenus',
      icon: Icons.checklist_rounded,
      color: AppColors.textSecondary,
      children: findings
          .map(
            (finding) =>
                ClinicalReasoningTextItem(data: presenter.finding(finding)),
          )
          .toList(growable: false),
    );
  }
}

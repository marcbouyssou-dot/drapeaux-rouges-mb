import 'package:flutter/material.dart';

import '../../models/clinical/clinical_models.dart';
import '../../presentation/clinical_reasoning/clinical_reasoning_presenter.dart';
import 'clinical_reasoning_section_card.dart';

class ClinicalAlertsCard extends StatelessWidget {
  const ClinicalAlertsCard({
    super.key,
    required this.alerts,
    required this.color,
    this.presenter = const ClinicalReasoningPresenter(),
  });

  final List<ClinicalAlert> alerts;
  final Color color;
  final ClinicalReasoningPresenter presenter;

  @override
  Widget build(BuildContext context) {
    return ClinicalReasoningSectionCard(
      title: 'Alertes cliniques',
      icon: Icons.notification_important_outlined,
      color: color,
      children: alerts
          .map(
            (alert) => ClinicalReasoningTextItem(data: presenter.alert(alert)),
          )
          .toList(growable: false),
    );
  }
}

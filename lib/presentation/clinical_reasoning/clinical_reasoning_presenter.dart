import 'package:flutter/material.dart';

import '../../models/clinical/clinical_models.dart';
import '../../theme/app_colors.dart';

class ClinicalReasoningPresenter {
  const ClinicalReasoningPresenter();

  ClinicalDisplayData alert(ClinicalAlert alert) {
    final color = alertLevelColor(alert.level);

    return ClinicalDisplayData(
      title: alert.title,
      body: alert.message,
      badgeLabel: alertLevelLabel(alert.level),
      badgeColor: color,
    );
  }

  ClinicalDisplayData recommendation(ClinicalRecommendation recommendation) {
    return ClinicalDisplayData(
      title: recommendation.title,
      body: recommendation.description,
      badgeLabel: recommendationPriorityLabel(recommendation.priority),
      badgeColor: recommendationPriorityColor(recommendation.priority),
    );
  }

  ClinicalDisplayData finding(ClinicalFinding finding) {
    return ClinicalDisplayData(
      title: finding.label,
      body:
          '${findingCategoryLabel(finding.category)} · ${severityLabel(finding.severity)}',
      badgeLabel: severityLabel(finding.severity),
      badgeColor: severityColor(finding.severity),
    );
  }

  Color alertLevelColor(ClinicalAlertLevel level) {
    switch (level) {
      case ClinicalAlertLevel.info:
        return AppColors.primary;
      case ClinicalAlertLevel.warning:
        return AppColors.warning;
      case ClinicalAlertLevel.urgent:
      case ClinicalAlertLevel.critical:
        return AppColors.danger;
    }
  }

  String alertLevelLabel(ClinicalAlertLevel level) {
    switch (level) {
      case ClinicalAlertLevel.info:
        return 'Info';
      case ClinicalAlertLevel.warning:
        return 'Vigilance';
      case ClinicalAlertLevel.urgent:
        return 'Urgent';
      case ClinicalAlertLevel.critical:
        return 'Critique';
    }
  }

  Color recommendationPriorityColor(ClinicalRecommendationPriority priority) {
    switch (priority) {
      case ClinicalRecommendationPriority.low:
        return AppColors.textSecondary;
      case ClinicalRecommendationPriority.medium:
        return AppColors.primary;
      case ClinicalRecommendationPriority.high:
        return AppColors.warning;
      case ClinicalRecommendationPriority.urgent:
        return AppColors.danger;
    }
  }

  String recommendationPriorityLabel(ClinicalRecommendationPriority priority) {
    switch (priority) {
      case ClinicalRecommendationPriority.low:
        return 'Faible';
      case ClinicalRecommendationPriority.medium:
        return 'Moyenne';
      case ClinicalRecommendationPriority.high:
        return 'Haute';
      case ClinicalRecommendationPriority.urgent:
        return 'Urgente';
    }
  }

  Color severityColor(ClinicalSeverity severity) {
    switch (severity) {
      case ClinicalSeverity.low:
        return AppColors.success;
      case ClinicalSeverity.moderate:
        return AppColors.warning;
      case ClinicalSeverity.high:
      case ClinicalSeverity.critical:
        return AppColors.danger;
      case ClinicalSeverity.unknown:
        return AppColors.textSecondary;
    }
  }

  String severityLabel(ClinicalSeverity severity) {
    switch (severity) {
      case ClinicalSeverity.low:
        return 'Faible';
      case ClinicalSeverity.moderate:
        return 'Modérée';
      case ClinicalSeverity.high:
        return 'Élevée';
      case ClinicalSeverity.critical:
        return 'Critique';
      case ClinicalSeverity.unknown:
        return 'Non précisée';
    }
  }

  String findingCategoryLabel(ClinicalFindingCategory category) {
    switch (category) {
      case ClinicalFindingCategory.general:
        return 'Général';
      case ClinicalFindingCategory.cardiovascular:
        return 'Cardiovasculaire';
      case ClinicalFindingCategory.respiratory:
        return 'Respiratoire';
      case ClinicalFindingCategory.neurological:
        return 'Neurologique';
      case ClinicalFindingCategory.infectious:
        return 'Infectieux';
      case ClinicalFindingCategory.mentalHealth:
        return 'Santé mentale';
      case ClinicalFindingCategory.musculoskeletal:
        return 'Musculosquelettique';
      case ClinicalFindingCategory.other:
        return 'Autre';
    }
  }
}

class ClinicalDisplayData {
  const ClinicalDisplayData({
    required this.title,
    required this.body,
    required this.badgeLabel,
    required this.badgeColor,
  });

  final String title;
  final String body;
  final String badgeLabel;
  final Color badgeColor;
}

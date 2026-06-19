import '../models/clinical_screening/clinical_screening_models.dart';

class ClinicalScreeningEngineV3 {
  const ClinicalScreeningEngineV3();

  ClinicalScreeningSession evaluate({
    required String sessionId,
    required String reason,
    required List<ClinicalFlag> flags,
    DateTime? createdAt,
    String? patientId,
  }) {
    final presentFlags = flags
        .where((flag) => flag.isPresent)
        .toList(growable: false);
    final score = _score(presentFlags);
    final decisionLevel = _decisionLevel(presentFlags, score);
    final action = _recommendedAction(decisionLevel, presentFlags);

    return ClinicalScreeningSession(
      id: sessionId,
      patientId: patientId,
      reason: reason,
      createdAt: createdAt ?? DateTime.now(),
      flags: List.unmodifiable(flags),
      decisionLevel: decisionLevel,
      recommendedAction: action,
      score: score,
    );
  }

  int _score(List<ClinicalFlag> flags) {
    return flags.fold<int>(0, (total, flag) => total + flag.weight);
  }

  ClinicalDecisionLevel _decisionLevel(List<ClinicalFlag> flags, int score) {
    if (flags.isEmpty) return ClinicalDecisionLevel.routine;

    if (_hasEmergencyPattern(flags)) {
      return ClinicalDecisionLevel.emergency;
    }

    final highestFlagLevel = flags
        .map((flag) => flag.level)
        .reduce((highest, level) => _maxLevel(highest, level));

    if (_levelRank(highestFlagLevel) >=
        _levelRank(ClinicalDecisionLevel.urgentReferral)) {
      return highestFlagLevel;
    }

    if (_hasVascularCluster(flags)) {
      return ClinicalDecisionLevel.urgentReferral;
    }

    if (score >= 6) return ClinicalDecisionLevel.urgentReferral;
    if (score >= 4) return ClinicalDecisionLevel.medicalAdvice;
    if (score >= 2) return ClinicalDecisionLevel.monitor;

    return highestFlagLevel;
  }

  ClinicalRecommendedAction _recommendedAction(
    ClinicalDecisionLevel level,
    List<ClinicalFlag> flags,
  ) {
    final relatedFlagIds = flags.map((flag) => flag.id).toList(growable: false);

    switch (level) {
      case ClinicalDecisionLevel.emergency:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Orientation urgente immédiate',
          message:
              'Présence de signes critiques. Contacter sans délai le 15, le 112 ou le service d’urgence adapté.',
          requiresMedicalContact: true,
          requiresEmergencyCall: true,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.urgentReferral:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Orientation médicale urgente',
          message:
              'Un avis médical urgent est recommandé avant toute poursuite de prise en charge non médicale.',
          requiresMedicalContact: true,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.medicalAdvice:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Avis médical rapide',
          message:
              'Des signes significatifs justifient un avis médical rapide et une réévaluation clinique.',
          requiresMedicalContact: true,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.monitor:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Surveillance renforcée',
          message:
              'La prise en charge peut être envisagée avec surveillance clinique rapprochée et consignes de réévaluation.',
          requiresMedicalContact: false,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.routine:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Prise en charge habituelle',
          message:
              'Aucun signe d’alerte majeur n’est identifié dans cette session de dépistage.',
          requiresMedicalContact: false,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
    }
  }

  bool _hasEmergencyPattern(List<ClinicalFlag> flags) {
    return flags.any((flag) {
      final tags = flag.tags.map((tag) => tag.toLowerCase()).toSet();

      return flag.level == ClinicalDecisionLevel.emergency ||
          tags.contains('urgence_vitale') ||
          tags.contains('embolie_pulmonaire') ||
          tags.contains('queue_cheval') ||
          tags.contains('fracture_ouverte') ||
          tags.contains('douleur_thoracique_critique');
    });
  }

  bool _hasVascularCluster(List<ClinicalFlag> flags) {
    final vascularFlags = flags.where((flag) {
      final tags = flag.tags.map((tag) => tag.toLowerCase()).toSet();

      return flag.category == ClinicalFlagCategory.vascular ||
          tags.contains('wells_tvp') ||
          tags.contains('neurovasculaire_cervical');
    }).length;

    return vascularFlags >= 2;
  }

  ClinicalDecisionLevel _maxLevel(
    ClinicalDecisionLevel first,
    ClinicalDecisionLevel second,
  ) {
    return _levelRank(first) >= _levelRank(second) ? first : second;
  }

  int _levelRank(ClinicalDecisionLevel level) {
    switch (level) {
      case ClinicalDecisionLevel.routine:
        return 0;
      case ClinicalDecisionLevel.monitor:
        return 1;
      case ClinicalDecisionLevel.medicalAdvice:
        return 2;
      case ClinicalDecisionLevel.urgentReferral:
        return 3;
      case ClinicalDecisionLevel.emergency:
        return 4;
    }
  }
}

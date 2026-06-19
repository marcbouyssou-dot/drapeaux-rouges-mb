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

    final immediateDangerLevel = _immediateDangerLevel(flags);
    if (immediateDangerLevel != null) {
      return immediateDangerLevel;
    }

    final systemicClusterLevel = _systemicClusterLevel(flags);
    if (systemicClusterLevel != null) {
      return systemicClusterLevel;
    }

    if (_hasOnlyYellowFlags(flags)) {
      return ClinicalDecisionLevel.monitor;
    }

    final highestFlagLevel = _highestFlagLevel(flags);
    if (_levelRank(highestFlagLevel) >=
        _levelRank(ClinicalDecisionLevel.urgentReferral)) {
      return highestFlagLevel;
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
          title: 'Urgence immédiate',
          message:
              'Présence de signes critiques. Appeler le 15, le 112 ou orienter immédiatement vers le service d’urgence adapté.',
          requiresMedicalContact: true,
          requiresEmergencyCall: true,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.urgentReferral:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Avis médical impératif rapide',
          message:
              'Un avis médical impératif et rapide est requis avant toute poursuite de prise en charge non médicale.',
          requiresMedicalContact: true,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.medicalAdvice:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Avis médical recommandé',
          message:
              'Des signes cliniques significatifs justifient un avis médical recommandé et une réévaluation adaptée.',
          requiresMedicalContact: true,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.monitor:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Surveillance renforcée',
          message:
              'La prise en charge peut être envisagée avec surveillance renforcée et consignes de réévaluation.',
          requiresMedicalContact: false,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
      case ClinicalDecisionLevel.routine:
        return ClinicalRecommendedAction(
          level: level,
          title: 'Prise en charge habituelle',
          message:
              'Aucun signe d’alerte majeur n’est identifié. La prise en charge habituelle peut être envisagée.',
          requiresMedicalContact: false,
          requiresEmergencyCall: false,
          relatedFlagIds: relatedFlagIds,
        );
    }
  }

  ClinicalDecisionLevel? _immediateDangerLevel(List<ClinicalFlag> flags) {
    final immediateDangerFlags = flags
        .where(
          (flag) =>
              flag.layer == ClinicalScreeningLayer.immediateDanger ||
              flag.level == ClinicalDecisionLevel.emergency ||
              _hasCriticalTag(flag),
        )
        .toList(growable: false);

    if (immediateDangerFlags.isEmpty) return null;

    final highestLevel = _highestFlagLevel(immediateDangerFlags);
    if (highestLevel == ClinicalDecisionLevel.emergency) {
      return ClinicalDecisionLevel.emergency;
    }

    return ClinicalDecisionLevel.urgentReferral;
  }

  ClinicalDecisionLevel? _systemicClusterLevel(List<ClinicalFlag> flags) {
    if (_hasCardiorespiratoryCluster(flags)) {
      return ClinicalDecisionLevel.emergency;
    }

    if (_hasOncologicCluster(flags) ||
        _hasInfectiousCluster(flags) ||
        _hasNeurologicCluster(flags) ||
        _hasFractureRiskCluster(flags) ||
        _hasVascularCluster(flags)) {
      return ClinicalDecisionLevel.urgentReferral;
    }

    if (_hasSingleSystemicConcern(flags)) {
      return ClinicalDecisionLevel.medicalAdvice;
    }

    return null;
  }

  bool _hasOncologicCluster(List<ClinicalFlag> flags) {
    return _hasAnyTag(flags, const ['cancer', 'neoplasie', 'oncologic']) &&
        _hasAnyTag(flags, const [
          'perte_poids',
          'douleur_nocturne',
          'alteration_etat_general',
        ]);
  }

  bool _hasInfectiousCluster(List<ClinicalFlag> flags) {
    final systemicInfection = _hasAnyTag(flags, const [
      'fievre',
      'fièvre',
      'frissons',
      'sueurs_nocturnes',
    ]);
    final fragileContext = _hasAnyTag(flags, const [
      'immunodepression',
      'immunodépression',
      'infection_recente',
      'infection_récente',
    ]);

    return systemicInfection && fragileContext;
  }

  bool _hasNeurologicCluster(List<ClinicalFlag> flags) {
    return _hasAnyTag(flags, const [
      'deficit_moteur_progressif',
      'déficit_moteur_progressif',
      'signes_neurologiques_centraux',
    ]);
  }

  bool _hasCardiorespiratoryCluster(List<ClinicalFlag> flags) {
    final chestPain = _hasAnyTag(flags, const [
      'douleur_thoracique',
      'douleur_thoracique_critique',
    ]);
    final respiratoryOrMalaise = _hasAnyTag(flags, const [
      'dyspnee',
      'dyspnée',
      'malaise',
      'syncope',
    ]);

    return chestPain && respiratoryOrMalaise;
  }

  bool _hasFractureRiskCluster(List<ClinicalFlag> flags) {
    final trauma = _hasAnyTag(flags, const ['traumatisme', 'chute']);
    final fragility = _hasAnyTag(flags, const [
      'osteoporose',
      'ostéoporose',
      'corticotherapie_prolongee',
      'corticothérapie_prolongée',
      'age_avance',
      'âge_avancé',
    ]);

    return trauma && fragility;
  }

  bool _hasVascularCluster(List<ClinicalFlag> flags) {
    final vascularFlags = flags.where(_isVascularConcern).length;

    return vascularFlags >= 2;
  }

  bool _hasSingleSystemicConcern(List<ClinicalFlag> flags) {
    return flags.any((flag) {
      return flag.layer == ClinicalScreeningLayer.systemic ||
          _hasAnyTagInFlag(flag, const [
            'cancer',
            'neoplasie',
            'oncologic',
            'fievre',
            'fièvre',
            'immunodepression',
            'immunodépression',
          ]);
    });
  }

  bool _hasOnlyYellowFlags(List<ClinicalFlag> flags) {
    return flags.every(
      (flag) => flag.layer == ClinicalScreeningLayer.yellowFlag,
    );
  }

  ClinicalDecisionLevel _highestFlagLevel(List<ClinicalFlag> flags) {
    return flags
        .map((flag) => flag.level)
        .reduce((highest, level) => _maxLevel(highest, level));
  }

  bool _hasCriticalTag(ClinicalFlag flag) {
    return _hasAnyTagInFlag(flag, const [
      'urgence_vitale',
      'embolie_pulmonaire',
      'queue_cheval',
      'fracture_ouverte',
      'douleur_thoracique_critique',
    ]);
  }

  bool _isVascularConcern(ClinicalFlag flag) {
    return flag.category == ClinicalFlagCategory.vascular ||
        _hasAnyTagInFlag(flag, const [
          'wells_tvp',
          'tvp',
          'neurovasculaire_cervical',
          'vasculaire',
        ]);
  }

  bool _hasAnyTag(List<ClinicalFlag> flags, List<String> searchedTags) {
    return flags.any((flag) => _hasAnyTagInFlag(flag, searchedTags));
  }

  bool _hasAnyTagInFlag(ClinicalFlag flag, List<String> searchedTags) {
    final tags = flag.tags.map((tag) => tag.toLowerCase()).toSet();

    return searchedTags.any((searchedTag) {
      return tags.contains(searchedTag.toLowerCase());
    });
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

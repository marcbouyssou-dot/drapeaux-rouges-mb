import '../models/clinical_screening/clinical_screening_models.dart';
import '../models/clinical_screening/clinical_screening_rule_version.dart';
import '../models/clinical_screening/clinical_screening_tags.dart';

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
    final decision = _decisionTrace(presentFlags, score);
    final action = _recommendedAction(decision.level, presentFlags);

    return ClinicalScreeningSession(
      id: sessionId,
      patientId: patientId,
      reason: reason,
      createdAt: createdAt ?? DateTime.now(),
      flags: flags,
      decisionLevel: decision.level,
      recommendedAction: action,
      score: score,
      traces: [decision.trace],
      engineName: ClinicalScreeningRuleVersion.engineName,
      engineVersion: ClinicalScreeningRuleVersion.engineVersion,
      rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
      rulesetDate: ClinicalScreeningRuleVersion.rulesetDate,
      clinicalStatus: ClinicalScreeningRuleVersion.clinicalStatus,
    );
  }

  int _score(List<ClinicalFlag> flags) {
    return flags.fold<int>(0, (total, flag) => total + flag.weight);
  }

  _DecisionTrace _decisionTrace(List<ClinicalFlag> flags, int score) {
    if (flags.isEmpty) {
      return _DecisionTrace(
        level: ClinicalDecisionLevel.routine,
        trace: ClinicalReasoningTrace(
          ruleId: 'routine',
          rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
          title: 'Aucun flag présent',
          layer: ClinicalScreeningLayer.regional,
          decisionLevel: ClinicalDecisionLevel.routine,
          causalFlagIds: const [],
          explanation:
              'Aucun élément clinique présent n’a été retenu dans cette session de dépistage.',
        ),
      );
    }

    final immediateDangerDecision = _immediateDangerDecision(flags);
    if (immediateDangerDecision != null) {
      return immediateDangerDecision;
    }

    final systemicClusterDecision = _systemicClusterDecision(flags);
    if (systemicClusterDecision != null) {
      return systemicClusterDecision;
    }

    if (_hasOnlyYellowFlags(flags)) {
      return _DecisionTrace(
        level: ClinicalDecisionLevel.monitor,
        trace: ClinicalReasoningTrace(
          ruleId: 'yellowFlagsOnly',
          rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
          title: 'Drapeaux jaunes isolés',
          layer: ClinicalScreeningLayer.yellowFlag,
          decisionLevel: ClinicalDecisionLevel.monitor,
          causalFlagIds: _flagIds(flags),
          explanation:
              'Les éléments présents relèvent uniquement de facteurs psychosociaux ou contextuels et justifient une surveillance renforcée sans orientation médicale urgente isolée.',
        ),
      );
    }

    final highestFlagLevel = _highestFlagLevel(flags);
    if (_levelRank(highestFlagLevel) >=
        _levelRank(ClinicalDecisionLevel.urgentReferral)) {
      final causalFlags = flags
          .where((flag) => flag.level == highestFlagLevel)
          .toList(growable: false);
      return _DecisionTrace(
        level: highestFlagLevel,
        trace: ClinicalReasoningTrace(
          ruleId: 'highestFlagLevel',
          rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
          title: 'Niveau intrinsèque de flag',
          layer: causalFlags.first.layer,
          decisionLevel: highestFlagLevel,
          causalFlagIds: _flagIds(causalFlags),
          explanation:
              'Le niveau clinique porté par un ou plusieurs flags impose directement le niveau de décision retenu.',
        ),
      );
    }

    final scoreLevel = _scoreDecisionLevel(score);
    if (scoreLevel != null) {
      return _DecisionTrace(
        level: scoreLevel,
        trace: ClinicalReasoningTrace(
          ruleId: 'scoreEscalation',
          rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
          title: 'Escalade par score',
          layer: ClinicalScreeningLayer.regional,
          decisionLevel: scoreLevel,
          causalFlagIds: _flagIds(flags),
          explanation:
              'L’accumulation de plusieurs éléments cliniques présents atteint le seuil de score associé au niveau de vigilance retenu.',
        ),
      );
    }

    final causalFlags = flags
        .where((flag) => flag.level == highestFlagLevel)
        .toList(growable: false);
    return _DecisionTrace(
      level: highestFlagLevel,
      trace: ClinicalReasoningTrace(
        ruleId: 'highestFlagLevel',
        rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
        title: 'Niveau intrinsèque de flag',
        layer: causalFlags.first.layer,
        decisionLevel: highestFlagLevel,
        causalFlagIds: _flagIds(causalFlags),
        explanation:
            'Le niveau clinique du flag présent le plus significatif est retenu en l’absence de cluster ou de seuil de score supérieur.',
      ),
    );
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

  _DecisionTrace? _immediateDangerDecision(List<ClinicalFlag> flags) {
    final immediateDangerFlags = flags
        .where(
          (flag) =>
              flag.layer == ClinicalScreeningLayer.immediateDanger ||
              flag.level == ClinicalDecisionLevel.emergency ||
              _hasCriticalTag(flag),
        )
        .toList(growable: false);

    if (immediateDangerFlags.isEmpty) return null;

    final hasCriticalEmergencyTag = immediateDangerFlags.any(_hasCriticalTag);
    final highestLevel = _highestFlagLevel(immediateDangerFlags);
    final level =
        hasCriticalEmergencyTag ||
            highestLevel == ClinicalDecisionLevel.emergency
        ? ClinicalDecisionLevel.emergency
        : ClinicalDecisionLevel.urgentReferral;

    return _DecisionTrace(
      level: level,
      trace: ClinicalReasoningTrace(
        ruleId: 'immediateDanger',
        rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
        title: 'Danger immédiat',
        layer: ClinicalScreeningLayer.immediateDanger,
        decisionLevel: level,
        causalFlagIds: _flagIds(immediateDangerFlags),
        explanation:
            'Un ou plusieurs éléments relèvent d’un danger immédiat ou d’un tag critique et imposent une orientation prioritaire.',
      ),
    );
  }

  _DecisionTrace? _systemicClusterDecision(List<ClinicalFlag> flags) {
    final cardiorespiratoryFlags = _cardiorespiratoryClusterFlags(flags);
    if (cardiorespiratoryFlags != null) {
      return _clusterDecision(
        ruleId: 'cardiorespiratoryCluster',
        title: 'Cluster cardio-respiratoire',
        level: ClinicalDecisionLevel.emergency,
        causalFlags: cardiorespiratoryFlags,
        explanation:
            'L’association douleur thoracique et dyspnée, malaise ou syncope impose une prise en charge urgente.',
      );
    }

    final oncologicFlags = _oncologicClusterFlags(flags);
    if (oncologicFlags != null) {
      return _clusterDecision(
        ruleId: 'oncologicCluster',
        title: 'Cluster oncologique',
        level: ClinicalDecisionLevel.urgentReferral,
        causalFlags: oncologicFlags,
        explanation:
            'L’association d’un contexte oncologique et de signes généraux ou nocturnes ne permet pas d’exclure une pathologie sous-jacente sérieuse.',
      );
    }

    final infectiousFlags = _infectiousClusterFlags(flags);
    if (infectiousFlags != null) {
      return _clusterDecision(
        ruleId: 'infectiousCluster',
        title: 'Cluster infectieux',
        level: ClinicalDecisionLevel.urgentReferral,
        causalFlags: infectiousFlags,
        explanation:
            'L’association de signes infectieux et d’un contexte de fragilité ou d’infection récente justifie un avis médical impératif rapide.',
      );
    }

    final neurologicFlags = _neurologicClusterFlags(flags);
    if (neurologicFlags != null) {
      return _clusterDecision(
        ruleId: 'neurologicCluster',
        title: 'Cluster neurologique',
        level: ClinicalDecisionLevel.urgentReferral,
        causalFlags: neurologicFlags,
        explanation:
            'La présence de signes neurologiques significatifs impose une évaluation médicale rapide.',
      );
    }

    final fractureRiskFlags = _fractureRiskClusterFlags(flags);
    if (fractureRiskFlags != null) {
      return _clusterDecision(
        ruleId: 'fractureRiskCluster',
        title: 'Cluster risque fracturaire',
        level: ClinicalDecisionLevel.urgentReferral,
        causalFlags: fractureRiskFlags,
        explanation:
            'L’association d’un traumatisme et d’un facteur de fragilité osseuse augmente le risque de lésion sérieuse.',
      );
    }

    final vascularFlags = _vascularClusterFlags(flags);
    if (vascularFlags != null) {
      return _clusterDecision(
        ruleId: 'vascularCluster',
        title: 'Cluster vasculaire',
        level: ClinicalDecisionLevel.urgentReferral,
        causalFlags: vascularFlags,
        explanation:
            'La répétition d’éléments vasculaires impose un avis médical impératif rapide.',
      );
    }

    if (_hasSingleSystemicConcern(flags)) {
      final causalFlags = flags
          .where(
            (flag) =>
                flag.layer == ClinicalScreeningLayer.systemic ||
                _hasAnyTagInFlag(
                  flag,
                  ClinicalScreeningTags.isolatedSystemicConcern,
                ),
          )
          .toList(growable: false);
      return _DecisionTrace(
        level: ClinicalDecisionLevel.medicalAdvice,
        trace: ClinicalReasoningTrace(
          ruleId: 'systemicConcern',
          rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
          title: 'Signe systémique isolé',
          layer: ClinicalScreeningLayer.systemic,
          decisionLevel: ClinicalDecisionLevel.medicalAdvice,
          causalFlagIds: _flagIds(causalFlags),
          explanation:
              'Un élément systémique isolé justifie un avis médical recommandé, sans cluster d’urgence identifié.',
        ),
      );
    }

    return null;
  }

  _DecisionTrace _clusterDecision({
    required String ruleId,
    required String title,
    required ClinicalDecisionLevel level,
    required List<ClinicalFlag> causalFlags,
    required String explanation,
  }) {
    return _DecisionTrace(
      level: level,
      trace: ClinicalReasoningTrace(
        ruleId: ruleId,
        rulesetVersion: ClinicalScreeningRuleVersion.rulesetVersion,
        title: title,
        layer: ClinicalScreeningLayer.systemic,
        decisionLevel: level,
        causalFlagIds: _flagIds(causalFlags),
        explanation: explanation,
      ),
    );
  }

  List<ClinicalFlag>? _oncologicClusterFlags(List<ClinicalFlag> flags) {
    final cancerFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.oncologicContext,
    );
    final associatedFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.oncologicAssociated,
    );

    if (cancerFlags.isEmpty || associatedFlags.isEmpty) return null;

    return _uniqueFlags([...cancerFlags, ...associatedFlags]);
  }

  List<ClinicalFlag>? _infectiousClusterFlags(List<ClinicalFlag> flags) {
    final systemicInfectionFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.infectiousSystemic,
    );
    final fragileContextFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.infectiousFragility,
    );

    if (systemicInfectionFlags.isEmpty || fragileContextFlags.isEmpty) {
      return null;
    }

    return _uniqueFlags([...systemicInfectionFlags, ...fragileContextFlags]);
  }

  List<ClinicalFlag>? _neurologicClusterFlags(List<ClinicalFlag> flags) {
    final neurologicFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.neurologicCluster,
    );

    return neurologicFlags.isEmpty ? null : neurologicFlags;
  }

  List<ClinicalFlag>? _cardiorespiratoryClusterFlags(List<ClinicalFlag> flags) {
    final chestPainFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.chestPain,
    );
    final respiratoryOrMalaiseFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.respiratoryOrMalaise,
    );

    if (chestPainFlags.isEmpty || respiratoryOrMalaiseFlags.isEmpty) {
      return null;
    }

    return _uniqueFlags([...chestPainFlags, ...respiratoryOrMalaiseFlags]);
  }

  List<ClinicalFlag>? _fractureRiskClusterFlags(List<ClinicalFlag> flags) {
    final traumaFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.fractureTrauma,
    );
    final fragilityFlags = _flagsWithAnyTag(
      flags,
      ClinicalScreeningTags.fractureFragility,
    );

    if (traumaFlags.isEmpty || fragilityFlags.isEmpty) return null;

    return _uniqueFlags([...traumaFlags, ...fragilityFlags]);
  }

  List<ClinicalFlag>? _vascularClusterFlags(List<ClinicalFlag> flags) {
    final vascularFlags = flags.where(_isVascularConcern).toList();

    return vascularFlags.length >= 2 ? vascularFlags : null;
  }

  bool _hasSingleSystemicConcern(List<ClinicalFlag> flags) {
    return flags.any((flag) {
      return flag.layer == ClinicalScreeningLayer.systemic ||
          _hasAnyTagInFlag(flag, ClinicalScreeningTags.isolatedSystemicConcern);
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
    return _hasAnyTagInFlag(flag, ClinicalScreeningTags.criticalEmergency);
  }

  bool _isVascularConcern(ClinicalFlag flag) {
    return flag.category == ClinicalFlagCategory.vascular ||
        _hasAnyTagInFlag(flag, ClinicalScreeningTags.vascularConcern);
  }

  bool _hasAnyTag(List<ClinicalFlag> flags, List<String> searchedTags) {
    return flags.any((flag) => _hasAnyTagInFlag(flag, searchedTags));
  }

  List<ClinicalFlag> _flagsWithAnyTag(
    List<ClinicalFlag> flags,
    List<String> searchedTags,
  ) {
    return flags
        .where((flag) => _hasAnyTagInFlag(flag, searchedTags))
        .toList(growable: false);
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

  ClinicalDecisionLevel? _scoreDecisionLevel(int score) {
    if (score >= 6) return ClinicalDecisionLevel.urgentReferral;
    if (score >= 4) return ClinicalDecisionLevel.medicalAdvice;
    if (score >= 2) return ClinicalDecisionLevel.monitor;

    return null;
  }

  List<String> _flagIds(List<ClinicalFlag> flags) {
    return flags.map((flag) => flag.id).toList(growable: false);
  }

  List<ClinicalFlag> _uniqueFlags(List<ClinicalFlag> flags) {
    final byId = <String, ClinicalFlag>{};
    for (final flag in flags) {
      byId.putIfAbsent(flag.id, () => flag);
    }

    return byId.values.toList(growable: false);
  }
}

class _DecisionTrace {
  final ClinicalDecisionLevel level;
  final ClinicalReasoningTrace trace;

  const _DecisionTrace({required this.level, required this.trace});
}

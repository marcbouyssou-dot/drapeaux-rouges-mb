import '../models/clinical_screening/clinical_adaptive_session_v5.dart';
import '../models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import '../models/clinical_screening/clinical_hard_stop_catalog_v5.dart';
import '../models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import '../models/clinical_screening/clinical_hypothesis_catalog_v5.dart';
import '../models/clinical_screening/clinical_hypothesis_v5.dart';
import '../models/clinical_screening/clinical_probability_update_v5.dart';
import '../models/clinical_screening/clinical_screening_models.dart';
import '../models/clinical_screening/clinical_screening_questionnaire_v4.dart';

class ClinicalAdaptiveViewStateMapperV5 {
  ClinicalAdaptiveViewStateV5 map({
    required String sessionId,
    required ClinicalAdaptiveSessionV5 session,
  }) {
    final totalQuestionCount =
        ClinicalScreeningQuestionnaireV4.questions.length;
    final answeredCount = session.answeredQuestionIds.length;
    final hardStop = _primaryHardStop(session.triggeredHardStopIds);
    final primaryHypothesis = _dominantStrengthenedHypothesis(
      session.hypothesisProbabilities,
    );
    final currentRiskLevel = _currentRiskLevel(hardStop, primaryHypothesis);
    final isFinal = hardStop != null || session.nextQuestion == null;
    final finalDecisionLevel = isFinal ? currentRiskLevel : null;

    return ClinicalAdaptiveViewStateV5(
      sessionId: sessionId,
      questionId: session.nextQuestion?.id,
      patientQuestionText: session.nextQuestion?.text,
      canAnswer: !isFinal,
      answeredCount: answeredCount,
      totalQuestionCount: totalQuestionCount,
      progressRatio: _boundedProgress(answeredCount, totalQuestionCount),
      progressLabel: _progressLabel(
        answeredCount: answeredCount,
        totalQuestionCount: totalQuestionCount,
        hasHardStop: hardStop != null,
        isFinal: isFinal,
      ),
      currentRiskLevel: currentRiskLevel,
      currentRiskLabel: _riskLabel(currentRiskLevel),
      hardStopId: hardStop?.id,
      hardStopTitle: hardStop?.title,
      finalDecisionLevel: finalDecisionLevel,
      finalDecisionLabel: finalDecisionLevel == null
          ? null
          : _riskLabel(finalDecisionLevel),
      primaryHypothesisId: primaryHypothesis?.hypothesis.id,
      primaryHypothesisTitle: primaryHypothesis?.hypothesis.title,
      probabilityLevel: primaryHypothesis?.probability,
      shortExplanation: _shortExplanation(
        hardStop: hardStop,
        riskLevel: currentRiskLevel,
        isFinal: isFinal,
      ),
      technicalSummary: session.reasoningSummary,
      isFinal: isFinal,
    );
  }

  ClinicalHardStopRuleV5? _primaryHardStop(List<String> hardStopIds) {
    ClinicalHardStopRuleV5? selected;

    for (final hardStopId in hardStopIds) {
      final hardStop = _hardStopById(hardStopId);
      if (hardStop == null) {
        continue;
      }

      if (selected == null ||
          _decisionRank(hardStop.expectedDecisionLevel) >
              _decisionRank(selected.expectedDecisionLevel)) {
        selected = hardStop;
      }
    }

    return selected;
  }

  _DominantHypothesis? _dominantStrengthenedHypothesis(
    Map<String, ClinicalQualitativeProbabilityV5> probabilities,
  ) {
    _DominantHypothesis? selected;

    for (final hypothesis in ClinicalHypothesisCatalogV5.hypotheses) {
      final probability = probabilities[hypothesis.id];
      if (probability == null || !_isStrengthened(probability)) {
        continue;
      }

      if (selected == null ||
          _probabilityRank(probability) >
              _probabilityRank(selected.probability)) {
        selected = _DominantHypothesis(hypothesis, probability);
      }
    }

    return selected;
  }

  ClinicalDecisionLevel _currentRiskLevel(
    ClinicalHardStopRuleV5? hardStop,
    _DominantHypothesis? primaryHypothesis,
  ) {
    if (hardStop != null) {
      return hardStop.expectedDecisionLevel;
    }

    if (primaryHypothesis != null) {
      return primaryHypothesis.hypothesis.targetDecisionLevel;
    }

    return ClinicalDecisionLevel.routine;
  }

  String _shortExplanation({
    required ClinicalHardStopRuleV5? hardStop,
    required ClinicalDecisionLevel riskLevel,
    required bool isFinal,
  }) {
    if (hardStop != null) {
      return 'Un élément d’urgence potentielle a été identifié. Le questionnaire doit être interrompu et la conduite adaptée doit être suivie.';
    }

    switch (riskLevel) {
      case ClinicalDecisionLevel.emergency:
        return 'Un élément d’urgence potentielle a été identifié. Une conduite immédiate est nécessaire.';
      case ClinicalDecisionLevel.urgentReferral:
        return 'Certains éléments justifient un avis médical rapide avant une prise en charge exclusive.';
      case ClinicalDecisionLevel.medicalAdvice:
        return 'Certains éléments justifient un avis médical avant de poursuivre.';
      case ClinicalDecisionLevel.monitor:
        return 'La situation justifie une surveillance renforcée et une réévaluation si elle évolue.';
      case ClinicalDecisionLevel.routine:
        if (isFinal) {
          return 'Aucun signal d’alerte prioritaire n’a été retrouvé dans ce questionnaire. La décision finale reste sous la responsabilité du professionnel.';
        }

        return 'Le questionnaire est en cours. Répondez à la question affichée pour poursuivre.';
    }
  }

  String _riskLabel(ClinicalDecisionLevel level) {
    switch (level) {
      case ClinicalDecisionLevel.routine:
        return 'Prise en charge habituelle';
      case ClinicalDecisionLevel.monitor:
        return 'Surveillance renforcée';
      case ClinicalDecisionLevel.medicalAdvice:
        return 'Avis médical recommandé';
      case ClinicalDecisionLevel.urgentReferral:
        return 'Avis médical rapide nécessaire';
      case ClinicalDecisionLevel.emergency:
        return 'Urgence immédiate';
    }
  }

  double _boundedProgress(int answeredCount, int totalQuestionCount) {
    if (totalQuestionCount <= 0) {
      return 0;
    }

    final ratio = answeredCount / totalQuestionCount;
    if (ratio < 0) {
      return 0;
    }
    if (ratio > 1) {
      return 1;
    }

    return ratio;
  }

  String _progressLabel({
    required int answeredCount,
    required int totalQuestionCount,
    required bool hasHardStop,
    required bool isFinal,
  }) {
    if (hasHardStop) {
      return 'Questionnaire interrompu';
    }

    if (isFinal) {
      return 'Questionnaire terminé';
    }

    final currentQuestionNumber = (answeredCount + 1).clamp(
      1,
      totalQuestionCount,
    );
    return 'Question $currentQuestionNumber sur $totalQuestionCount';
  }

  ClinicalHardStopRuleV5? _hardStopById(String hardStopId) {
    for (final hardStop in ClinicalHardStopCatalogV5.rules) {
      if (hardStop.id == hardStopId) {
        return hardStop;
      }
    }

    return null;
  }

  bool _isStrengthened(ClinicalQualitativeProbabilityV5 probability) {
    return probability == ClinicalQualitativeProbabilityV5.high ||
        probability == ClinicalQualitativeProbabilityV5.veryHigh;
  }

  int _probabilityRank(ClinicalQualitativeProbabilityV5 probability) {
    return ClinicalQualitativeProbabilityV5.values.indexOf(probability);
  }

  int _decisionRank(ClinicalDecisionLevel level) {
    return ClinicalDecisionLevel.values.indexOf(level);
  }
}

class _DominantHypothesis {
  final ClinicalHypothesisV5 hypothesis;
  final ClinicalQualitativeProbabilityV5 probability;

  const _DominantHypothesis(this.hypothesis, this.probability);
}

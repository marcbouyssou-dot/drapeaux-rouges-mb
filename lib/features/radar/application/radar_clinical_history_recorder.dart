import 'package:hive/hive.dart';

import '../../../models/evaluation_model.dart';
import '../../../models/clinical_screening/clinical_screening_models.dart';
import '../../../services/history_service.dart';
import '../../../services/rgpd_local_service.dart';
import '../../../services/secure_hive_service.dart';
import 'radar_clinical_hard_stop_view_state.dart';
import 'radar_clinical_region.dart';
import 'radar_clinical_summary_view_state.dart';
import 'radar_clinical_view_state.dart';

class RadarClinicalHistoryRecorder {
  const RadarClinicalHistoryRecorder({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  Future<void> saveCompletedEvaluation(RadarClinicalViewState state) async {
    if (state.destination != RadarClinicalDestination.summary &&
        state.destination != RadarClinicalDestination.hardStop) {
      return;
    }
    if (!Hive.isBoxOpen(SecureHiveService.evaluationsBoxName)) {
      return;
    }

    final evaluation = await buildEvaluation(state);
    final data = evaluation.toJson()
      ..['source'] = 'radar'
      ..['radarSessionId'] = state.sessionId
      ..['radarRegion'] = state.region.name
      ..['radarStatus'] = state.status.name
      ..['radarMatrixVersion'] = state.summary?.matrixVersion
      ..['radarValidationStatus'] = state.summary?.validationStatus
      ..['radarEngineVersion'] = state.summary?.engineVersion;

    await HistoryService.saveEvaluation(history: const [], evaluation: data);
  }

  Future<EvaluationModel> buildEvaluation(RadarClinicalViewState state) async {
    final patient = await RgpdLocalService.getCurrentPatient();
    final summary = state.summary;
    final hardStop = state.hardStop;
    final decision = summary?.decision ?? state.decision;
    final checkedFlags = _checkedFlags(
      state: state,
      summary: summary,
      hardStop: hardStop,
    );

    return EvaluationModel(
      evaluationId: 'radar_${state.sessionId}',
      patientLocalId: patient?.localId,
      patientAnonymousId: patient?.anonymousId,
      patientDisplayName: RgpdLocalService.patientDisplayName(patient),
      date: _now(),
      motif: 'Radar - ${_regionLabel(state.region)}',
      score: 0,
      riskLevel: _riskLevelLabel(decision?.decisionLevel),
      checkedCount: checkedFlags.length,
      checkedFlags: checkedFlags,
      decisionTitle:
          hardStop?.hardStopTitle ??
          decision?.title ??
          'Décision clinique Radar',
      decisionMessage:
          decision?.vigilanceMessage ??
          _hardStopRecommendation(hardStop) ??
          'Conclusion issue du parcours clinique Radar.',
      aiSummary: _clinicalSummary(
        summary: summary,
        hardStop: hardStop,
        decisionSummary: decision?.summary,
      ),
    );
  }

  List<Map<String, dynamic>> _checkedFlags({
    required RadarClinicalViewState state,
    required RadarClinicalSummaryViewState? summary,
    required RadarClinicalHardStopViewState? hardStop,
  }) {
    final severity = _severityLabel(state.decision?.decisionLevel);
    final flags = <Map<String, dynamic>>[
      for (final answer in summary?.positiveAnswers ?? const [])
        {
          'id': answer.questionId,
          'label': answer.text,
          'title': answer.text,
          'text': answer.text,
          'category': _regionLabel(state.region),
          'severity': severity,
          'source': 'radar',
          'questionId': answer.questionId,
        },
    ];

    if (hardStop != null) {
      flags.add({
        'id': hardStop.hardStopId ?? 'radar_hard_stop',
        'label': hardStop.hardStopTitle ?? 'Élément prioritaire Radar',
        'title': hardStop.hardStopTitle ?? 'Élément prioritaire Radar',
        'text': hardStop.hardStopTitle ?? 'Élément prioritaire Radar',
        'description': _hardStopRecommendation(hardStop) ?? hardStop.stopReason,
        'category': _regionLabel(hardStop.region),
        'severity': _severityLabel(
          hardStop.decisionLevel ?? state.decision?.decisionLevel,
        ),
        'source': 'radar',
        if (hardStop.triggeringQuestionId != null)
          'questionId': hardStop.triggeringQuestionId,
      });
    }

    return flags;
  }

  String _clinicalSummary({
    required RadarClinicalSummaryViewState? summary,
    required RadarClinicalHardStopViewState? hardStop,
    required String? decisionSummary,
  }) {
    final lines = [
      if (hardStop?.hardStopTitle?.trim().isNotEmpty ?? false)
        'Élément prioritaire : ${hardStop!.hardStopTitle!.trim()}',
      if (summary?.shortExplanation.trim().isNotEmpty ?? false)
        summary!.shortExplanation.trim(),
      if (decisionSummary?.trim().isNotEmpty ?? false) decisionSummary!.trim(),
      if (hardStop != null) _hardStopRecommendation(hardStop),
    ].whereType<String>().where((line) => line.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      return 'Synthèse issue du parcours clinique Radar.';
    }

    return lines.join('\n\n');
  }

  String? _hardStopRecommendation(RadarClinicalHardStopViewState? hardStop) {
    if (hardStop == null) return null;
    return 'Évaluation médicale urgente recommandée.';
  }

  String _riskLevelLabel(ClinicalDecisionLevel? level) {
    return switch (level) {
      ClinicalDecisionLevel.routine => 'Prise en charge possible',
      ClinicalDecisionLevel.monitor => 'Surveillance renforcée',
      ClinicalDecisionLevel.medicalAdvice => 'Avis médical recommandé',
      ClinicalDecisionLevel.urgentReferral => 'Avis médical rapide nécessaire',
      ClinicalDecisionLevel.emergency => 'Urgence immédiate',
      null => 'Risque inconnu',
    };
  }

  String _severityLabel(ClinicalDecisionLevel? level) {
    return switch (level) {
      ClinicalDecisionLevel.routine => 'faible',
      ClinicalDecisionLevel.monitor => 'modere',
      ClinicalDecisionLevel.medicalAdvice => 'modere',
      ClinicalDecisionLevel.urgentReferral => 'eleve',
      ClinicalDecisionLevel.emergency => 'critique',
      null => 'inconnu',
    };
  }

  String _regionLabel(RadarClinicalRegion region) {
    return switch (region) {
      RadarClinicalRegion.lumbar => 'Lombaires',
      RadarClinicalRegion.cervical => 'Cou',
      RadarClinicalRegion.thoracic => 'Thorax / dos',
      RadarClinicalRegion.shoulderUpperLimbProximal => 'Épaule / bras',
      RadarClinicalRegion.upperLimbDistal => 'Coude / main',
      RadarClinicalRegion.hipLowerLimbProximal => 'Bassin / hanche',
      RadarClinicalRegion.kneeLeg => 'Genou / jambe',
      RadarClinicalRegion.ankleFoot => 'Cheville / pied',
      RadarClinicalRegion.diffuse => 'Douleur diffuse',
    };
  }
}

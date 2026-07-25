import 'dart:io';

import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_history_recorder.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_hard_stop_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_status.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_stop_policy.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_summary_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_decision_view_data.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/services/history_service.dart';
import 'package:drapeaux_rouges_mb/services/rgpd_local_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('RadarClinicalHistoryRecorder', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'radar_clinical_history_recorder_test_',
      );
      Hive.init(tempDir.path);
      await Hive.openBox('patients_box');
      await Hive.openBox('settings_box');
      await Hive.openBox('evaluations_box');
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('saves a completed Radar summary in evaluation history', () async {
      await RgpdLocalService.saveOrUpdatePatient(_patient());
      final recorder = RadarClinicalHistoryRecorder(
        now: () => DateTime(2026, 7, 25, 10),
      );

      await recorder.saveCompletedEvaluation(_summaryState());

      final history = await HistoryService.loadHistory();
      expect(history, hasLength(1));
      expect(history.single['evaluationId'], 'radar_radar-session-1');
      expect(history.single['source'], 'radar');
      expect(history.single['patientDisplayName'], 'DUPONT Alice');
      expect(history.single['motif'], 'Radar - Lombaires');
      expect(history.single['riskLevel'], 'Prise en charge possible');
      expect(history.single['decisionTitle'], 'Prise en charge possible');
      expect(history.single['checkedCount'], 0);
      expect(history.single['clinicalReasoning'], isA<Map>());
      expect(
        history.single['aiSummary'],
        contains('Aucun drapeau rouge identifié'),
      );
      expect(history.single['aiSummary'], isNot(contains('engine')));
      expect(history.single['aiSummary'], isNot(contains('V5')));
    });

    test('saves a Radar hard stop as a critical history finding', () async {
      final recorder = RadarClinicalHistoryRecorder(
        now: () => DateTime(2026, 7, 25, 11),
      );

      await recorder.saveCompletedEvaluation(_hardStopState());

      final history = await HistoryService.loadHistory();
      expect(history, hasLength(1));
      expect(history.single['evaluationId'], 'radar_radar-hard-stop-1');
      expect(history.single['patientDisplayName'], 'Patient non renseigné');
      expect(history.single['riskLevel'], 'Urgence immédiate');
      expect(
        history.single['decisionTitle'],
        'Suspicion de syndrome de la queue de cheval',
      );
      expect(history.single['checkedCount'], 1);

      final checkedFlags = history.single['checkedFlags'] as List;
      expect(checkedFlags.single['id'], 'v5_hard_stop_queue_cheval');
      expect(checkedFlags.single['severity'], 'critique');
      expect(
        checkedFlags.single['title'],
        'Suspicion de syndrome de la queue de cheval',
      );
      expect(history.single['clinicalReasoning'], isA<Map>());
    });

    test('does not save an unfinished Radar question state', () async {
      final recorder = RadarClinicalHistoryRecorder(
        now: () => DateTime(2026, 7, 25, 12),
      );

      await recorder.saveCompletedEvaluation(
        RadarClinicalViewState(
          sessionId: 'radar-question-1',
          region: RadarClinicalRegion.lumbar,
          status: RadarClinicalStatus.question,
          question: null,
          decision: null,
          answeredQuestionIds: const {},
        ),
      );

      expect(await HistoryService.loadHistory(), isEmpty);
    });
  });
}

PatientLocal _patient() {
  return PatientLocal(
    localId: 'patient-1',
    anonymousId: 'DR-patient-1',
    nom: 'Dupont',
    prenom: 'Alice',
    dateNaissance: '12/03/1981',
    consentementValide: true,
    dateConsentement: DateTime(2026, 1, 12),
  );
}

RadarClinicalViewState _summaryState() {
  final decision = RadarDecisionViewData(
    decisionLevel: ClinicalDecisionLevel.routine,
    title: 'Prise en charge possible',
    summary: 'Aucun drapeau rouge identifié parmi les éléments évalués.',
    vigilanceMessage:
        'Réévaluer en cas d’évolution défavorable ou d’apparition de nouveaux signes.',
  );
  final summary = RadarClinicalSummaryViewState(
    sessionId: 'radar-session-1',
    region: RadarClinicalRegion.lumbar,
    status: RadarClinicalStatus.decision,
    decision: decision,
    regionalOutcome: RadarSessionOutcome.reassure,
    endReason: 'Complétude régionale atteinte.',
    questions: const [
      RadarClinicalQuestionSummary(
        questionId: 'v4_queue_cheval_001',
        text: 'Troubles urinaires ou fécaux nouveaux',
        isPositive: false,
      ),
    ],
    contextGates: const {},
    clinicalTriggers: const {},
    contextActivations: const [],
    positiveFlagIds: const [],
    reassuringFlagIds: const [],
    hardStopId: null,
    hardStopTitle: null,
    primaryHypothesisId: null,
    primaryHypothesisTitle: null,
    shortExplanation: 'Aucun drapeau rouge identifié.',
    matrixVersion: kRadarPathwayMatrixVersion,
    validationStatus: kRadarPathwayClinicalValidationStatus,
    operatingMode: RadarClinicalOperatingMode.experimental,
    engineVersion: 'V5',
  );

  return RadarClinicalViewState(
    sessionId: 'radar-session-1',
    region: RadarClinicalRegion.lumbar,
    status: RadarClinicalStatus.decision,
    question: null,
    decision: decision,
    answeredQuestionIds: const {'v4_queue_cheval_001'},
    summary: summary,
  );
}

RadarClinicalViewState _hardStopState() {
  final decision = RadarDecisionViewData(
    decisionLevel: ClinicalDecisionLevel.emergency,
    title: 'Urgence immédiate',
    summary: 'Les éléments recueillis justifient une conduite immédiate.',
    vigilanceMessage: 'Évaluation médicale urgente recommandée.',
    hardStopIds: const ['v5_hard_stop_queue_cheval'],
  );
  final hardStop = RadarClinicalHardStopViewState(
    sessionId: 'radar-hard-stop-1',
    region: RadarClinicalRegion.lumbar,
    hardStopState: ClinicalHardStopStateV5.confirmed,
    hardStopId: 'v5_hard_stop_queue_cheval',
    hardStopTitle: 'Suspicion de syndrome de la queue de cheval',
    clinicalFamilyId: 'neurologique',
    decisionLevel: ClinicalDecisionLevel.emergency,
    criticalArguments: const ['Troubles urinaires ou fécaux nouveaux'],
    contributingQuestionIds: const ['v4_queue_cheval_001'],
    triggeringQuestionId: 'v4_queue_cheval_001',
    stopReason: 'Hard Stop identifié.',
    regionalOutcome: RadarSessionOutcome.hardStop,
    contextGates: const {},
    clinicalTriggers: const {},
    engineVersion: 'V5',
    matrixVersion: kRadarPathwayMatrixVersion,
    validationStatus: kRadarPathwayClinicalValidationStatus,
    operatingMode: RadarClinicalOperatingMode.experimental,
  );

  return RadarClinicalViewState(
    sessionId: 'radar-hard-stop-1',
    region: RadarClinicalRegion.lumbar,
    status: RadarClinicalStatus.hardStop,
    question: null,
    decision: decision,
    answeredQuestionIds: const {'v4_queue_cheval_001'},
    hardStop: hardStop,
  );
}

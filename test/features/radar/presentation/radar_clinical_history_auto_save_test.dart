import 'dart:async';

import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_history_recorder.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_hard_stop_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_status.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_stop_policy.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_summary_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_decision_view_data.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_hard_stop_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_summary_screen.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_hard_stop_rule_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Radar terminal history auto save', () {
    testWidgets('summary screen records the completed state on entry', (
      tester,
    ) async {
      final recorder = _SpyHistoryRecorder();
      final state = _summaryState();

      await tester.pumpWidget(
        MaterialApp(
          home: RadarClinicalSummaryScreen(
            finalState: state,
            historyRecorder: recorder,
          ),
        ),
      );

      expect(await recorder.savedState, same(state));
    });

    testWidgets('hard stop screen records the completed state on entry', (
      tester,
    ) async {
      final recorder = _SpyHistoryRecorder();
      final state = _hardStopState();

      await tester.pumpWidget(
        MaterialApp(
          home: RadarClinicalHardStopScreen(
            finalState: state,
            historyRecorder: recorder,
          ),
        ),
      );

      expect(await recorder.savedState, same(state));
    });
  });
}

class _SpyHistoryRecorder extends RadarClinicalHistoryRecorder {
  final _completer = Completer<RadarClinicalViewState>();

  Future<RadarClinicalViewState> get savedState => _completer.future;

  @override
  Future<void> saveCompletedEvaluation(RadarClinicalViewState state) async {
    if (!_completer.isCompleted) {
      _completer.complete(state);
    }
  }
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
    sessionId: 'radar-summary-widget',
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
    sessionId: 'radar-summary-widget',
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

  return RadarClinicalViewState(
    sessionId: 'radar-hard-stop-widget',
    region: RadarClinicalRegion.lumbar,
    status: RadarClinicalStatus.hardStop,
    question: null,
    decision: decision,
    answeredQuestionIds: const {'v4_queue_cheval_001'},
    hardStop: RadarClinicalHardStopViewState(
      sessionId: 'radar-hard-stop-widget',
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
    ),
  );
}

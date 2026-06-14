import 'dart:io';

import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/models/evaluation_model.dart';
import 'package:drapeaux_rouges_mb/services/history_service.dart';
import 'package:drapeaux_rouges_mb/services/local_database_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'clinical_reasoning_persistence_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox('evaluations_box');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('saves clinical reasoning with evaluation history', () async {
    final evaluation = _evaluation(
      checkedFlags: const [
        {
          'label': 'Dyspnee inhabituelle',
          'category': 'Respiratoire',
          'severity': 'eleve',
        },
      ],
    );

    await HistoryService.saveEvaluation(
      history: const [],
      evaluation: evaluation.toJson(),
    );

    final saved = await HistoryService.loadHistory();
    final clinicalReasoning = saved.single['clinicalReasoning'];

    expect(clinicalReasoning, isA<Map>());
    expect(clinicalReasoning['summary'], isNotEmpty);
    expect(clinicalReasoning['severity'], 'high');
    expect(clinicalReasoning['alerts'], isNotEmpty);
    expect(clinicalReasoning['recommendations'], isNotEmpty);
    expect(clinicalReasoning['retainedItems'], isNotEmpty);
  });

  test('restores clinical reasoning from EvaluationModel JSON', () {
    final reasoning = ClinicalReasoning(
      id: 'reasoning-1',
      evaluationId: 'evaluation-1',
      patientId: 'patient-1',
      findings: [
        ClinicalFinding(
          id: 'finding-1',
          label: 'Dyspnee inhabituelle',
          category: ClinicalFindingCategory.respiratory,
          severity: ClinicalSeverity.high,
          source: ClinicalSource.evaluation,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      alerts: [
        ClinicalAlert(
          id: 'alert-1',
          title: 'Vigilance',
          message: 'Message',
          level: ClinicalAlertLevel.warning,
          relatedFindingIds: const ['finding-1'],
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      recommendations: [
        ClinicalRecommendation(
          id: 'recommendation-1',
          title: 'Validation',
          description: 'Description',
          priority: ClinicalRecommendationPriority.high,
          actionType: ClinicalActionType.refer,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      summary: 'Synthese persistée',
      createdAt: DateTime(2026, 1, 1),
    );

    final restored = EvaluationModel.fromJson({
      ..._evaluation().toJson(),
      'clinicalReasoning': reasoning.toJson(),
    });

    expect(restored.clinicalReasoning, isNotNull);
    expect(restored.clinicalReasoning!.summary, 'Synthese persistée');
    expect(
      restored.clinicalReasoning!.findings.single.severity,
      ClinicalSeverity.high,
    );
    expect(
      restored.clinicalReasoning!.alerts.single.level,
      ClinicalAlertLevel.warning,
    );
    expect(
      restored.clinicalReasoning!.recommendations.single.priority,
      ClinicalRecommendationPriority.high,
    );
  });

  test('keeps old evaluations compatible when clinicalReasoning is absent', () {
    final oldEvaluation = _evaluation().toJson()..remove('clinicalReasoning');

    final restored = EvaluationModel.fromJson(oldEvaluation);

    expect(restored.clinicalReasoning, isNull);
    expect(restored.evaluationId, 'evaluation-1');
  });

  test('loads old persisted evaluations without clinical reasoning', () async {
    final oldEvaluation = _evaluation().toJson()..remove('clinicalReasoning');

    await LocalDatabaseService.saveEvaluation(oldEvaluation);

    final saved = await HistoryService.loadHistory();

    expect(saved.single['clinicalReasoning'], isNull);
    expect(() => EvaluationModel.fromJson(saved.single), returnsNormally);
  });
}

EvaluationModel _evaluation({
  List<Map<String, dynamic>> checkedFlags = const [],
}) {
  return EvaluationModel(
    evaluationId: 'evaluation-1',
    patientLocalId: 'patient-1',
    patientAnonymousId: null,
    patientDisplayName: 'Patient test',
    date: DateTime(2026, 1, 1),
    motif: 'Respiratoire',
    score: 7,
    riskLevel: 'Risque eleve',
    checkedCount: checkedFlags.length,
    checkedFlags: checkedFlags,
    decisionTitle: 'Decision',
    decisionMessage: 'Message',
    aiSummary: 'Synthese',
  );
}

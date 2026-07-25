import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/models/evaluation_model.dart';
import 'package:drapeaux_rouges_mb/screens/evaluation/evaluation_detail_screen.dart';
import 'package:drapeaux_rouges_mb/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Radar saved evaluation history display and export', () {
    testWidgets('shows saved Radar summary details without technical metadata', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: EvaluationDetailScreen(evaluation: _savedSummaryEvaluation()),
        ),
      );
      await tester.pump();

      expect(find.text('DUPONT Alice'), findsOneWidget);
      expect(find.text('Radar - Lombaires'), findsWidgets);
      expect(find.text('Prise en charge possible'), findsWidgets);
      expect(
        find.text(
          'Réévaluer en cas d’évolution défavorable ou d’apparition de nouveaux signes.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Aucun drapeau rouge coché dans ce bilan.'),
        findsOneWidget,
      );
      expect(find.textContaining('radar-session-1'), findsNothing);
      expect(find.textContaining(kRadarPathwayMatrixVersion), findsNothing);
      expect(find.textContaining('engine'), findsNothing);
      expect(find.textContaining('V5'), findsNothing);
      expect(find.textContaining('v5_hard_stop'), findsNothing);
    });

    test('builds a PDF from a saved Radar hard stop evaluation', () async {
      final detail = EvaluationDetailScreen(
        evaluation: _savedHardStopEvaluation(),
      );
      final categories = detail.buildPdfCategories();

      expect(detail.patientName, 'Patient non renseigné');
      expect(detail.motif, 'Radar - Lombaires');
      expect(detail.riskLevel, 'Urgence immédiate');
      expect(
        detail.decisionTitle,
        'Suspicion de syndrome de la queue de cheval',
      );
      expect(categories, contains('Lombaires'));
      expect(
        categories['Lombaires']!.single['title'],
        'Suspicion de syndrome de la queue de cheval',
      );

      final bytes = await PdfService.buildPdfBytes(
        categories: categories,
        score: detail.score,
        checkedCount: detail.checkedCount,
        riskLevel: detail.riskLevel,
        patientCode: detail.patientExportCode,
        motif: detail.motif,
        decisionTitle: detail.decisionTitle,
        decisionMessage: detail.decisionMessage,
        aiSummary: detail.aiSummary,
        clinicalReasoning: detail.savedClinicalReasoning,
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(bytes.length, greaterThan(1500));
    });
  });
}

Map<String, dynamic> _savedSummaryEvaluation() {
  return EvaluationModel(
      evaluationId: 'radar_radar-session-1',
      patientLocalId: 'patient-1',
      patientAnonymousId: 'DR-patient-1',
      patientDisplayName: 'DUPONT Alice',
      date: DateTime(2026, 7, 25, 10),
      motif: 'Radar - Lombaires',
      score: 0,
      riskLevel: 'Prise en charge possible',
      checkedCount: 0,
      checkedFlags: const [],
      decisionTitle: 'Prise en charge possible',
      decisionMessage:
          'Réévaluer en cas d’évolution défavorable ou d’apparition de nouveaux signes.',
      aiSummary: 'Aucun drapeau rouge identifié.',
    ).toJson()
    ..['source'] = 'radar'
    ..['radarSessionId'] = 'radar-session-1'
    ..['radarRegion'] = 'lumbar'
    ..['radarMatrixVersion'] = kRadarPathwayMatrixVersion
    ..['radarValidationStatus'] = kRadarPathwayClinicalValidationStatus
    ..['radarEngineVersion'] = 'V5';
}

Map<String, dynamic> _savedHardStopEvaluation() {
  return EvaluationModel(
      evaluationId: 'radar_radar-hard-stop-1',
      patientLocalId: null,
      patientAnonymousId: null,
      patientDisplayName: 'Patient non renseigné',
      date: DateTime(2026, 7, 25, 11),
      motif: 'Radar - Lombaires',
      score: 0,
      riskLevel: 'Urgence immédiate',
      checkedCount: 1,
      checkedFlags: const [
        {
          'id': 'v5_hard_stop_queue_cheval',
          'title': 'Suspicion de syndrome de la queue de cheval',
          'label': 'Suspicion de syndrome de la queue de cheval',
          'category': 'Lombaires',
          'severity': 'critique',
          'source': 'radar',
        },
      ],
      decisionTitle: 'Suspicion de syndrome de la queue de cheval',
      decisionMessage: 'Évaluation médicale urgente recommandée.',
      aiSummary:
          'Élément prioritaire : Suspicion de syndrome de la queue de cheval\n\n'
          'Évaluation médicale urgente recommandée.',
    ).toJson()
    ..['source'] = 'radar'
    ..['radarSessionId'] = 'radar-hard-stop-1'
    ..['radarRegion'] = 'lumbar'
    ..['radarMatrixVersion'] = kRadarPathwayMatrixVersion
    ..['radarValidationStatus'] = kRadarPathwayClinicalValidationStatus
    ..['radarEngineVersion'] = 'V5';
}

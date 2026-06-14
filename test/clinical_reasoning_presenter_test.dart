import 'package:drapeaux_rouges_mb/models/clinical/clinical_models.dart';
import 'package:drapeaux_rouges_mb/presentation/clinical_reasoning/clinical_reasoning_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClinicalReasoningPresenter', () {
    const presenter = ClinicalReasoningPresenter();

    test('labels a warning alert', () {
      expect(
        presenter.alertLevelLabel(ClinicalAlertLevel.warning),
        'Vigilance',
      );
    });

    test('labels a critical alert', () {
      expect(
        presenter.alertLevelLabel(ClinicalAlertLevel.critical),
        'Critique',
      );
    });

    test('labels a high priority recommendation', () {
      expect(
        presenter.recommendationPriorityLabel(
          ClinicalRecommendationPriority.high,
        ),
        'Haute',
      );
    });

    test('labels a finding', () {
      final finding = ClinicalFinding(
        id: 'finding-1',
        label: 'Dyspnée inhabituelle',
        category: ClinicalFindingCategory.respiratory,
        severity: ClinicalSeverity.high,
        source: ClinicalSource.evaluation,
        createdAt: DateTime(2026, 1, 1),
      );

      final data = presenter.finding(finding);

      expect(data.title, 'Dyspnée inhabituelle');
      expect(data.body, 'Respiratoire · Élevée');
      expect(data.badgeLabel, 'Élevée');
    });

    test('handles empty display values without crashing', () {
      final alert = ClinicalAlert(
        id: 'alert-empty',
        title: '',
        message: '',
        level: ClinicalAlertLevel.info,
        relatedFindingIds: const [],
        createdAt: DateTime(2026, 1, 1),
      );

      final data = presenter.alert(alert);

      expect(data.title, '');
      expect(data.body, '');
      expect(data.badgeLabel, 'Info');
    });
  });
}

import 'package:drapeaux_rouges_mb/services/decision_engine_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DecisionEngineService', () {
    test('low score returns the low-risk decision title and message', () {
      final categories = <String, List<Map<String, dynamic>>>{};

      expect(
        DecisionEngineService.decisionTitle(
          score: 0,
          selectedCategory: 'Lombalgie',
          categories: categories,
        ),
        'Prise en charge possible avec surveillance',
      );

      expect(
        DecisionEngineService.decisionMessage(
          score: 0,
          selectedCategory: 'Lombalgie',
          categories: categories,
        ),
        'Aucun signe critique majeur identifié actuellement.',
      );
    });

    test('medium score returns the intermediate decision title and message', () {
      final categories = <String, List<Map<String, dynamic>>>{};

      expect(
        DecisionEngineService.decisionTitle(
          score: 4,
          selectedCategory: 'Lombalgie',
          categories: categories,
        ),
        'Avis médical rapide recommandé',
      );

      expect(
        DecisionEngineService.decisionMessage(
          score: 4,
          selectedCategory: 'Lombalgie',
          categories: categories,
        ),
        'Des signes d’alerte significatifs sont présents. Un avis médical rapide est recommandé.',
      );
    });

    test('high score returns the urgent decision title and message', () {
      final categories = <String, List<Map<String, dynamic>>>{};

      expect(
        DecisionEngineService.decisionTitle(
          score: 6,
          selectedCategory: 'Lombalgie',
          categories: categories,
        ),
        'Orientation urgente recommandée',
      );

      expect(
        DecisionEngineService.decisionMessage(
          score: 6,
          selectedCategory: 'Lombalgie',
          categories: categories,
        ),
        'Plusieurs signes d’alerte importants sont présents. Une orientation médicale urgente doit être envisagée.',
      );
    });

    test('checked Ottawa red flag influences the decision', () {
      final categories = {
        'Entorse de cheville': [
          {
            'title': 'Critère Ottawa positif',
            'severity': 'Modéré',
            'checked': true,
            'tags': ['ottawa'],
          },
        ],
      };

      expect(
        DecisionEngineService.decisionTitle(
          score: 1,
          selectedCategory: 'Entorse de cheville',
          categories: categories,
        ),
        'Critères d’Ottawa positifs',
      );

      expect(
        DecisionEngineService.decisionMessage(
          score: 1,
          selectedCategory: 'Entorse de cheville',
          categories: categories,
        ),
        'Un ou plusieurs critères d’Ottawa sont positifs. Une radiographie est recommandée selon le contexte clinique.',
      );
    });

    test('checked pulmonary embolism red flag overrides score decision', () {
      final categories = {
        'TVP / Vasculaire': [
          {
            'title': 'Dyspnée brutale',
            'severity': 'Critique',
            'checked': true,
            'tags': ['embolie_pulmonaire'],
          },
        ],
      };

      expect(
        DecisionEngineService.decisionTitle(
          score: 1,
          selectedCategory: 'TVP / Vasculaire',
          categories: categories,
        ),
        'Orientation urgente recommandée',
      );

      expect(
        DecisionEngineService.decisionMessage(
          score: 1,
          selectedCategory: 'TVP / Vasculaire',
          categories: categories,
        ),
        'Présence de signes pouvant évoquer une complication cardio-respiratoire ou embolique. Une orientation médicale urgente est recommandée.',
      );
    });
  });
}

import 'package:drapeaux_rouges_mb/services/risk_score_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RiskScoreService', () {
    test('normalizes severity values and returns severity points', () {
      expect(RiskScoreService.normalizeSeverity('critique'), 'Critique');
      expect(RiskScoreService.normalizeSeverity('Élevé'), 'Élevé');
      expect(RiskScoreService.normalizeSeverity('modéré'), 'Modéré');

      expect(RiskScoreService.severityPoints('Critique'), 3);
      expect(RiskScoreService.severityPoints('Élevé'), 2);
      expect(RiskScoreService.severityPoints('Modéré'), 1);
    });

    test('computes score from checked items only', () {
      final items = [
        {
          'title': 'Checked moderate flag',
          'severity': 'Modéré',
          'checked': true,
        },
        {
          'title': 'Checked high flag',
          'severity': 'Élevé',
          'checked': true,
        },
        {
          'title': 'Unchecked critical flag',
          'severity': 'Critique',
          'checked': false,
        },
      ];

      expect(RiskScoreService.computeScore(items), 3);
      expect(RiskScoreService.computeCheckedCount(items), 2);
    });

    test('computes global score and checked count across categories', () {
      final categories = {
        'Lombalgie': [
          {
            'title': 'Moderate flag',
            'severity': 'Modéré',
            'checked': true,
          },
        ],
        'Cervicalgie': [
          {
            'title': 'Critical flag',
            'severity': 'Critique',
            'checked': true,
          },
          {
            'title': 'Unchecked high flag',
            'severity': 'Élevé',
            'checked': false,
          },
        ],
      };

      expect(RiskScoreService.computeGlobalScore(categories), 4);
      expect(RiskScoreService.computeGlobalCheckedCount(categories), 2);
    });

    test('returns risk level and color from score', () {
      expect(RiskScoreService.riskLevelFromScore(0), 'Risque faible');
      expect(RiskScoreService.riskLevelFromScore(2), 'Risque modéré');
      expect(RiskScoreService.riskLevelFromScore(4), 'Risque élevé');
      expect(RiskScoreService.riskLevelFromScore(6), 'Risque critique');

      expect(
        RiskScoreService.riskColorFromScore(0),
        const Color(0xFF22C55E),
      );
      expect(
        RiskScoreService.riskColorFromScore(2),
        const Color(0xFFF59E0B),
      );
      expect(
        RiskScoreService.riskColorFromScore(4),
        const Color(0xFFDC2626),
      );
      expect(
        RiskScoreService.riskColorFromScore(6),
        const Color(0xFF7F1D1D),
      );
    });

    test('extracts checked flags from categories', () {
      final categories = {
        'Lombalgie': [
          {
            'title': 'Moderate flag',
            'severity': 'modéré',
            'checked': true,
            'tags': ['test'],
          },
          {
            'title': 'Unchecked flag',
            'severity': 'Critique',
            'checked': false,
          },
        ],
      };

      expect(
        RiskScoreService.checkedFlagsFromCategories(categories),
        [
          {
            'category': 'Lombalgie',
            'title': 'Moderate flag',
            'severity': 'Modéré',
            'tags': ['test'],
          },
        ],
      );
    });
  });
}

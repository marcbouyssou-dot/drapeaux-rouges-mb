import 'dart:io';

import 'package:drapeaux_rouges_mb/services/bdk_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(BDKSessionService.clear);

  test(
    'loadFromClinicalSummary clears previous state and loads clinical data',
    () {
      BDKSessionService.motif = 'ancien motif';
      BDKSessionService.riskLevel = 'ancien risque';
      BDKSessionService.riskScore = 42;
      BDKSessionService.redFlags = ['ancien drapeau'];

      BDKSessionService.loadFromClinicalSummary(
        const BDKClinicalPrefill(
          regionLabel: 'Lombaires',
          decisionTitle: 'Prise en charge possible',
          decisionSummary:
              'Aucun drapeau rouge identifié parmi les éléments évalués.',
          vigilanceMessage:
              'Réévaluer en cas d’évolution défavorable ou d’apparition de nouveaux signes.',
          clinicalExplanation: 'Synthèse établie à partir des réponses.',
          positiveFindings: ['Douleur liée au mouvement'],
          negativeFindings: ['Troubles urinaires ou fécaux nouveaux'],
        ),
      );

      expect(BDKSessionService.motif, contains('Lombaires'));
      expect(
        BDKSessionService.contexte,
        contains('Évaluation de sécurité clinique réalisée avant le bilan.'),
      );
      expect(
        BDKSessionService.evaluation,
        contains('Douleur liée au mouvement'),
      );
      expect(
        BDKSessionService.evaluation,
        contains('Troubles urinaires ou fécaux nouveaux'),
      );
      expect(BDKSessionService.vigilance, contains('Réévaluer'));
      expect(
        BDKSessionService.syntheseClinique,
        contains('Conclusion Radar : Prise en charge possible'),
      );
      expect(BDKSessionService.riskLevel, isEmpty);
      expect(BDKSessionService.riskScore, 0);
      expect(BDKSessionService.redFlags, isEmpty);
    },
  );

  test('loadFromClinicalSummary does not require technical identifiers', () {
    BDKSessionService.loadFromClinicalSummary(
      const BDKClinicalPrefill(
        regionLabel: 'Genou / jambe',
        decisionTitle: 'Surveillance renforcée',
        decisionSummary:
            'Les éléments recueillis justifient une surveillance clinique renforcée.',
        vigilanceMessage: 'Réévaluer régulièrement.',
        clinicalExplanation: 'Explication clinique courte.',
      ),
    );

    final exportedText = [
      BDKSessionService.motif,
      BDKSessionService.contexte,
      BDKSessionService.evaluation,
      BDKSessionService.vigilance,
      BDKSessionService.syntheseClinique,
    ].join('\n');

    expect(exportedText, isNot(contains('V5')));
    expect(exportedText, isNot(contains('engine')));
    expect(exportedText, isNot(contains('runtime')));
    expect(exportedText, isNot(contains('session id')));
    expect(exportedText, isNot(contains('RadarClinicalStatus')));
    expect(exportedText, isNot(contains('v5_hard_stop')));
  });

  test('BDKClinicalPrefill remains free of patient identity', () {
    final source = File(
      'lib/services/bdk_session_service.dart',
    ).readAsStringSync();
    final prefillSource = source.substring(
      source.indexOf('class BDKClinicalPrefill'),
      source.indexOf('class BDKSessionService'),
    );

    expect(prefillSource, isNot(contains('PatientLocal')));
    expect(prefillSource, isNot(contains('patient')));
    expect(prefillSource, isNot(contains('anonymousId')));
    expect(prefillSource, isNot(contains('localId')));
  });
}

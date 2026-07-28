import 'dart:io';

import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_engine_adapter.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_answer.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_pathway_definition.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_region.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_session_controller.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_clinical_view_state.dart';
import 'package:drapeaux_rouges_mb/features/radar/application/radar_regional_clinical_orchestrator.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_question_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_start_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/screens/radar_clinical_summary_screen.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_decision_card.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_patient_context.dart';
import 'package:drapeaux_rouges_mb/features/radar/presentation/widgets/radar_region_action.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_session_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_adaptive_view_state_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_probability_update_v5.dart';
import 'package:drapeaux_rouges_mb/models/clinical_screening/clinical_screening_models.dart';
import 'package:drapeaux_rouges_mb/screens/bdk/bdk_detail_screen.dart';
import 'package:drapeaux_rouges_mb/screens/bdk/bdk_type_screen.dart';
import 'package:drapeaux_rouges_mb/screens/patient_consent_screen.dart';
import 'package:drapeaux_rouges_mb/services/bdk_pdf_service.dart';
import 'package:drapeaux_rouges_mb/services/bdk_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  group('Radar clinical connected flow', () {
    late Directory tempDir;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      tempDir = await Directory.systemTemp.createTemp('radar_bdk_test_');
      Hive.init(tempDir.path);

      await Hive.openBox('patients_box');
      await Hive.openBox('settings_box');
    });

    setUp(() async {
      BDKSessionService.clear();
      await Hive.box('patients_box').clear();
      await Hive.box('settings_box').clear();
    });

    tearDownAll(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    testWidgets('tapping Lombaires opens the first real runtime question', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      expect(find.text('TÊTE ET COU'), findsOneWidget);
      expect(find.text('MEMBRE SUPÉRIEUR'), findsOneWidget);
      expect(find.text('TRONC'), findsOneWidget);
      expect(find.text('MEMBRE INFÉRIEUR'), findsOneWidget);
      expect(find.text('AUTRE'), findsOneWidget);
      expect(find.byType(RadioListTile), findsNothing);

      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsOneWidget,
      );
      expect(find.text('Évaluation clinique'), findsOneWidget);
      expect(find.text('Lombaires • Étape 1'), findsOneWidget);
      expect(find.byTooltip('Retour'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping Cou opens the cervical pathway question', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      await tester.tap(find.text('Cou'));
      await tester.pumpAndSettle();

      expect(find.textContaining('céphalée inhabituelle'), findsOneWidget);
      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsNothing,
      );
    });

    testWidgets(
      'different supported regions can start with different questions',
      (tester) async {
        await _pumpStartScreen(tester);
        await tester.tap(find.text('Lombaires'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('troubles urinaires ou fécaux nouveaux'),
          findsOneWidget,
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await _pumpStartScreen(tester);
        await tester.tap(find.text('Cou'));
        await tester.pumpAndSettle();

        expect(find.textContaining('céphalée inhabituelle'), findsOneWidget);
        expect(
          find.textContaining('troubles urinaires ou fécaux nouveaux'),
          findsNothing,
        );
      },
    );

    testWidgets('shows nine functional regions and hides Tête / Face', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      expect(find.text('Tête / Face'), findsNothing);
      expect(find.text('Thorax'), findsNothing);
      expect(find.text('Dos'), findsNothing);
      expect(find.text('Thorax / Dos'), findsOneWidget);
      expect(find.byType(RadarRegionAction), findsNWidgets(9));
    });

    testWidgets('only yes and no are visible in the connected V5 flow', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      expect(find.text('Oui'), findsOneWidget);
      expect(find.text('Non'), findsOneWidget);
      expect(find.text('Des deux côtés'), findsNothing);
      expect(find.text('Impossible à préciser'), findsNothing);
      expect(find.byType(RadioListTile), findsNothing);
    });

    testWidgets('question text is allowed to wrap without ellipsis', (
      tester,
    ) async {
      await _pumpStartScreen(tester);

      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      final questionFinder = find.textContaining(
        'troubles urinaires ou fécaux nouveaux',
      );
      expect(questionFinder, findsOneWidget);

      final questionText = tester.widget<Text>(questionFinder);
      expect(questionText.maxLines, isNull);
      expect(questionText.overflow, isNull);
    });

    testWidgets('question screen supports increased text scaling', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final controller = RadarClinicalSessionController(
        orchestrator: RadarRegionalClinicalOrchestrator(),
      );
      final initialState = controller.startSession(
        region: RadarClinicalRegion.shoulderUpperLimbProximal,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(1.2),
            ),
            child: RadarClinicalQuestionScreen(
              controller: controller,
              initialState: initialState,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Évaluation clinique'), findsOneWidget);
      expect(find.text('Épaule • Étape 1'), findsOneWidget);
      expect(find.text('Oui'), findsOneWidget);
      expect(find.text('Non'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping no shows next real question without pushing a route', (
      tester,
    ) async {
      final observer = _RecordingNavigatorObserver();
      await _pumpStartScreen(tester, observer: observer);
      final routeCountBeforeStart = observer.didPushCount;

      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();
      expect(observer.didPushCount, routeCountBeforeStart + 1);

      await tester.tap(find.text('Non'));
      await tester.pumpAndSettle();

      expect(observer.didPushCount, routeCountBeforeStart + 1);
      expect(find.textContaining('cancer actif'), findsOneWidget);
      expect(
        find.textContaining('troubles urinaires ou fécaux nouveaux'),
        findsNothing,
      );
    });

    testWidgets(
      'patient context opens from a question and preserves the current step',
      (tester) async {
        await _pumpStartScreen(tester);
        await tester.tap(find.text('Lombaires'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Non'));
        await tester.pumpAndSettle();

        final currentQuestion = find.textContaining('cancer actif');
        expect(currentQuestion, findsOneWidget);

        await tester.tap(find.byType(RadarPatientContextBar));
        await tester.pumpAndSettle();
        expect(find.byType(PatientConsentScreen), findsOneWidget);

        Navigator.of(
          tester.element(find.byType(PatientConsentScreen)),
        ).maybePop();
        await tester.pumpAndSettle();

        expect(find.byType(RadarClinicalQuestionScreen), findsOneWidget);
        expect(currentQuestion, findsOneWidget);
        expect(find.text('Lombaires • Étape 2'), findsOneWidget);
      },
    );

    testWidgets('lumbar summary displays dynamic session data', (tester) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      expect(find.text('Synthèse clinique'), findsOneWidget);
      expect(find.byType(RadarDecisionCard), findsOneWidget);
      expect(find.text('Créer ou compléter le BDK'), findsOneWidget);
      expect(find.text('Poursuivre la consultation'), findsOneWidget);
      expect(find.text('Voir les détails de l’analyse'), findsOneWidget);
      expect(find.text('Détails cliniques'), findsNothing);
      expect(find.textContaining('Région : Lombaires'), findsNothing);
      await tester.tap(find.text('Voir les détails de l’analyse'));
      await tester.pumpAndSettle();

      expect(find.text('Détails cliniques'), findsOneWidget);
      expect(find.textContaining('Région : Lombaires'), findsOneWidget);
      await _scrollUntilText(tester, 'Traçabilité technique avancée');
      expect(find.text('Traçabilité technique avancée'), findsOneWidget);
    });

    testWidgets('another pathway summary displays its own region', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Cou'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      await tester.tap(find.text('Voir les détails de l’analyse'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Région : Cou'), findsOneWidget);
      expect(find.textContaining('Région : Lombaires'), findsNothing);
    });

    testWidgets('positive answer appears dynamically in summary', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(
        tester,
        answerForCurrentQuestion: () {
          if (find.textContaining('liée au mouvement').evaluate().isNotEmpty) {
            return 'Oui';
          }
          return 'Non';
        },
      );

      expect(find.text('Éléments ayant contribué à la décision'), findsNothing);
      await tester.tap(find.text('Voir les détails de l’analyse'));
      await tester.pumpAndSettle();

      expect(
        find.text('Éléments ayant contribué à la décision'),
        findsOneWidget,
      );
      expect(find.textContaining('Réponse positive'), findsOneWidget);
      expect(find.textContaining('liée au mouvement'), findsOneWidget);
    });

    testWidgets('empty contribution section is hidden', (tester) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');
      await tester.tap(find.text('Voir les détails de l’analyse'));
      await tester.pumpAndSettle();

      expect(find.text('Éléments ayant contribué à la décision'), findsNothing);
    });

    testWidgets('experimental non validated status is visible in summary', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');
      await tester.tap(find.text('Voir les détails de l’analyse'));
      await tester.pumpAndSettle();
      await _scrollUntilText(tester, 'Traçabilité technique avancée');

      expect(find.textContaining('NON VALIDÉE'), findsOneWidget);
      expect(find.textContaining('0.1-experimental'), findsOneWidget);
    });

    testWidgets('summary primary action opens the existing BDK flow', (
      tester,
    ) async {
      BDKSessionService.motif = 'ancien motif';
      BDKSessionService.contexte = 'ancien contexte';
      BDKSessionService.evaluation = 'ancienne évaluation';
      BDKSessionService.riskLevel = 'ancien risque';
      BDKSessionService.riskScore = 42;
      BDKSessionService.redFlags = ['ancien drapeau'];

      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      expect(find.byType(RadarDecisionCard), findsOneWidget);
      final decisionCard = tester.widget<RadarDecisionCard>(
        find.byType(RadarDecisionCard),
      );
      expect(decisionCard.primaryActionLabel, 'Créer ou compléter le BDK');
      expect(find.text('Créer ou compléter le BDK'), findsOneWidget);
      await tester.tap(find.text('Créer ou compléter le BDK'));
      await tester.pumpAndSettle();

      expect(find.text('Fonction disponible prochainement'), findsNothing);
      expect(find.byType(BDKTypeScreen), findsOneWidget);
      expect(find.text('BDK Lombalgie'), findsOneWidget);
      expect(BDKSessionService.motif, contains('Lombaires'));
      expect(
        BDKSessionService.contexte,
        contains('Évaluation de sécurité clinique réalisée avant le bilan.'),
      );
      expect(
        BDKSessionService.evaluation,
        contains('Aucun drapeau rouge identifié'),
      );
      expect(BDKSessionService.vigilance, contains('Réévaluer'));
      expect(
        BDKSessionService.syntheseClinique,
        contains('Conclusion Radar : Prise en charge possible'),
      );
      expect(BDKSessionService.riskLevel, isEmpty);
      expect(BDKSessionService.riskScore, 0);
      expect(BDKSessionService.redFlags, isEmpty);

      final bdkText = [
        BDKSessionService.motif,
        BDKSessionService.contexte,
        BDKSessionService.evaluation,
        BDKSessionService.vigilance,
        BDKSessionService.syntheseClinique,
      ].join('\n');
      expect(bdkText, isNot(contains('ClinicalAdaptiveQuestionEngineV5')));
      expect(bdkText, isNot(contains('RadarClinicalStatus')));
      expect(bdkText, isNot(contains('v5_hard_stop')));
      expect(bdkText, isNot(contains('session id')));
      expect(bdkText, isNot(contains('runtime')));
      expect(bdkText, isNot(contains('engine')));

      await tester.tap(find.text('BDK Lombalgie'));
      await tester.pumpAndSettle();

      expect(find.byType(BDKDetailScreen), findsOneWidget);
      expect(find.text('Patient non renseigné'), findsWidgets);
      expect(
        find.textContaining('Évaluation de sécurité clinique'),
        findsWidgets,
      );
      expect(find.textContaining('Région évaluée : Lombaires'), findsOneWidget);
      expect(find.textContaining('ancien'), findsNothing);
      expect(
        find.textContaining('ClinicalAdaptiveQuestionEngineV5'),
        findsNothing,
      );
      expect(find.textContaining('RadarClinicalStatus'), findsNothing);
      expect(find.textContaining('v5_hard_stop'), findsNothing);
      expect(find.text('Exporter PDF'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField).first,
        'Motif vérifié et modifié par le kinésithérapeute',
      );
      await tester.pump();

      expect(
        BDKSessionService.motif,
        'Motif vérifié et modifié par le kinésithérapeute',
      );

      final pdfBytes = await BdkPdfService.buildBdkPdfBytes(
        title: 'BDK Lombalgie',
        patient: null,
        motif: BDKSessionService.motif,
        contexte: BDKSessionService.contexte,
        antecedents: BDKSessionService.antecedents,
        evaluation: BDKSessionService.evaluation,
        tests: BDKSessionService.tests,
        limitations: BDKSessionService.limitations,
        diagnostic: BDKSessionService.diagnostic,
        vigilance: BDKSessionService.vigilance,
        objectifs: BDKSessionService.objectifs,
        planTraitement: BDKSessionService.planTraitement,
        criteresReevaluation: BDKSessionService.criteresReevaluation,
        syntheseClinique: BDKSessionService.syntheseClinique,
      );
      expect(String.fromCharCodes(pdfBytes.take(4)), '%PDF');
      expect(pdfBytes.length, greaterThan(1500));

      Navigator.of(tester.element(find.byType(BDKDetailScreen))).pop();
      await tester.pumpAndSettle();
      expect(find.byType(BDKTypeScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();

      expect(find.byType(BDKTypeScreen), findsNothing);
      expect(find.text('Synthèse clinique'), findsOneWidget);
      expect(find.text('Créer ou compléter le BDK'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('summary supports increased text scaling without overflow', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final finalState = _completeLumbarRoutineState();

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(1.2),
            ),
            child: RadarClinicalSummaryScreen(finalState: finalState),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Synthèse clinique'), findsOneWidget);
      expect(find.byType(RadarDecisionCard), findsOneWidget);
      expect(find.text(finalState.decision!.title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('old static summary data is no longer rendered', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await _answerUntilSummary(tester, defaultAnswer: 'Non');

      expect(find.text('Marie Dupont'), findsNothing);
      expect(find.text('Télécharger la synthèse (PDF)'), findsNothing);
      expect(find.textContaining('Facteurs rassurants'), findsNothing);
      expect(
        find.textContaining('prise en charge kinésithérapique habituelle'),
        findsNothing,
      );
    });

    testWidgets('hard stop flow opens the dynamic hard stop screen', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();

      expect(find.text('Urgence médicale'), findsOneWidget);
      expect(
        find.text('Suspicion de syndrome de la queue de cheval'),
        findsOneWidget,
      );
      expect(
        find.text('Évaluation médicale urgente recommandée.'),
        findsOneWidget,
      );
      expect(find.textContaining('v5_hard_stop_queue_cheval'), findsNothing);
      expect(find.textContaining('Statut : confirmé'), findsOneWidget);
      expect(find.textContaining('Région : Lombaires'), findsNothing);
      expect(find.text('Poursuivre la consultation'), findsNothing);
      expect(find.text('Créer ou compléter le BDK'), findsNothing);
      expect(BDKSessionService.motif, isEmpty);
      expect(BDKSessionService.syntheseClinique, isEmpty);
    });

    testWidgets('old hard stop static data is gone', (tester) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();

      expect(find.text('Marie Dupont'), findsNothing);
      expect(find.text('Orientation prioritaire'), findsNothing);
      expect(find.textContaining('Suivre la conduite adaptée'), findsNothing);
    });

    testWidgets('hard stop details and non validated status are traceable', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();
      await _tapSection(tester, 'Arguments cliniques');

      expect(find.textContaining('queue_cheval_suspected'), findsOneWidget);

      await _tapSection(tester, 'Traçabilité technique avancée');

      expect(find.textContaining('Question déclenchante'), findsWidgets);
      expect(
        find.textContaining('ClinicalAdaptiveQuestionEngineV5'),
        findsOneWidget,
      );
      expect(find.textContaining('0.1-experimental'), findsOneWidget);
      expect(find.textContaining('NON VALIDÉE'), findsOneWidget);
    });

    testWidgets('hard stop screen hides forbidden wording', (tester) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Appelez immédiatement le 15'), findsNothing);
      expect(find.textContaining('Urgence vitale'), findsNothing);
      expect(find.textContaining('Diagnostic confirmé'), findsNothing);
      expect(find.textContaining('Le patient présente'), findsNothing);
      expect(
        find.textContaining('Cette pathologie est certaine'),
        findsNothing,
      );
      expect(find.textContaining('Aucun autre risque'), findsNothing);
    });

    testWidgets('hard stop safe return action goes back home', (tester) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Lombaires'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();
      await _scrollUntilText(tester, 'Revenir à l’accueil');
      await tester.tap(find.text('Revenir à l’accueil'));
      await tester.pumpAndSettle();

      expect(find.text('Lombaires'), findsOneWidget);
      expect(find.text('Urgence médicale'), findsNothing);
    });

    testWidgets('thorax cardio pathway reaches the real dynamic hard stop', (
      tester,
    ) async {
      await _pumpStartScreen(tester);
      await tester.tap(find.text('Thorax / Dos'));
      await tester.pumpAndSettle();

      expect(find.textContaining('La douleur thoracique'), findsOneWidget);

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();

      expect(find.text('Urgence médicale'), findsOneWidget);
      expect(
        find.text('Douleur thoracique avec signe cardio-respiratoire'),
        findsOneWidget,
      );
      expect(
        find.textContaining('v5_hard_stop_cardiorespiratoire'),
        findsNothing,
      );
      expect(find.textContaining('Statut : confirmé'), findsOneWidget);
      expect(find.textContaining('Niveau fourni : emergency'), findsNothing);
      expect(find.textContaining('Région : Thorax / dos'), findsNothing);
      expect(find.text('Poursuivre la consultation'), findsNothing);

      await _tapSection(tester, 'Arguments cliniques');
      expect(find.textContaining('v4_cardiorespiratory_001'), findsOneWidget);

      await _tapSection(tester, 'Contexte clinique');
      expect(find.textContaining('Région : Thorax / dos'), findsOneWidget);

      await _tapSection(tester, 'Traçabilité technique avancée');
      expect(find.textContaining('Niveau fourni : emergency'), findsOneWidget);
      expect(
        find.textContaining('v5_hard_stop_cardiorespiratoire'),
        findsNothing,
      );
      expect(
        find.textContaining('ClinicalAdaptiveQuestionEngineV5'),
        findsOneWidget,
      );
      expect(find.textContaining('0.1-experimental'), findsOneWidget);
      expect(find.textContaining('NON VALIDÉE'), findsOneWidget);

      await _scrollUntilText(tester, 'Revenir à l’accueil');
      await tester.tap(find.text('Revenir à l’accueil'));
      await tester.pumpAndSettle();

      expect(find.text('Thorax / Dos'), findsOneWidget);
      expect(find.text('Urgence médicale'), findsNothing);
    });

    testWidgets(
      'knee TVP pathway reaches the real vascular terminal state with explicit context',
      (tester) async {
        await _pumpStartScreen(
          tester,
          initialContext: const RadarClinicalInitialContext(
            gates: {RadarContextGate.recentImmobilization},
          ),
        );
        await _scrollUntilText(tester, 'Genou');
        await tester.tap(find.text('Genou'));
        await tester.pumpAndSettle();

        await _answerUntilQuestionContaining(
          tester,
          'facteurs de risque de TVP',
        );
        await tester.tap(find.text('Oui'));
        await tester.pumpAndSettle();

        expect(find.text('Urgence médicale'), findsOneWidget);
        expect(
          find.text('Suspicion TVP ou atteinte vasculaire'),
          findsOneWidget,
        );
        expect(
          find.textContaining('v5_hard_stop_vasculaire_tvp'),
          findsNothing,
        );
        expect(find.textContaining('Statut : suspecté'), findsOneWidget);
        expect(
          find.textContaining('Niveau fourni : urgentReferral'),
          findsNothing,
        );
        expect(find.textContaining('Région : Genou / jambe'), findsNothing);

        await _tapSection(tester, 'Arguments cliniques');
        expect(find.textContaining('v4_vascular_tvp_001'), findsOneWidget);

        await _tapSection(tester, 'Contexte clinique');
        expect(find.textContaining('Région : Genou / jambe'), findsOneWidget);

        await _tapSection(tester, 'Traçabilité technique avancée');
        expect(
          find.textContaining('Portes activées : recentImmobilization'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Niveau fourni : urgentReferral'),
          findsOneWidget,
        );
        expect(
          find.textContaining('v5_hard_stop_vasculaire_tvp'),
          findsNothing,
        );
        expect(find.textContaining('0.1-experimental'), findsOneWidget);
        expect(find.textContaining('NON VALIDÉE'), findsOneWidget);

        await _scrollUntilText(tester, 'Revenir à l’accueil');
        await tester.tap(find.text('Revenir à l’accueil'));
        await tester.pumpAndSettle();

        expect(find.byType(RadarClinicalStartScreen), findsOneWidget);
        expect(find.text('Urgence médicale'), findsNothing);
      },
    );

    testWidgets('non hard-stop delegation keeps question flow', (tester) async {
      final controller = RadarClinicalSessionController(
        orchestrator: RadarRegionalClinicalOrchestrator(
          engineAdapter: _RedFlagWithoutHardStopAdapter(),
          sessionIdFactory: () => 'radar-presentation-delegate-test',
        ),
      );
      final initialState = controller.startSession(
        region: RadarClinicalRegion.lumbar,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RadarClinicalQuestionScreen(
            controller: controller,
            initialState: initialState,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();

      expect(find.text('Urgence médicale'), findsNothing);
      expect(find.textContaining('La douleur thoracique'), findsOneWidget);
      expect(find.text('Oui'), findsOneWidget);
      expect(find.text('Non'), findsOneWidget);
    });
  });
}

Future<void> _scrollUntilText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    180,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
}

Future<void> _tapSection(WidgetTester tester, String title) async {
  await _scrollUntilText(tester, title);
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -120));
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _answerUntilSummary(
  WidgetTester tester, {
  String defaultAnswer = 'Non',
  String Function()? answerForCurrentQuestion,
}) async {
  var guard = 0;
  while (find.text('Oui').evaluate().isNotEmpty ||
      find.text('Non').evaluate().isNotEmpty) {
    final label = answerForCurrentQuestion?.call() ?? defaultAnswer;
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    guard++;
    if (guard > 20) {
      throw StateError('Radar summary was not reached.');
    }
  }
}

Future<void> _answerUntilQuestionContaining(
  WidgetTester tester,
  String text, {
  String defaultAnswer = 'Non',
}) async {
  var guard = 0;
  while (find.textContaining(text).evaluate().isEmpty) {
    await tester.tap(find.text(defaultAnswer));
    await tester.pumpAndSettle();
    guard++;
    if (guard > 20) {
      throw StateError('Radar question containing "$text" was not reached.');
    }
  }
}

RadarClinicalViewState _completeLumbarRoutineState() {
  final controller = RadarClinicalSessionController(
    orchestrator: RadarRegionalClinicalOrchestrator(),
  );
  var state = controller.startSession(region: RadarClinicalRegion.lumbar);

  var guard = 0;
  while (state.summary == null) {
    state = controller.answer(RadarClinicalAnswer.no);
    guard++;
    if (guard > 20) {
      throw StateError('Radar summary was not reached.');
    }
  }

  return state;
}

Future<void> _pumpStartScreen(
  WidgetTester tester, {
  NavigatorObserver? observer,
  RadarClinicalInitialContext initialContext =
      const RadarClinicalInitialContext(),
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: RadarClinicalStartScreen(initialContext: initialContext),
      navigatorObservers: [?observer],
    ),
  );
  await tester.pumpAndSettle();
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  int didPushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPushCount += 1;
    super.didPush(route, previousRoute);
  }
}

class _RedFlagWithoutHardStopAdapter extends RadarClinicalEngineAdapter {
  @override
  ClinicalAdaptiveSessionV5 initialSession() {
    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: const {},
      positiveFlagIds: const [],
      reassuringFlagIds: const [],
      hypothesisProbabilities: const {},
      appliedProbabilityUpdateIds: const [],
      triggeredHardStopIds: const [],
      nextQuestion: questionById('v4_queue_cheval_001'),
      reasoningSummary: 'Fake V5 state for Radar presentation delegation test.',
    );
  }

  @override
  ClinicalAdaptiveSessionV5 answerQuestion({
    required ClinicalAdaptiveSessionV5 session,
    required String questionId,
    required bool isPositive,
  }) {
    return ClinicalAdaptiveSessionV5(
      answeredQuestionIds: {
        ...session.answeredQuestionIds,
        questionId: isPositive,
      },
      positiveFlagIds: isPositive ? const ['fake_red_flag'] : const [],
      reassuringFlagIds: const [],
      hypothesisProbabilities: const {},
      appliedProbabilityUpdateIds: const [],
      triggeredHardStopIds: const [],
      nextQuestion: questionById('v4_cardiorespiratory_001'),
      reasoningSummary: 'Fake V5 red flag without hard stop.',
    );
  }

  @override
  ClinicalAdaptiveViewStateV5 map({
    required String sessionId,
    required ClinicalAdaptiveSessionV5 session,
  }) {
    final hasRedFlag = session.positiveFlagIds.isNotEmpty;
    return ClinicalAdaptiveViewStateV5(
      sessionId: sessionId,
      questionId: session.nextQuestion?.id,
      patientQuestionText: session.nextQuestion?.text,
      canAnswer: session.nextQuestion != null,
      answeredCount: session.answeredQuestionIds.length,
      totalQuestionCount: 2,
      progressRatio: session.answeredQuestionIds.length / 2,
      progressLabel: 'Fake V5',
      currentRiskLevel: hasRedFlag
          ? ClinicalDecisionLevel.medicalAdvice
          : ClinicalDecisionLevel.routine,
      currentRiskLabel: 'Fake V5',
      hardStopId: null,
      hardStopTitle: null,
      finalDecisionLevel: null,
      finalDecisionLabel: null,
      primaryHypothesisId: hasRedFlag ? 'fake' : null,
      primaryHypothesisTitle: hasRedFlag ? 'Fake' : null,
      probabilityLevel: hasRedFlag
          ? ClinicalQualitativeProbabilityV5.high
          : null,
      shortExplanation: 'Fake V5 state.',
      technicalSummary: session.reasoningSummary,
      isFinal: false,
    );
  }
}

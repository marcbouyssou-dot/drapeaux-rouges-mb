import 'dart:io';

import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/services/bdk_draft_service.dart';
import 'package:drapeaux_rouges_mb/services/bdk_session_service.dart';
import 'package:drapeaux_rouges_mb/services/history_service.dart';
import 'package:drapeaux_rouges_mb/services/local_database_service.dart';
import 'package:drapeaux_rouges_mb/services/rgpd_local_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('rgpd_service_test_');
    Hive.init(tempDir.path);

    await Hive.openBox('patients_box');
    await Hive.openBox('evaluations_box');
    await Hive.openBox('settings_box');
    await Hive.openBox(BdkDraftService.boxName);
    BDKSessionService.clear();
  });

  tearDown(() async {
    BDKSessionService.clear();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  PatientLocal buildPatient() {
    return PatientLocal(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      nom: 'Dupont',
      prenom: 'Alice',
      dateNaissance: '01/01/1980',
      consentementValide: true,
      dateConsentement: DateTime(2026, 1, 1),
    );
  }

  Map<String, dynamic> buildEvaluation() {
    return {
      'evaluationId': 'evaluation-1',
      'patientLocalId': 'patient-1',
      'patientAnonymousId': 'DR-patient-1',
      'patientDisplayName': 'DUPONT Alice',
      'date': DateTime(2026, 1, 2).toIso8601String(),
      'motif': 'Lombalgie',
      'score': 2,
      'riskLevel': 'Risque modéré',
      'checkedCount': 1,
      'checkedFlags': <Map<String, dynamic>>[],
      'decisionTitle': 'Vigilance clinique renforcée',
      'decisionMessage': 'Une surveillance clinique renforcée est recommandée.',
      'aiSummary': 'Synthèse test',
    };
  }

  test('deleting a patient anonymizes linked evaluations', () async {
    final patient = buildPatient();

    await RgpdLocalService.saveOrUpdatePatient(patient);
    await LocalDatabaseService.saveEvaluation(buildEvaluation());

    await RgpdLocalService.deletePatient(patient.localId);

    final evaluations = await HistoryService.loadHistory();

    expect(evaluations, hasLength(1));
    expect(evaluations.single['patientLocalId'], isNull);
    expect(evaluations.single['patientAnonymousId'], 'DR-patient-1');
    expect(evaluations.single['patientDisplayName'], 'Patient non renseigné');
  });

  test('deleting a patient removes its BDK draft and memory session', () async {
    final patient = buildPatient();
    await RgpdLocalService.saveOrUpdatePatient(patient);
    BDKSessionService.associatePatient(
      localId: patient.localId,
      anonymousId: patient.anonymousId,
      displayName: 'DUPONT Alice',
    );
    BDKSessionService.motif = 'BDK Lombalgie';
    await BdkDraftService.saveActiveDraft(title: 'BDK Lombalgie');

    await RgpdLocalService.deletePatient(patient.localId);

    expect(await BdkDraftService.getActiveDraft(), isNull);
    expect(BDKSessionService.hasDraftContent, isFalse);
    expect(BDKSessionService.patientLocalId, isNull);
  });

  test(
    'deleting patient A preserves patient B BDK draft and session',
    () async {
      final patientA = buildPatient();
      BDKSessionService.associatePatient(
        localId: 'patient-2',
        anonymousId: 'DR-patient-2',
        displayName: 'MARTIN Bob',
      );
      BDKSessionService.motif = 'BDK Genou';
      await BdkDraftService.saveActiveDraft(title: 'BDK Genou');

      await RgpdLocalService.deletePatient(patientA.localId);

      final draft = await BdkDraftService.getActiveDraft();
      expect(draft?['patientLocalId'], 'patient-2');
      expect(BDKSessionService.patientLocalId, 'patient-2');
      expect(BDKSessionService.motif, 'BDK Genou');
    },
  );

  test('patient deletion wins over an asynchronous draft save', () async {
    final patient = buildPatient();
    await RgpdLocalService.saveOrUpdatePatient(patient);
    BDKSessionService.associatePatient(
      localId: patient.localId,
      anonymousId: patient.anonymousId,
      displayName: 'DUPONT Alice',
    );
    BDKSessionService.motif = 'BDK Lombalgie';

    final pendingSave = BdkDraftService.saveActiveDraft(title: 'BDK Lombalgie');
    final deletion = RgpdLocalService.deletePatient(patient.localId);
    await Future.wait([pendingSave, deletion]);

    expect(await BdkDraftService.getActiveDraft(), isNull);
    expect(BDKSessionService.hasDraftContent, isFalse);
  });

  test('deleting all local RGPD data clears evaluation history', () async {
    await RgpdLocalService.saveOrUpdatePatient(buildPatient());
    await LocalDatabaseService.saveEvaluation(buildEvaluation());
    BDKSessionService.associatePatient(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      displayName: 'DUPONT Alice',
    );
    BDKSessionService.motif = 'BDK Lombalgie';
    await BdkDraftService.saveActiveDraft(title: 'BDK Lombalgie');
    await Hive.box(
      BdkDraftService.boxName,
    ).put('legacy_bdk_draft', {'motif': 'Ancien brouillon'});

    await RgpdLocalService.deleteAllLocalData();

    expect(await RgpdLocalService.getPatients(), isEmpty);
    expect(await HistoryService.loadHistory(), isEmpty);
    expect(Hive.box(BdkDraftService.boxName).isEmpty, isTrue);
    expect(BDKSessionService.hasDraftContent, isFalse);
    expect(BDKSessionService.patientLocalId, isNull);
  });
}

import 'dart:io';

import 'package:drapeaux_rouges_mb/models/patient_local.dart';
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
  });

  tearDown(() async {
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

  test('deleting all local RGPD data clears evaluation history', () async {
    await RgpdLocalService.saveOrUpdatePatient(buildPatient());
    await LocalDatabaseService.saveEvaluation(buildEvaluation());

    await RgpdLocalService.deleteAllLocalData();

    expect(await RgpdLocalService.getPatients(), isEmpty);
    expect(await HistoryService.loadHistory(), isEmpty);
  });
}

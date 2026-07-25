import 'dart:io';

import 'package:drapeaux_rouges_mb/services/bdk_draft_service.dart';
import 'package:drapeaux_rouges_mb/services/bdk_session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('bdk_draft_test_');
    Hive.init(tempDir.path);
    await Hive.openBox(BdkDraftService.boxName);
    await Hive.box(BdkDraftService.boxName).clear();
    BDKSessionService.clear();
  });

  tearDown(() async {
    BDKSessionService.clear();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('saveActiveDraft persists the active BDK session snapshot', () async {
    BDKSessionService.associatePatient(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      displayName: 'DUPONT Alice',
    );
    BDKSessionService.motif = 'BDK Lombalgie';
    BDKSessionService.evaluation = 'Mobilité lombaire limitée.';
    BDKSessionService.syntheseClinique = 'Synthèse en cours.';
    BDKSessionService.redFlags = ['Surveillance neurologique'];

    await BdkDraftService.saveActiveDraft(title: 'BDK Lombalgie');

    final draft = await BdkDraftService.getActiveDraft();

    expect(draft, isNotNull);
    expect(draft?['schemaVersion'], BDKSessionService.draftSchemaVersion);
    expect(draft?['title'], 'BDK Lombalgie');
    expect(draft?['patientLocalId'], 'patient-1');
    expect(draft?['patientAnonymousId'], 'DR-patient-1');
    expect(draft?['patientDisplayName'], 'DUPONT Alice');
    expect(draft?['motif'], 'BDK Lombalgie');
    expect(draft?['evaluation'], 'Mobilité lombaire limitée.');
    expect(draft?['syntheseClinique'], 'Synthèse en cours.');
    expect(draft?['redFlags'], ['Surveillance neurologique']);
    expect(draft?['updatedAt'], isA<String>());
  });

  test('restoreActiveDraft reloads a matching patient and BDK type', () async {
    BDKSessionService.associatePatient(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      displayName: 'DUPONT Alice',
    );
    BDKSessionService.motif = 'BDK Lombalgie';
    BDKSessionService.contexte = 'Douleur mécanique.';
    BDKSessionService.riskScore = 2;

    await BdkDraftService.saveActiveDraft(title: 'BDK Lombalgie');
    BDKSessionService.clear();

    final restored = await BdkDraftService.restoreActiveDraft(
      patientLocalId: 'patient-1',
      patientAnonymousId: 'DR-patient-1',
      title: 'BDK Lombalgie',
    );

    expect(restored, isTrue);
    expect(BDKSessionService.patientLocalId, 'patient-1');
    expect(BDKSessionService.patientAnonymousId, 'DR-patient-1');
    expect(BDKSessionService.patientDisplayName, 'DUPONT Alice');
    expect(BDKSessionService.motif, 'BDK Lombalgie');
    expect(BDKSessionService.contexte, 'Douleur mécanique.');
    expect(BDKSessionService.riskScore, 2);
  });

  test('restoreActiveDraft refuses a different patient', () async {
    BDKSessionService.associatePatient(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      displayName: 'DUPONT Alice',
    );
    BDKSessionService.motif = 'BDK Lombalgie';

    await BdkDraftService.saveActiveDraft(title: 'BDK Lombalgie');
    BDKSessionService.clear();

    final restored = await BdkDraftService.restoreActiveDraft(
      patientLocalId: 'patient-2',
      patientAnonymousId: 'DR-patient-2',
      title: 'BDK Lombalgie',
    );

    expect(restored, isFalse);
    expect(BDKSessionService.motif, isEmpty);
    expect(BDKSessionService.patientLocalId, isNull);
  });

  test('restoreActiveDraft refuses a different BDK type', () async {
    BDKSessionService.associatePatient(
      localId: 'patient-1',
      anonymousId: 'DR-patient-1',
      displayName: 'DUPONT Alice',
    );
    BDKSessionService.motif = 'BDK Lombalgie';

    await BdkDraftService.saveActiveDraft(title: 'BDK Lombalgie');
    BDKSessionService.clear();

    final restored = await BdkDraftService.restoreActiveDraft(
      patientLocalId: 'patient-1',
      patientAnonymousId: 'DR-patient-1',
      title: 'BDK Épaule',
    );

    expect(restored, isFalse);
    expect(BDKSessionService.motif, isEmpty);
  });

  test('clearActiveDraft deletes the durable BDK draft', () async {
    BDKSessionService.motif = 'BDK Genou';

    await BdkDraftService.saveActiveDraft(title: 'BDK Genou');
    await BdkDraftService.clearActiveDraft();

    expect(await BdkDraftService.getActiveDraft(), isNull);
  });

  test('BdkDraftService uses protected Hive storage outside test boxes', () {
    final source = File(
      'lib/services/bdk_draft_service.dart',
    ).readAsStringSync();

    expect(source, contains("static const String boxName = 'bdk_drafts_box'"));
    expect(source, contains('SecureHiveService.openProtectedBox(boxName)'));
  });
}

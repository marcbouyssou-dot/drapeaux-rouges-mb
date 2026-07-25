import 'dart:io';

import 'package:drapeaux_rouges_mb/models/bdk_history_item.dart';
import 'package:drapeaux_rouges_mb/services/bdk_history_service.dart';
import 'package:drapeaux_rouges_mb/services/bdk_session_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveDirectory;

  setUp(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('bdk_history_test_');
    Hive.init(hiveDirectory.path);
    await Hive.openBox(BdkHistoryService.boxName);
    await BdkHistoryService.clearHistory();
    BDKSessionService.clear();
  });

  tearDown(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
    BDKSessionService.clear();
  });

  test('saves and restores a completed BDK snapshot', () async {
    final item = _item(id: 'bdk-a', patientLocalId: 'patient-a');

    await BdkHistoryService.save(item);

    final restored = (await BdkHistoryService.getHistory()).single;
    expect(restored.id, 'bdk-a');
    expect(restored.title, 'BDK membre inférieur');
    expect(restored.displayPatient, 'PATIENT A');
    expect(restored.motif, 'Douleur du genou');
    expect(restored.updatedAt, item.updatedAt);
  });

  test('patient deletion preserves BDKs belonging to another patient', () async {
    await BdkHistoryService.save(
      _item(id: 'bdk-a', patientLocalId: 'patient-a'),
    );
    await BdkHistoryService.save(
      _item(id: 'bdk-b', patientLocalId: 'patient-b'),
    );

    await BdkHistoryService.deleteForPatient('patient-a', 'anonymous-a');

    final remaining = await BdkHistoryService.getHistory();
    expect(remaining, hasLength(1));
    expect(remaining.single.id, 'bdk-b');
    expect(remaining.single.patientLocalId, 'patient-b');
  });

  test('clearHistory removes known and unknown keys', () async {
    await BdkHistoryService.save(
      _item(id: 'bdk-a', patientLocalId: 'patient-a'),
    );
    await Hive.box(BdkHistoryService.boxName).put('legacy_key', 'value');

    await BdkHistoryService.clearHistory();

    expect(Hive.box(BdkHistoryService.boxName).isEmpty, isTrue);
  });

  test('reading history never changes the active BDK session', () async {
    BDKSessionService.motif = 'Brouillon actif';
    BDKSessionService.patientLocalId = 'active-patient';
    await BdkHistoryService.save(
      _item(id: 'history', patientLocalId: 'historic-patient'),
    );

    await BdkHistoryService.getHistory();

    expect(BDKSessionService.motif, 'Brouillon actif');
    expect(BDKSessionService.patientLocalId, 'active-patient');
  });
}

BdkHistoryItem _item({
  required String id,
  required String patientLocalId,
}) {
  final generatedAt = DateTime.utc(2026, 7, 25, 10);
  return BdkHistoryItem(
    id: id,
    title: 'BDK membre inférieur',
    generatedAt: generatedAt,
    updatedAt: generatedAt.add(const Duration(minutes: 5)),
    patientLocalId: patientLocalId,
    patientAnonymousId: patientLocalId.replaceFirst('patient', 'anonymous'),
    patientDisplayName: patientLocalId == 'patient-a'
        ? 'PATIENT A'
        : 'PATIENT B',
    motif: 'Douleur du genou',
    contexte: 'Contexte',
    antecedents: 'Antécédents',
    evaluation: 'Évaluation',
    tests: 'Tests',
    limitations: 'Limitations',
    diagnostic: 'Diagnostic',
    vigilance: 'Vigilance',
    objectifs: 'Objectifs',
    planTraitement: 'Plan',
    criteresReevaluation: 'Critères',
    syntheseClinique: 'Synthèse',
    patientSnapshot: null,
    practitionerSnapshot: const {},
  );
}

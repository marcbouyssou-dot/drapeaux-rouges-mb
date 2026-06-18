import 'dart:io';

import 'package:drapeaux_rouges_mb/services/connectivity_service.dart';
import 'package:drapeaux_rouges_mb/services/local_database_service.dart';
import 'package:drapeaux_rouges_mb/services/offline_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_sync_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('evaluations_box');
    ConnectivityService.instance.clearTestOverride();
  });

  tearDown(() async {
    ConnectivityService.instance.clearTestOverride();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('offline creation is marked pendingSync', () async {
    ConnectivityService.instance.emitStatusForTests(false);

    final evaluation = buildEvaluation('evaluation-offline');
    await OfflineSyncService().enrichForLocalSave(evaluation);
    await LocalDatabaseService.saveEvaluation(evaluation);

    final saved = await LocalDatabaseService.getEvaluations();
    expect(saved.single['localId'], 'evaluation-offline');
    expect(saved.single['idempotencyKey'], 'evaluation-offline');
    expect(saved.single['syncStatus'], SyncStatus.pendingSync.storageValue);
  });

  test(
    'online sync marks pending evaluation as synced after remote success',
    () async {
      ConnectivityService.instance.emitStatusForTests(true);

      await savePendingEvaluation('evaluation-sync-success');
      final remote = _FakeRemoteDataSource([const SyncResult.success()]);

      final syncedCount = await OfflineSyncService(
        remoteDataSource: remote,
      ).syncPendingEvaluations();

      final saved = await LocalDatabaseService.getEvaluations();
      expect(syncedCount, 1);
      expect(saved.single['syncStatus'], SyncStatus.synced.storageValue);
      expect(saved.single['syncedAt'], isNotNull);
      expect(saved.single['lastSyncError'], isNull);
      expect(remote.sentIdempotencyKeys, ['evaluation-sync-success']);
    },
  );

  test('remote failure keeps local data and marks syncFailed', () async {
    ConnectivityService.instance.emitStatusForTests(true);

    await savePendingEvaluation('evaluation-sync-failure');
    final remote = _FakeRemoteDataSource([
      const SyncResult.failure('Serveur indisponible'),
    ]);

    final syncedCount = await OfflineSyncService(
      remoteDataSource: remote,
    ).syncPendingEvaluations();

    final saved = await LocalDatabaseService.getEvaluations();
    expect(syncedCount, 0);
    expect(saved.single['syncStatus'], SyncStatus.syncFailed.storageValue);
    expect(saved.single['lastSyncError'], 'Serveur indisponible');
  });

  test(
    'retry sends syncFailed evaluation and marks it synced on success',
    () async {
      ConnectivityService.instance.emitStatusForTests(true);

      await savePendingEvaluation('evaluation-sync-retry');
      final remote = _FakeRemoteDataSource([
        const SyncResult.failure('Timeout'),
        const SyncResult.success(),
      ]);
      final service = OfflineSyncService(remoteDataSource: remote);

      await service.syncPendingEvaluations();
      final retriedCount = await service.syncPendingEvaluations();

      final saved = await LocalDatabaseService.getEvaluations();
      expect(retriedCount, 1);
      expect(saved.single['syncStatus'], SyncStatus.synced.storageValue);
      expect(remote.sentIdempotencyKeys, [
        'evaluation-sync-retry',
        'evaluation-sync-retry',
      ]);
    },
  );

  test('synced evaluations are not sent twice', () async {
    ConnectivityService.instance.emitStatusForTests(true);

    await savePendingEvaluation('evaluation-no-duplicate');
    final remote = _FakeRemoteDataSource([
      const SyncResult.success(),
      const SyncResult.success(),
    ]);
    final service = OfflineSyncService(remoteDataSource: remote);

    await service.syncPendingEvaluations();
    final secondCount = await service.syncPendingEvaluations();

    expect(secondCount, 0);
    expect(remote.sentIdempotencyKeys, ['evaluation-no-duplicate']);
  });
}

Map<String, dynamic> buildEvaluation(String id) {
  return {
    'evaluationId': id,
    'date': DateTime(2026, 6, 18).toIso8601String(),
    'motif': 'Lombalgie aiguë',
    'score': 1,
    'riskLevel': 'Faible',
    'checkedCount': 0,
  };
}

Future<void> savePendingEvaluation(String id) async {
  final evaluation = buildEvaluation(id)
    ..['localId'] = id
    ..['idempotencyKey'] = id
    ..['syncStatus'] = SyncStatus.pendingSync.storageValue;
  await LocalDatabaseService.saveEvaluation(evaluation);
}

class _FakeRemoteDataSource implements OfflineSyncRemoteDataSource {
  _FakeRemoteDataSource(this.results);

  final List<SyncResult> results;
  final List<String> sentIdempotencyKeys = [];

  @override
  Future<SyncResult> sendEvaluation(Map<String, dynamic> evaluation) async {
    sentIdempotencyKeys.add(evaluation['idempotencyKey'].toString());
    if (results.isEmpty) return const SyncResult.success();
    return results.removeAt(0);
  }
}

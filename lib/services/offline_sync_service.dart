import 'connectivity_service.dart';
import 'local_database_service.dart';

enum SyncStatus {
  localOnly,
  pendingSync,
  syncing,
  synced,
  syncFailed;

  String get storageValue => name;

  static SyncStatus fromValue(Object? value) {
    return SyncStatus.values.firstWhere(
      (status) => status.storageValue == value?.toString(),
      orElse: () => SyncStatus.localOnly,
    );
  }
}

class SyncResult {
  const SyncResult.success() : error = null;
  const SyncResult.failure(this.error);

  final String? error;

  bool get isSuccess => error == null;
}

abstract class OfflineSyncRemoteDataSource {
  Future<SyncResult> sendEvaluation(Map<String, dynamic> evaluation);
}

class LocalOnlySyncRemoteDataSource implements OfflineSyncRemoteDataSource {
  const LocalOnlySyncRemoteDataSource();

  @override
  Future<SyncResult> sendEvaluation(Map<String, dynamic> evaluation) async {
    return const SyncResult.failure(
      'Aucun stockage distant configuré pour cette version.',
    );
  }
}

class OfflineSyncService {
  OfflineSyncService({
    ConnectivityService? connectivityService,
    OfflineSyncRemoteDataSource? remoteDataSource,
  }) : connectivityService =
           connectivityService ?? ConnectivityService.instance,
       remoteDataSource =
           remoteDataSource ?? const LocalOnlySyncRemoteDataSource();

  final ConnectivityService connectivityService;
  final OfflineSyncRemoteDataSource remoteDataSource;

  Future<void> enrichForLocalSave(Map<String, dynamic> evaluation) async {
    final now = DateTime.now().toIso8601String();
    final localId = evaluation['localId']?.toString().isNotEmpty == true
        ? evaluation['localId'].toString()
        : evaluation['evaluationId']?.toString();

    evaluation['localId'] = localId;
    evaluation['idempotencyKey'] ??= localId;
    evaluation['createdAt'] ??= evaluation['date'] ?? now;
    evaluation['updatedAt'] = now;
    evaluation.putIfAbsent('syncedAt', () => null);
    evaluation.putIfAbsent('lastSyncError', () => null);

    final currentStatus = SyncStatus.fromValue(evaluation['syncStatus']);
    if (!connectivityService.isOnline) {
      evaluation['syncStatus'] = SyncStatus.pendingSync.storageValue;
      return;
    }

    if (currentStatus == SyncStatus.pendingSync ||
        currentStatus == SyncStatus.syncFailed) {
      return;
    }

    evaluation['syncStatus'] = SyncStatus.localOnly.storageValue;
  }

  Future<int> syncPendingEvaluations() async {
    if (!connectivityService.isOnline) return 0;

    final evaluations = await LocalDatabaseService.getEvaluations();
    var syncedCount = 0;

    for (final evaluation in evaluations) {
      final status = SyncStatus.fromValue(evaluation['syncStatus']);
      if (status != SyncStatus.pendingSync && status != SyncStatus.syncFailed) {
        continue;
      }

      final id = evaluation['evaluationId']?.toString() ?? '';
      if (id.isEmpty) continue;

      evaluation['syncStatus'] = SyncStatus.syncing.storageValue;
      evaluation['updatedAt'] = DateTime.now().toIso8601String();
      await LocalDatabaseService.saveEvaluation(evaluation);

      final result = await remoteDataSource.sendEvaluation(evaluation);
      evaluation['updatedAt'] = DateTime.now().toIso8601String();

      if (result.isSuccess) {
        evaluation['syncStatus'] = SyncStatus.synced.storageValue;
        evaluation['syncedAt'] = DateTime.now().toIso8601String();
        evaluation['lastSyncError'] = null;
        syncedCount++;
      } else {
        evaluation['syncStatus'] = SyncStatus.syncFailed.storageValue;
        evaluation['lastSyncError'] = result.error;
      }

      await LocalDatabaseService.saveEvaluation(evaluation);
    }

    return syncedCount;
  }
}

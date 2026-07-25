import 'package:hive_flutter/hive_flutter.dart';

import '../models/bdk_history_item.dart';
import 'secure_hive_service.dart';

class BdkHistoryService {
  static const String boxName = 'bdk_history_box';
  static const String _historyKey = 'bdk_history';
  static Future<void> _mutationQueue = Future<void>.value();

  static Future<Box> _openBox() {
    return SecureHiveService.openProtectedBox(boxName);
  }

  static Future<List<BdkHistoryItem>> getHistory() async {
    final box = await _openBox();
    final raw = box.get(_historyKey);
    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map(
          (item) => BdkHistoryItem.tryFromMap(Map<String, dynamic>.from(item)),
        )
        .whereType<BdkHistoryItem>()
        .toList();
  }

  static Future<void> save(BdkHistoryItem item) async {
    await _serializeMutation(() async {
      final history = await getHistory();
      history.removeWhere((existing) => existing.id == item.id);
      history.insert(0, item);
      final box = await _openBox();
      await box.put(
        _historyKey,
        history.map((entry) => entry.toMap()).toList(),
      );
    });
  }

  static Future<void> deleteById(String id) async {
    await _serializeMutation(() async {
      final history = await getHistory();
      history.removeWhere((item) => item.id == id);
      final box = await _openBox();
      await box.put(
        _historyKey,
        history.map((entry) => entry.toMap()).toList(),
      );
    });
  }

  static Future<void> deleteForPatient(
    String localId,
    String anonymousId,
  ) async {
    await _serializeMutation(() async {
      final normalizedLocalId = localId.trim();
      final normalizedAnonymousId = anonymousId.trim();
      final history = await getHistory();
      history.removeWhere(
        (item) =>
            (normalizedLocalId.isNotEmpty &&
                item.patientLocalId.trim() == normalizedLocalId) ||
            (normalizedAnonymousId.isNotEmpty &&
                item.patientAnonymousId.trim() == normalizedAnonymousId),
      );
      final box = await _openBox();
      await box.put(
        _historyKey,
        history.map((entry) => entry.toMap()).toList(),
      );
    });
  }

  static Future<void> clearHistory() async {
    await _serializeMutation(() async {
      final box = await _openBox();
      await box.clear();
    });
  }

  static Future<void> _serializeMutation(Future<void> Function() mutation) {
    final operation = _mutationQueue.then((_) => mutation());
    _mutationQueue = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return operation;
  }
}

import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import 'bdk_session_service.dart';
import 'secure_hive_service.dart';

class BdkDraftService {
  static const String boxName = 'bdk_drafts_box';
  static const String _activeDraftKey = 'active_bdk_draft';

  static Future<void> _pendingMutation = Future<void>.value();

  static Future<Box> _openBox() {
    if (Hive.isBoxOpen(boxName)) {
      return Future.value(Hive.box(boxName));
    }

    return SecureHiveService.openProtectedBox(boxName);
  }

  static Future<void> saveActiveDraft({
    required String title,
    String? customContext,
  }) async {
    if (!BDKSessionService.hasDraftContent) {
      await clearActiveDraft();
      return;
    }

    final draft = BDKSessionService.toDraftMap(
      title: title,
      customContext: customContext,
      updatedAt: DateTime.now(),
    );

    await _runSerialized(() async {
      final box = await _openBox();
      await box.put(_activeDraftKey, draft);
    });
  }

  static Future<bool> restoreActiveDraft({
    required String? patientLocalId,
    required String? patientAnonymousId,
    required String title,
  }) async {
    final draft = await getActiveDraft();
    if (draft == null) return false;

    if (_intValue(draft['schemaVersion']) !=
        BDKSessionService.draftSchemaVersion) {
      return false;
    }

    if (!_matchesPatient(draft, patientLocalId, patientAnonymousId)) {
      return false;
    }

    if (_stringValue(draft['title']) != title.trim()) {
      return false;
    }

    BDKSessionService.loadFromDraftMap(draft);
    return true;
  }

  static Future<Map<String, dynamic>?> getActiveDraft() async {
    await _pendingMutation;
    final box = await _openBox();
    final raw = box.get(_activeDraftKey);
    if (raw is! Map) return null;

    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  static Future<void> clearActiveDraft() async {
    await _runSerialized(() async {
      final box = await _openBox();
      await box.delete(_activeDraftKey);
    });
  }

  static Future<void> deleteDraftForPatient(String patientLocalId) async {
    final normalizedPatientLocalId = patientLocalId.trim();
    if (normalizedPatientLocalId.isEmpty) return;

    await _runSerialized(() async {
      final box = await _openBox();
      final raw = box.get(_activeDraftKey);
      if (raw is! Map) return;

      final draft = raw.map((key, value) => MapEntry(key.toString(), value));
      if (_stringValue(draft['patientLocalId']) == normalizedPatientLocalId) {
        await box.delete(_activeDraftKey);
      }
    });
  }

  static Future<void> clearAllDrafts() async {
    await _runSerialized(() async {
      final box = await _openBox();
      await box.clear();
    });
  }

  static bool _matchesPatient(
    Map<String, dynamic> draft,
    String? patientLocalId,
    String? patientAnonymousId,
  ) {
    final draftLocalId = _stringValue(draft['patientLocalId']);
    final draftAnonymousId = _stringValue(draft['patientAnonymousId']);
    final targetLocalId = patientLocalId?.trim() ?? '';
    final targetAnonymousId = patientAnonymousId?.trim() ?? '';

    if (targetLocalId.isEmpty && targetAnonymousId.isEmpty) {
      return draftLocalId.isEmpty && draftAnonymousId.isEmpty;
    }

    if (draftLocalId.isNotEmpty && targetLocalId.isNotEmpty) {
      return draftLocalId == targetLocalId;
    }

    if (draftAnonymousId.isNotEmpty && targetAnonymousId.isNotEmpty) {
      return draftAnonymousId == targetAnonymousId;
    }

    return false;
  }

  static String _stringValue(Object? value) {
    return value?.toString().trim() ?? '';
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static Future<T> _runSerialized<T>(Future<T> Function() operation) async {
    final previousMutation = _pendingMutation;
    final completer = Completer<void>();
    _pendingMutation = completer.future;

    try {
      await previousMutation;
      return await operation();
    } finally {
      completer.complete();
    }
  }
}

import 'package:hive_flutter/hive_flutter.dart';

import 'bdk_session_service.dart';
import 'secure_hive_service.dart';

class BdkDraftService {
  static const String boxName = 'bdk_drafts_box';
  static const String _activeDraftKey = 'active_bdk_draft';

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

    final box = await _openBox();
    await box.put(
      _activeDraftKey,
      BDKSessionService.toDraftMap(
        title: title,
        customContext: customContext,
        updatedAt: DateTime.now(),
      ),
    );
  }

  static Future<bool> restoreActiveDraft({
    required String? patientLocalId,
    required String? patientAnonymousId,
    required String title,
  }) async {
    final draft = await getActiveDraft();
    if (draft == null) return false;

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
    final box = await _openBox();
    final raw = box.get(_activeDraftKey);
    if (raw is! Map) return null;

    return raw.map((key, value) => MapEntry(key.toString(), value));
  }

  static Future<void> clearActiveDraft() async {
    final box = await _openBox();
    await box.delete(_activeDraftKey);
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
}

import 'package:hive_flutter/hive_flutter.dart';

import '../models/attestation/attestation_history_item.dart';
import 'secure_hive_service.dart';

class AttestationHistoryService {
  static const String boxName = 'attestations_box';
  static const String _key = 'attestations_history';
  static Future<void> _mutationQueue = Future<void>.value();

  static Future<Box> _openBox() {
    if (Hive.isBoxOpen(boxName)) {
      return Future.value(Hive.box(boxName));
    }

    return SecureHiveService.openProtectedBox(boxName);
  }

  static Future<void> saveAttestation(
    AttestationHistoryItem attestation,
  ) async {
    await _serializeMutation(() async {
      final attestations = await getAttestations();
      attestations.removeWhere((item) => item.id == attestation.id);
      attestations.insert(0, attestation);

      final box = await _openBox();
      await box.put(_key, attestations.map((item) => item.toMap()).toList());
    });
  }

  static Future<List<AttestationHistoryItem>> getAttestations() async {
    final box = await _openBox();
    final raw = box.get(_key);

    if (raw is! List) return [];

    final attestations = raw
        .whereType<Map>()
        .map(
          (item) => AttestationHistoryItem.tryFromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .whereType<AttestationHistoryItem>()
        .toList();

    attestations.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

    return attestations;
  }

  static Future<void> deleteById(String id) async {
    await _serializeMutation(() async {
      final attestations = await getAttestations();
      attestations.removeWhere((item) => item.id == id);

      final box = await _openBox();
      await box.put(_key, attestations.map((item) => item.toMap()).toList());
    });
  }

  static Future<void> deleteForPatient(
    String localId,
    String anonymousId,
  ) async {
    await _serializeMutation(() async {
      final normalizedLocalId = localId.trim();
      final normalizedAnonymousId = anonymousId.trim();
      final attestations = await getAttestations();

      attestations.removeWhere(
        (item) =>
            (normalizedLocalId.isNotEmpty &&
                item.patientLocalId.trim() == normalizedLocalId) ||
            (normalizedAnonymousId.isNotEmpty &&
                item.patientAnonymousId.trim() == normalizedAnonymousId),
      );

      final box = await _openBox();
      await box.put(_key, attestations.map((item) => item.toMap()).toList());
    });
  }

  static Future<void> clearAttestations() async {
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

import 'package:hive_flutter/hive_flutter.dart';

import '../models/attestation/attestation_history_item.dart';
import 'secure_hive_service.dart';

class AttestationHistoryService {
  static const String boxName = 'attestations_box';
  static const String _key = 'attestations_history';

  static Future<Box> _openBox() {
    if (Hive.isBoxOpen(boxName)) {
      return Future.value(Hive.box(boxName));
    }

    return SecureHiveService.openProtectedBox(boxName);
  }

  static Future<void> saveAttestation(
    AttestationHistoryItem attestation,
  ) async {
    final attestations = await getAttestations();
    attestations.removeWhere((item) => item.id == attestation.id);
    attestations.insert(0, attestation);

    final box = await _openBox();
    await box.put(_key, attestations.map((item) => item.toMap()).toList());
  }

  static Future<List<AttestationHistoryItem>> getAttestations() async {
    final box = await _openBox();
    final raw = box.get(_key);

    if (raw is! List) return [];

    final attestations = raw
        .whereType<Map>()
        .map(
          (item) =>
              AttestationHistoryItem.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();

    attestations.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

    return attestations;
  }

  static Future<void> clearAttestations() async {
    final box = await _openBox();
    await box.delete(_key);
  }
}

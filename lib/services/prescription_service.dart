import 'package:hive_flutter/hive_flutter.dart';

import '../models/prescription_model.dart';
import 'secure_hive_service.dart';

class PrescriptionService {
  static const String _boxName = 'prescriptions_box';
  static const String _key = 'prescriptions_history';
  static Future<void> _mutationQueue = Future<void>.value();

  static Future<Box> _openBox() {
    return SecureHiveService.openProtectedBox(_boxName);
  }

  static Future<void> savePrescription(PrescriptionModel prescription) async {
    await _serializeMutation(() async {
      final prescriptions = await getPrescriptions();
      prescriptions.removeWhere((item) => item.id == prescription.id);
      prescriptions.insert(0, prescription);

      final box = await _openBox();
      await box.put(_key, prescriptions.map((item) => item.toMap()).toList());
    });
  }

  static Future<List<PrescriptionModel>> getPrescriptions() async {
    final box = await _openBox();
    final raw = box.get(_key);

    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map(
          (item) =>
              PrescriptionModel.tryFromMap(Map<String, dynamic>.from(item)),
        )
        .whereType<PrescriptionModel>()
        .toList();
  }

  static Future<void> deleteById(String id) async {
    await _serializeMutation(() async {
      final prescriptions = await getPrescriptions();
      prescriptions.removeWhere((item) => item.id == id);

      final box = await _openBox();
      await box.put(_key, prescriptions.map((item) => item.toMap()).toList());
    });
  }

  static Future<void> deleteForPatient(
    String localId,
    String anonymousId,
  ) async {
    await _serializeMutation(() async {
      final normalizedLocalId = localId.trim();
      final normalizedAnonymousId = anonymousId.trim();
      final prescriptions = await getPrescriptions();

      prescriptions.removeWhere(
        (item) =>
            (normalizedLocalId.isNotEmpty &&
                item.patientLocalId.trim() == normalizedLocalId) ||
            (normalizedAnonymousId.isNotEmpty &&
                item.patientAnonymousId.trim() == normalizedAnonymousId),
      );

      final box = await _openBox();
      await box.put(_key, prescriptions.map((item) => item.toMap()).toList());
    });
  }

  static Future<void> clearPrescriptions() async {
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

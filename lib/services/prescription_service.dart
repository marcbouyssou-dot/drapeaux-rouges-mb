import 'package:hive_flutter/hive_flutter.dart';

import '../models/prescription_model.dart';
import 'secure_hive_service.dart';

class PrescriptionService {
  static const String _boxName = 'prescriptions_box';
  static const String _key = 'prescriptions_history';

  static Future<Box> _openBox() {
    return SecureHiveService.openProtectedBox(_boxName);
  }

  static Future<void> savePrescription(PrescriptionModel prescription) async {
    final prescriptions = await getPrescriptions();
    prescriptions.removeWhere((item) => item.id == prescription.id);
    prescriptions.insert(0, prescription);

    final box = await _openBox();
    await box.put(_key, prescriptions.map((item) => item.toMap()).toList());
  }

  static Future<List<PrescriptionModel>> getPrescriptions() async {
    final box = await _openBox();
    final raw = box.get(_key);

    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map(
          (item) => PrescriptionModel.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Future<void> clearPrescriptions() async {
    final box = await _openBox();
    await box.delete(_key);
  }
}

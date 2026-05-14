import '../models/prescription_model.dart';

class PrescriptionService {
  static final List<PrescriptionModel> _prescriptions = [];

  static Future<void> savePrescription(
    PrescriptionModel prescription,
  ) async {
    _prescriptions.insert(0, prescription);
  }

  static Future<List<PrescriptionModel>> getPrescriptions() async {
    return _prescriptions;
  }

  static Future<void> clearPrescriptions() async {
    _prescriptions.clear();
  }
}
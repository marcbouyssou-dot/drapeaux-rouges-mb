import 'dart:io';

import 'package:drapeaux_rouges_mb/models/prescription_model.dart';
import 'package:drapeaux_rouges_mb/services/prescription_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'prescription_service_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox('prescriptions_box');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('deletes one prescription by id', () async {
    await PrescriptionService.savePrescription(_prescription('prescription-1'));
    await PrescriptionService.savePrescription(_prescription('prescription-2'));

    await PrescriptionService.deleteById('prescription-1');

    final saved = await PrescriptionService.getPrescriptions();
    expect(saved, hasLength(1));
    expect(saved.single.id, 'prescription-2');
  });
}

PrescriptionModel _prescription(String id) {
  return PrescriptionModel(
    id: id,
    professional: 'Camille DURAND',
    patient: 'Alice DUPONT',
    patientLocalId: 'patient-1',
    patientAnonymousId: 'DR-patient-1',
    clinicalContext: 'Lombalgie',
    prescription: 'Rééducation',
    frequency: '',
    duration: '',
    nomenclature: '',
    createdAt: DateTime(2026, 1, 3),
  );
}

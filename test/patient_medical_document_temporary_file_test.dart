import 'dart:convert';
import 'dart:io';

import 'package:drapeaux_rouges_mb/core/utils/selected_document_data.dart';
import 'package:drapeaux_rouges_mb/models/patient_local.dart';
import 'package:drapeaux_rouges_mb/services/rgpd_local_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'patient_medical_document_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox('patients_box');
    await Hive.openBox('settings_box');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('camera document persists without path and deletes capture', () async {
    final cameraFile = File('${tempDir.path}/camera-document.jpg');
    await cameraFile.writeAsBytes([1, 2, 3]);
    final selected = await SelectedDocumentData.read(
      file: XFile(cameraFile.path),
      source: ImageSource.camera,
    );

    try {
      await _savePatientWith(_documentFrom(selected));
    } finally {
      await selected.deleteTemporaryCameraFile();
    }

    final restored = await RgpdLocalService.getPatientByLocalId('patient-1');
    final document = restored!.medicalDocuments.single;
    expect(document.documentName, 'camera-document.jpg');
    expect(document.documentBase64, base64Encode([1, 2, 3]));
    expect(document.documentPath, isNull);
    expect(document.hasStoredDocument, isTrue);
    expect(await cameraFile.exists(), isFalse);
  });

  test('gallery document persists without deleting user file', () async {
    final galleryFile = File('${tempDir.path}/gallery-document.jpg');
    await galleryFile.writeAsBytes([4, 5, 6]);
    final selected = await SelectedDocumentData.read(
      file: XFile(galleryFile.path),
      source: ImageSource.gallery,
    );

    try {
      await _savePatientWith(_documentFrom(selected));
    } finally {
      await selected.deleteTemporaryCameraFile();
    }

    final restored = await RgpdLocalService.getPatientByLocalId('patient-1');
    final document = restored!.medicalDocuments.single;
    expect(document.documentName, 'gallery-document.jpg');
    expect(document.documentBase64, base64Encode([4, 5, 6]));
    expect(document.documentPath, isNull);
    expect(document.hasStoredDocument, isTrue);
    expect(await galleryFile.exists(), isTrue);
  });

  test('restores document from name and base64 alone', () async {
    await _savePatientWith(
      PatientMedicalDocument(
        type: 'Courrier médical',
        documentName: 'courrier.jpg',
        documentBase64: base64Encode([7, 8]),
      ),
    );

    final restored = await RgpdLocalService.getPatientByLocalId('patient-1');
    final document = restored!.medicalDocuments.single;
    expect(document.documentName, 'courrier.jpg');
    expect(document.documentPath, isNull);
    expect(document.hasStoredDocument, isTrue);
  });

  test('historical path alone is not a stored document', () {
    const document = PatientMedicalDocument(
      type: 'Prescription médicale',
      documentPath: '/legacy/cache/prescription.jpg',
      documentName: 'prescription.jpg',
    );

    expect(document.hasStoredDocument, isFalse);
  });

  test('historical path with valid base64 remains readable', () {
    final document = PatientMedicalDocument(
      type: 'Prescription médicale',
      documentPath: '/legacy/cache/prescription.jpg',
      documentName: 'prescription.jpg',
      documentBase64: base64Encode([9]),
    );

    expect(document.hasStoredDocument, isTrue);
  });

  test('invalid base64 is absent without throwing', () {
    const document = PatientMedicalDocument(
      type: 'Prescription médicale',
      documentBase64: 'invalid base64',
    );

    expect(document.hasStoredDocument, isFalse);
  });

  test('failed replacement leaves previous document unchanged', () async {
    final previous = PatientMedicalDocument(
      type: 'Prescription médicale',
      documentName: 'previous.jpg',
      documentBase64: base64Encode([10]),
    );
    final documents = [previous];

    await expectLater(
      SelectedDocumentData.read(
        file: XFile('${tempDir.path}/missing-camera.jpg'),
        source: ImageSource.camera,
      ),
      throwsA(isA<FileSystemException>()),
    );

    expect(documents.single, same(previous));
  });

  test('successful replacement uses new base64 and cleans camera', () async {
    final previous = PatientMedicalDocument(
      type: 'Prescription médicale',
      documentName: 'previous.jpg',
      documentBase64: base64Encode([11]),
    );
    final cameraFile = File('${tempDir.path}/replacement.jpg');
    await cameraFile.writeAsBytes([12, 13]);
    final selected = await SelectedDocumentData.read(
      file: XFile(cameraFile.path),
      source: ImageSource.camera,
    );
    final documents = [previous];

    try {
      documents
        ..removeWhere((item) => item.type == previous.type)
        ..add(_documentFrom(selected));
    } finally {
      await selected.deleteTemporaryCameraFile();
    }

    expect(documents.single.documentName, 'replacement.jpg');
    expect(documents.single.documentBase64, base64Encode([12, 13]));
    expect(await cameraFile.exists(), isFalse);
  });

  test(
    'removal changes only patient model and keeps historical file',
    () async {
      final galleryFile = File('${tempDir.path}/legacy-gallery.jpg');
      await galleryFile.writeAsBytes([14]);
      await _savePatientWith(
        PatientMedicalDocument(
          type: 'Prescription médicale',
          documentPath: galleryFile.path,
          documentName: 'legacy-gallery.jpg',
          documentBase64: base64Encode([14]),
        ),
      );
      final existing = await RgpdLocalService.getPatientByLocalId('patient-1');

      await RgpdLocalService.saveOrUpdatePatient(
        _patient(medicalDocuments: const []),
      );

      final restored = await RgpdLocalService.getPatientByLocalId('patient-1');
      expect(existing!.medicalDocuments, hasLength(1));
      expect(restored!.medicalDocuments, isEmpty);
      expect(await galleryFile.exists(), isTrue);
    },
  );

  test('patient screen uses selected data without durable path', () {
    final source = File(
      'lib/screens/patient_consent_screen.dart',
    ).readAsStringSync();
    final pickStart = source.indexOf(
      'Future<void> pickPatientMedicalDocument({',
    );
    final nextMethod = source.indexOf(
      '\n  void removePatientMedicalDocument',
      pickStart,
    );
    final pickMethod = source.substring(pickStart, nextMethod);

    expect(pickMethod, contains('SelectedDocumentData.read('));
    expect(pickMethod, contains('documentPath: null'));
    expect(pickMethod, contains('documentName: selected.filename'));
    expect(pickMethod, contains('documentBase64: selected.base64Data'));
    expect(pickMethod, contains('finally {'));
    expect(pickMethod, contains('deleteTemporaryCameraFile()'));
    expect(pickMethod, isNot(contains('document.path')));
    expect(pickMethod, isNot(contains('document.readAsBytes()')));
  });
}

PatientMedicalDocument _documentFrom(SelectedDocumentData selected) {
  return PatientMedicalDocument(
    type: 'Prescription médicale',
    documentPath: null,
    documentName: selected.filename,
    documentBase64: selected.base64Data,
    documentAddedAt: '2026-07-25T14:00:00.000',
  );
}

Future<void> _savePatientWith(PatientMedicalDocument document) {
  return RgpdLocalService.saveOrUpdatePatient(
    _patient(medicalDocuments: [document]),
  );
}

PatientLocal _patient({
  required List<PatientMedicalDocument> medicalDocuments,
}) {
  return PatientLocal(
    localId: 'patient-1',
    anonymousId: 'DR-patient-1',
    nom: 'Dupont',
    prenom: 'Alice',
    dateNaissance: '01/01/1980',
    consentementValide: true,
    dateConsentement: DateTime(2026, 1, 1),
    medicalDocuments: medicalDocuments,
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:drapeaux_rouges_mb/core/utils/selected_document_data.dart';
import 'package:drapeaux_rouges_mb/models/access_direct_model.dart';
import 'package:drapeaux_rouges_mb/services/access_direct_local_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'access_direct_document_test_',
    );
    Hive.init(tempDir.path);
    await Hive.openBox('access_direct_box');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'camera selection persists base64 without path and removes capture',
    () async {
      final cameraFile = File('${tempDir.path}/camera.jpg');
      await cameraFile.writeAsBytes([1, 2, 3]);
      final selected = await SelectedDocumentData.read(
        file: XFile(cameraFile.path),
        source: ImageSource.camera,
      );

      try {
        await _saveSelected(selected);
      } finally {
        await selected.deleteTemporaryCameraFile();
      }

      final restored = await AccessDirectLocalService.loadSettings();
      expect(restored.diagnosisDocumentName, 'camera.jpg');
      expect(restored.diagnosisDocumentBase64, base64Encode([1, 2, 3]));
      expect(restored.diagnosisDocumentPath, isNull);
      expect(restored.hasDiagnosisProof, isTrue);
      expect(await cameraFile.exists(), isFalse);
    },
  );

  test('gallery selection persists base64 without deleting source', () async {
    final galleryFile = File('${tempDir.path}/gallery.jpg');
    await galleryFile.writeAsBytes([4, 5, 6]);
    final selected = await SelectedDocumentData.read(
      file: XFile(galleryFile.path),
      source: ImageSource.gallery,
    );

    try {
      await _saveSelected(selected);
    } finally {
      await selected.deleteTemporaryCameraFile();
    }

    final restored = await AccessDirectLocalService.loadSettings();
    expect(restored.diagnosisDocumentName, 'gallery.jpg');
    expect(restored.diagnosisDocumentBase64, base64Encode([4, 5, 6]));
    expect(restored.diagnosisDocumentPath, isNull);
    expect(restored.hasDiagnosisProof, isTrue);
    expect(await galleryFile.exists(), isTrue);
  });

  test('restores proof from base64 alone after persistence', () async {
    await AccessDirectLocalService.saveSettings(
      _model(path: null, base64Data: base64Encode([7, 8, 9])),
    );

    final restored = await AccessDirectLocalService.loadSettings();

    expect(restored.diagnosisDocumentPath, isNull);
    expect(restored.hasDiagnosisProof, isTrue);
  });

  test('historical path alone is not a diagnosis proof', () {
    final historical = _model(
      path: '/legacy/cache/proof.jpg',
      base64Data: null,
    );

    expect(historical.hasDiagnosisProof, isFalse);
  });

  test('historical path with valid base64 remains a diagnosis proof', () {
    final historical = _model(
      path: '/legacy/cache/proof.jpg',
      base64Data: base64Encode([10]),
    );

    expect(historical.hasDiagnosisProof, isTrue);
  });

  test('invalid non-empty base64 is not a diagnosis proof', () {
    expect(
      _model(path: null, base64Data: 'not base64').hasDiagnosisProof,
      isFalse,
    );
  });

  test('failed selections preserve the previously persisted proof', () async {
    final previousBase64 = base64Encode([11, 12]);
    await AccessDirectLocalService.saveSettings(
      _model(path: '/legacy/proof.jpg', base64Data: previousBase64),
    );

    await expectLater(
      SelectedDocumentData.read(
        file: XFile('${tempDir.path}/missing-camera.jpg'),
        source: ImageSource.camera,
      ),
      throwsA(isA<FileSystemException>()),
    );
    await expectLater(
      SelectedDocumentData.read(
        file: XFile('${tempDir.path}/missing-gallery.jpg'),
        source: ImageSource.gallery,
      ),
      throwsA(isA<FileSystemException>()),
    );

    final restored = await AccessDirectLocalService.loadSettings();
    expect(restored.diagnosisDocumentBase64, previousBase64);
    expect(restored.diagnosisDocumentPath, '/legacy/proof.jpg');
  });

  test(
    'removing proof preserves unknown historical path and source file',
    () async {
      final galleryFile = File('${tempDir.path}/legacy-gallery.jpg');
      await galleryFile.writeAsBytes([13]);
      await AccessDirectLocalService.saveSettings(
        _model(path: galleryFile.path, base64Data: base64Encode([13])),
      );

      final existing = await AccessDirectLocalService.loadSettings();
      await AccessDirectLocalService.saveSettings(
        AccessDirectModel(
          isCoordinatedExercise: existing.isCoordinatedExercise,
          isExperimentalDepartment: existing.isExperimentalDepartment,
          hasArsDeclaration: existing.hasArsDeclaration,
          hasMedicalDiagnosis: existing.hasMedicalDiagnosis,
          diagnosisDocumentPath: existing.diagnosisDocumentPath,
          diagnosisDocumentName: null,
          diagnosisDocumentBase64: null,
          diagnosisDocumentAddedAt: null,
          sessionsDone: existing.sessionsDone,
        ),
      );

      final restored = await AccessDirectLocalService.loadSettings();
      expect(restored.diagnosisDocumentPath, galleryFile.path);
      expect(restored.diagnosisDocumentName, isNull);
      expect(restored.diagnosisDocumentBase64, isNull);
      expect(restored.hasDiagnosisProof, isFalse);
      expect(await galleryFile.exists(), isTrue);
    },
  );

  test(
    'both access direct screens use selected data and guaranteed cleanup',
    () {
      for (final path in [
        'lib/screens/access_direct_settings_screen.dart',
        'lib/screens/patient_consent_screen.dart',
      ]) {
        final source = File(path).readAsStringSync();
        final pickStart = source.indexOf(
          'Future<void> pickDiagnosisDocument(ImageSource source)',
        );
        final nextMethod = source.indexOf('\n  Future<void>', pickStart + 1);
        final pickMethod = source.substring(pickStart, nextMethod);

        expect(pickMethod, contains('SelectedDocumentData.read('));
        expect(pickMethod, contains('diagnosisDocumentPath: null'));
        expect(
          pickMethod,
          contains('diagnosisDocumentName: selected.filename'),
        );
        expect(
          pickMethod,
          contains('diagnosisDocumentBase64: selected.base64Data'),
        );
        expect(pickMethod, contains('finally {'));
        expect(pickMethod, contains('deleteTemporaryCameraFile()'));
        expect(pickMethod, isNot(contains('document.path')));
        expect(pickMethod, isNot(contains('document.readAsBytes()')));

        final save = pickMethod.indexOf(
          'AccessDirectLocalService.saveSettings(updatedModel)',
        );
        final stateUpdate = pickMethod.indexOf('setState(() {', save);
        expect(save, greaterThan(0));
        expect(stateUpdate, greaterThan(save));
      }
    },
  );
}

Future<void> _saveSelected(SelectedDocumentData selected) {
  return AccessDirectLocalService.saveSettings(
    AccessDirectModel(
      isCoordinatedExercise: true,
      isExperimentalDepartment: true,
      hasArsDeclaration: true,
      hasMedicalDiagnosis: true,
      diagnosisDocumentPath: null,
      diagnosisDocumentName: selected.filename,
      diagnosisDocumentBase64: selected.base64Data,
      diagnosisDocumentAddedAt: '2026-07-25T12:00:00.000',
      sessionsDone: 0,
    ),
  );
}

AccessDirectModel _model({required String? path, required String? base64Data}) {
  return AccessDirectModel(
    isCoordinatedExercise: true,
    isExperimentalDepartment: true,
    hasArsDeclaration: true,
    hasMedicalDiagnosis: true,
    diagnosisDocumentPath: path,
    diagnosisDocumentName: 'proof.jpg',
    diagnosisDocumentBase64: base64Data,
    diagnosisDocumentAddedAt: '2026-07-25T12:00:00.000',
    sessionsDone: 0,
  );
}

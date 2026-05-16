import '../models/patient_local.dart';
import '../models/patient_record_model.dart';
import 'local_database_service.dart';
import 'rgpd_local_service.dart';

class PatientRecordService {
  static Future<PatientRecordModel?> getRecordForPatient(
    PatientLocal patient,
  ) async {
    final evaluations = await LocalDatabaseService.getEvaluationsForPatient(
      patient.localId,
    );

    return PatientRecordModel(
      patientLocalId: patient.localId,
      patientAnonymousId: patient.anonymousId,
      patientDisplayName: RgpdLocalService.patientDisplayName(patient),
      evaluations: evaluations,
      prescriptions: const [],
    );
  }

  static Future<List<PatientRecordModel>> getAllPatientRecords() async {
    final patients = await RgpdLocalService.getPatients();

    final records = <PatientRecordModel>[];

    for (final patient in patients) {
      final record = await getRecordForPatient(patient);

      if (record != null) {
        records.add(record);
      }
    }

    records.sort((a, b) {
      return a.patientDisplayName
          .toLowerCase()
          .compareTo(b.patientDisplayName.toLowerCase());
    });

    return records;
  }

  static Future<List<Map<String, dynamic>>> getAnonymousRecordsExport() async {
    final records = await getAllPatientRecords();

    return records.map((record) {
      return record.toAnonymousExport();
    }).toList();
  }
}
enum MedicalLetterType {
  generalPractitionerInfo('general_practitioner_info'),
  medicalOrientation('medical_orientation'),
  specialistOpinion('specialist_opinion');

  const MedicalLetterType(this.id);

  final String id;
}

MedicalLetterType medicalLetterTypeById(String id) {
  return MedicalLetterType.values.firstWhere(
    (type) => type.id == id,
    orElse: () => MedicalLetterType.generalPractitionerInfo,
  );
}

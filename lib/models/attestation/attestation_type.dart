enum AttestationType {
  nearestAvailableMk,
  refusedMedicalOrientation,
  reinforcedConsent,
  directAccessCare,
}

extension AttestationTypeLabel on AttestationType {
  String get id {
    switch (this) {
      case AttestationType.nearestAvailableMk:
        return 'nearest_available_mk';
      case AttestationType.refusedMedicalOrientation:
        return 'refused_medical_orientation';
      case AttestationType.reinforcedConsent:
        return 'reinforced_consent';
      case AttestationType.directAccessCare:
        return 'direct_access_care';
    }
  }
}

enum ClinicalFindingCategory {
  general,
  cardiovascular,
  respiratory,
  neurological,
  infectious,
  mentalHealth,
  musculoskeletal,
  other,
}

enum ClinicalSeverity { low, moderate, high, critical, unknown }

enum ClinicalSource {
  evaluation,
  patientInput,
  practitionerInput,
  voice,
  ai,
  importedDocument,
  unknown,
}

enum ClinicalAlertLevel { info, warning, urgent, critical }

enum ClinicalRecommendationPriority { low, medium, high, urgent }

enum ClinicalActionType {
  monitor,
  refer,
  emergencyReferral,
  prescribe,
  document,
  educate,
  none,
}

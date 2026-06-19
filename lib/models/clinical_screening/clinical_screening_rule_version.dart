abstract final class ClinicalScreeningRuleVersion {
  // Versioning makes exported decisions auditable over time.
  // Any clinical rule change must update rulesetVersion.
  static const engineName = 'ClinicalScreeningEngineV3';
  static const engineVersion = '3.0.0';
  static const rulesetVersion = '2026.06-v1';
  static const rulesetDate = '2026-06-19';
  static const clinicalStatus = 'experimental_not_clinically_validated';
  static const notes =
      'Aide au repérage clinique, non validée pour usage autonome.';

  static const clinicalStatusLabel = 'expérimental, non validé cliniquement';
}

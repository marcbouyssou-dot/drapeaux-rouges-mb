abstract final class ClinicalScriptIdsV7 {
  static const mecanique = 'SCRIPT_MECANIQUE';
  static const oncologique = 'SCRIPT_ONCOLOGIQUE';
  static const infectieux = 'SCRIPT_INFECTIEUX';
  static const fracture = 'SCRIPT_FRACTURE';
  static const neurologique = 'SCRIPT_NEUROLOGIQUE';
  static const queueDeCheval = 'SCRIPT_QUEUE_DE_CHEVAL';
  static const vasculaire = 'SCRIPT_VASCULAIRE';
  static const psychosocial = 'SCRIPT_PSYCHOSOCIAL';
  static const cervicalVasculaire = 'SCRIPT_CERVICAL_VASCULAIRE';
  static const aaaVasculaireAbdominal = 'SCRIPT_AAA_VASCULAIRE_ABDOMINAL';

  static const all = [
    mecanique,
    oncologique,
    infectieux,
    fracture,
    neurologique,
    queueDeCheval,
    vasculaire,
    psychosocial,
    cervicalVasculaire,
    aaaVasculaireAbdominal,
  ];
}

abstract final class ClinicalPsychosocialLevelsV7 {
  static const psychoLow = 'PSYCHO_LOW';
  static const psychoModerate = 'PSYCHO_MODERATE';
  static const psychoHigh = 'PSYCHO_HIGH';

  static const all = [psychoLow, psychoModerate, psychoHigh];
}

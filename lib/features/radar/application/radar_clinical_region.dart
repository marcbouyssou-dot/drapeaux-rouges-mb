/// Régions cliniques Radar — écran d'entrée.
///
/// STATUT : matrice Delphi V0.1 — NON VALIDÉE cliniquement.
/// Taxonomie (point Delphi n°8) : régions = anatomiques uniquement.
/// Le traumatisme est une PORTE (RadarContextGate.trauma), pas une région.
/// Le neurologique est une PRÉSENTATION couverte par la question universelle
/// v4_neurologic_deficit_001, pas une région.
enum RadarClinicalRegion {
  lumbar,
  cervical,
  thoracic,
  shoulderUpperLimbProximal,
  upperLimbDistal, // coude, poignet, main
  hipLowerLimbProximal,
  kneeLeg,
  ankleFoot,

  /// Douleur diffuse / multifocale / non systématisée.
  /// Pathway le plus exigeant du système : DEC_REASSURE inaccessible en V1.
  /// À distinguer visuellement des autres régions dans l'UI.
  diffuse,
}

/// Portes contextuelles — faits saisis AVANT toute question clinique.
/// Le kiné les connaît déjà : coût de saisie quasi nul, élagage maximal.
enum RadarContextGate {
  /// P1 — Traumatisme récent.
  /// Effet : injecte fracture ouverte en position 0 (pré-emption absolue).
  /// Diffus + trauma = orientation d'emblée (polytraumatisme).
  trauma,

  /// P2 — Âge >= 50 ans OU fragilité osseuse connue
  /// (ostéoporose, corticothérapie prolongée).
  /// Effet : active risque fracturaire sans trauma ; participe à l'activation
  /// de l'AAA en lombaire. Seuil unique à 50 ans (point Delphi n°5).
  ageOrBoneFragility,

  /// P3 — Chirurgie, immobilisation ou alitement prolongé < 3 mois.
  /// Effet : active la question TVP dans les régions de membre inférieur.
  recentImmobilization,
}

/// Déclencheurs cliniques conditionnels — sous-questions de porte posées
/// uniquement pour décider d'activer une question conditionnelle.
/// La formulation exacte de chaque déclencheur est un livrable Delphi
/// (point n°3 pour les déclencheurs cardiaques).
enum RadarClinicalTrigger {
  /// Douleur lombo-pelvienne associée (rouvre queue de cheval en hanche/diffus).
  lumbopelvicComponent,

  /// Douleur ou œdème de mollet (active TVP même sans porte P3).
  calfPainOrEdema,

  /// Douleur cervicale antérieure ou liée à l'effort (angor projeté).
  anteriorOrExertionalNeckPain,

  /// Épaule GAUCHE + lien à l'effort ou dyspnée/malaise (IDM projeté).
  leftShoulderExertionalOrSystemic,

  /// Céphalée ou cervicalgie associée (rouvre cervico-vasculaire en diffus).
  headacheOrNeckPain,

  /// Dyspnée ou malaise associés (rouvre cardio-respiratoire / EP en diffus).
  dyspneaOrMalaise,

  /// Signes unilatéraux de membre inférieur (rouvre TVP en diffus).
  unilateralLowerLimbSigns,

  /// Douleur lombo-abdominale profonde (composante AAA en diffus).
  lumboabdominalPain,

  /// Facteurs de risque cardiovasculaires connus (participe à l'AAA).
  cardiovascularRiskFactors,
}

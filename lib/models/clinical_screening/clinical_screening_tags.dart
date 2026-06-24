abstract final class ClinicalScreeningTags {
  // Technical and stable identifiers used by ClinicalScreeningEngineV3.
  // Patient-facing and practitioner-facing labels must live outside this file.
  // Any tag change must be accompanied by dedicated unit tests.
  static const urgenceVitale = 'urgence_vitale';
  static const emboliePulmonaire = 'embolie_pulmonaire';
  static const queueCheval = 'queue_cheval';
  static const fractureOuverte = 'fracture_ouverte';
  static const douleurThoraciqueCritique = 'douleur_thoracique_critique';

  static const cancer = 'cancer';
  static const neoplasie = 'neoplasie';
  static const oncologic = 'oncologic';
  static const pertePoids = 'perte_poids';
  static const douleurNocturne = 'douleur_nocturne';
  static const alterationEtatGeneral = 'alteration_etat_general';

  static const fievre = 'fievre';
  static const frissons = 'frissons';
  static const sueursNocturnes = 'sueurs_nocturnes';
  static const immunodepression = 'immunodepression';
  static const infectionRecente = 'infection_recente';

  static const deficitMoteurProgressif = 'deficit_moteur_progressif';
  static const signesNeurologiquesCentraux = 'signes_neurologiques_centraux';

  static const douleurThoracique = 'douleur_thoracique';
  static const dyspnee = 'dyspnee';
  static const malaise = 'malaise';
  static const syncope = 'syncope';

  static const traumatisme = 'traumatisme';
  static const chute = 'chute';
  static const osteoporose = 'osteoporose';
  static const corticotherapieProlongee = 'corticotherapie_prolongee';
  static const ageAvance = 'age_avance';

  static const wellsTvp = 'wells_tvp';
  static const tvp = 'tvp';
  static const neurovasculaireCervical = 'neurovasculaire_cervical';
  static const vasculaire = 'vasculaire';
  static const cephaleeInhabituelle = 'cephalee_inhabituelle';
  static const vertigesInhabituels = 'vertiges_inhabituels';
  static const troublesVisuels = 'troubles_visuels';
  static const dysarthrie = 'dysarthrie';
  static const traumaCervicalMineur = 'trauma_cervical_mineur';
  static const hta = 'hta';
  static const tabac = 'tabac';
  static const facteursVasculaires = 'facteurs_vasculaires';
  static const douleurLombaireAbdominaleProfonde =
      'douleur_lombaire_abdominale_profonde';
  static const douleurBrutale = 'douleur_brutale';
  static const douleurLieeMouvement = 'douleur_liee_mouvement';
  static const douleurReproductible = 'douleur_reproductible';
  static const ameliorationRepos = 'amelioration_repos';
  static const surchargeMecanique = 'surcharge_mecanique';
  static const episodeMecaniqueStable = 'episode_mecanique_stable';
  static const absenceSignesSystemiques = 'absence_signes_systemiques';

  static const criticalEmergency = [
    urgenceVitale,
    emboliePulmonaire,
    queueCheval,
    fractureOuverte,
    douleurThoraciqueCritique,
  ];

  static const oncologicContext = [cancer, neoplasie, oncologic];
  static const oncologicAssociated = [
    pertePoids,
    douleurNocturne,
    alterationEtatGeneral,
  ];

  static const infectiousSystemic = [fievre, frissons, sueursNocturnes];
  static const infectiousFragility = [immunodepression, infectionRecente];

  static const neurologicCluster = [
    deficitMoteurProgressif,
    signesNeurologiquesCentraux,
  ];

  static const chestPain = [douleurThoracique, douleurThoraciqueCritique];
  static const respiratoryOrMalaise = [dyspnee, malaise, syncope];

  static const fractureTrauma = [traumatisme, chute];
  static const fractureFragility = [
    osteoporose,
    corticotherapieProlongee,
    ageAvance,
  ];

  static const vascularConcern = [
    wellsTvp,
    tvp,
    neurovasculaireCervical,
    vasculaire,
    cephaleeInhabituelle,
    vertigesInhabituels,
    troublesVisuels,
    dysarthrie,
    douleurLombaireAbdominaleProfonde,
    douleurBrutale,
  ];

  static const cervicalVascular = [
    neurovasculaireCervical,
    cephaleeInhabituelle,
    vertigesInhabituels,
    troublesVisuels,
    dysarthrie,
    traumaCervicalMineur,
    hta,
    tabac,
    facteursVasculaires,
  ];

  static const aaaVascularAbdominal = [
    ageAvance,
    tabac,
    hta,
    douleurLombaireAbdominaleProfonde,
    malaise,
    douleurBrutale,
  ];

  static const isolatedSystemicConcern = [
    cancer,
    neoplasie,
    oncologic,
    fievre,
    immunodepression,
  ];

  static const mechanicalReassurance = [
    douleurLieeMouvement,
    douleurReproductible,
    ameliorationRepos,
    surchargeMecanique,
    episodeMecaniqueStable,
    absenceSignesSystemiques,
  ];
}

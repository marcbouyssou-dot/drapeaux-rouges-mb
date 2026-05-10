final Map<String, List<Map<String, dynamic>>> clinicalCategories = {
  'Lombalgie': [
    {
      'title': 'Déficit neurologique brutal : paralysie, anesthésie en selle, troubles urinaires ou fécaux',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Syndrome de la queue de cheval suspecté',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Fièvre, frissons ou signes infectieux associés à la douleur rachidienne',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Douleur nocturne non mécanique, progressive ou insomniante',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Traumatisme violent ou chute de hauteur',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Antécédent de cancer ou suspicion de tumeur',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Perte de poids inexpliquée, fatigue intense, anorexie',
      'severity': 'Modéré',
      'checked': false,
    },
  ],

  'Entorse de cheville': [
    {
      'title': 'Incapacité à effectuer au moins quatre pas',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Douleur osseuse sur les malléoles',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Douleur osseuse à la base du 5e métatarsien',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Douleur osseuse sur le naviculaire',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Déformation évidente ou suspicion de luxation',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Suspicion de fracture ouverte',
      'severity': 'Critique',
      'checked': false,
    },
  ],

  'Respiratoire adulte': [
    {
      'title': 'Dyspnée sévère ou aggravation rapide',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Cyanose',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Hémoptysie',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Fièvre élevée persistante',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Douleur thoracique associée',
      'severity': 'Élevé',
      'checked': false,
    },
  ],

  'Orthopédie générale': [
    {
      'title': 'Déformation visible',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Suspicion de fracture',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Fièvre avec articulation chaude',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Blocage complet ou impotence fonctionnelle sévère',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Incapacité d’utiliser le membre',
      'severity': 'Élevé',
      'checked': false,
    },
  ],

  'Cervicalgie': [
    {
      'title': 'Céphalée brutale en coup de tonnerre',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Diplopie, dysarthrie, dysphagie, drop attacks ou vertiges importants',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Troubles de coordination, fièvre ou raideur cervicale',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Signes neurologiques : paresthésies, faiblesse, déficit moteur',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Suspicion de dissection ou atteinte neurovasculaire',
      'severity': 'Critique',
      'checked': false,
    },
  ],

  'Cardiaque': [
    {
      'title': 'Douleur thoracique oppressive ou constrictive',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Irradiation vers bras gauche, mâchoire ou dos',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Dyspnée brutale ou gêne respiratoire',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Sueurs froides, pâleur ou agitation',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Malaise, pré-syncope ou syncope',
      'severity': 'Critique',
      'checked': false,
    },
  ],

  'TVP / Vasculaire': [
    {
      'title': 'Œdème unilatéral récent',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Mollet chaud, tendu et douloureux à la palpation',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Score de Wells à vérifier',
      'severity': 'Modéré',
      'checked': false,
    },
    {
      'title': 'Dyspnée brutale, douleur thoracique ou tachycardie',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Facteurs de risque : chirurgie récente, immobilisation, cancer actif, grossesse/post-partum',
      'severity': 'Modéré',
      'checked': false,
    },
  ],

  'Post-opératoire': [
    {
      'title': 'Fièvre, frissons ou cicatrice inflammatoire/suintante',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Rougeur étendue, chaleur ou œdème croissant',
      'severity': 'Élevé',
      'checked': false,
    },
    {
      'title': 'Douleur du mollet, œdème ou suspicion de TVP',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Pâleur, froideur, cyanose ou pouls diminué',
      'severity': 'Critique',
      'checked': false,
    },
    {
      'title': 'Douleur aiguë soudaine après un geste chirurgical',
      'severity': 'Élevé',
      'checked': false,
    },
  ],
};
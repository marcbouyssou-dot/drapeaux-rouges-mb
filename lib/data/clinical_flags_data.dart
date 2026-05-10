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
    'title': 'Ottawa positif : incapacité à effectuer au moins quatre pas immédiatement après le traumatisme ou à l’examen',
    'severity': 'Élevé',
    'checked': false,
  },
  {
    'title': 'Ottawa positif : douleur osseuse au bord postérieur ou à la pointe de la malléole latérale',
    'severity': 'Élevé',
    'checked': false,
  },
  {
    'title': 'Ottawa positif : douleur osseuse au bord postérieur ou à la pointe de la malléole médiale',
    'severity': 'Élevé',
    'checked': false,
  },
  {
    'title': 'Ottawa positif : douleur osseuse à la base du 5e métatarsien',
    'severity': 'Élevé',
    'checked': false,
  },
  {
    'title': 'Ottawa positif : douleur osseuse sur le naviculaire',
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
  {
    'title': 'Douleur haute ou instabilité évoquant une atteinte syndesmotique importante',
    'severity': 'Élevé',
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
    'title': '5D : vertiges importants ou sensation rotatoire',
    'severity': 'Critique',
    'checked': false,
  },
  {
    'title': '5D : diplopie',
    'severity': 'Critique',
    'checked': false,
  },
  {
    'title': '5D : dysarthrie',
    'severity': 'Critique',
    'checked': false,
  },
  {
    'title': '5D : dysphagie',
    'severity': 'Critique',
    'checked': false,
  },
  {
    'title': '5D : drop attacks ou malaise brutal',
    'severity': 'Critique',
    'checked': false,
  },
  {
    'title': '3N : nausees importantes',
    'severity': 'Élevé',
    'checked': false,
  },
  {
    'title': '3N : nystagmus',
    'severity': 'Élevé',
    'checked': false,
  },
  {
    'title': '3N : paresthesies ou engourdissement facial',
    'severity': 'Élevé',
    'checked': false,
  },
  {
    'title': 'Céphalée brutale inhabituelle',
    'severity': 'Critique',
    'checked': false,
  },
  {
    'title': 'Trouble neurologique recent',
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
    'title': 'Wells TVP : cancer actif ou traitement recent',
    'severity': 'Modere',
    'checked': false,
  },
  {
    'title': 'Wells TVP : paralysie, paresie ou immobilisation recente du membre inferieur',
    'severity': 'Modere',
    'checked': false,
  },
  {
    'title': 'Wells TVP : alitement recent de plus de 3 jours ou chirurgie majeure recente',
    'severity': 'Modere',
    'checked': false,
  },
  {
    'title': 'Wells TVP : douleur localisee sur le trajet veineux profond',
    'severity': 'Eleve',
    'checked': false,
  },
  {
    'title': 'Wells TVP : oedeme global du membre inferieur',
    'severity': 'Eleve',
    'checked': false,
  },
  {
    'title': 'Wells TVP : mollet augmente de volume de plus de 3 cm',
    'severity': 'Eleve',
    'checked': false,
  },
  {
    'title': 'Wells TVP : oedeme prenant le godet',
    'severity': 'Modere',
    'checked': false,
  },
  {
    'title': 'Wells TVP : veines superficielles collaterales non variqueuses',
    'severity': 'Modere',
    'checked': false,
  },
  {
    'title': 'Dyspnee brutale, douleur thoracique, malaise ou tachycardie',
    'severity': 'Critique',
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
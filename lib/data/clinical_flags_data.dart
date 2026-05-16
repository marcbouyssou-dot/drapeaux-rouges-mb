final Map<String, List<Map<String, dynamic>>> clinicalCategories = {
  'Lombalgie': [
    {
      'title':
          'Déficit neurologique brutal : paralysie, anesthésie en selle, troubles urinaires ou fécaux',
      'severity': 'Critique',
      'tags': ['urgence', 'neurologique', 'queue_cheval'],
      'checked': false,
    },
    {
      'title': 'Syndrome de la queue de cheval suspecté',
      'severity': 'Critique',
      'tags': ['urgence', 'neurologique', 'queue_cheval'],
      'checked': false,
    },
    {
      'title':
          'Fièvre, frissons ou signes infectieux associés à la douleur rachidienne',
      'severity': 'Critique',
      'tags': ['urgence', 'infection'],
      'checked': false,
    },
    {
      'title': 'Douleur nocturne non mécanique, progressive ou insomniante',
      'severity': 'Élevé',
      'tags': ['cancer', 'infection'],
      'checked': false,
    },
    {
      'title': 'Traumatisme violent ou chute de hauteur',
      'severity': 'Élevé',
      'tags': ['traumatisme', 'fracture', 'imagerie'],
      'checked': false,
    },
    {
      'title': 'Antécédent de cancer ou suspicion de tumeur',
      'severity': 'Élevé',
      'tags': ['cancer'],
      'checked': false,
    },
    {
      'title': 'Perte de poids inexpliquée, fatigue intense, anorexie',
      'severity': 'Modéré',
      'tags': ['cancer', 'systemique'],
      'checked': false,
    },
  ],

  'Entorse de cheville': [
    {
      'title':
          'Ottawa positif : incapacité à effectuer au moins quatre pas immédiatement après le traumatisme ou à l’examen',
      'severity': 'Élevé',
      'tags': ['ottawa', 'fracture', 'imagerie'],
      'checked': false,
    },
    {
      'title':
          'Ottawa positif : douleur osseuse au bord postérieur ou à la pointe de la malléole latérale',
      'severity': 'Élevé',
      'tags': ['ottawa', 'fracture', 'imagerie'],
      'checked': false,
    },
    {
      'title':
          'Ottawa positif : douleur osseuse au bord postérieur ou à la pointe de la malléole médiale',
      'severity': 'Élevé',
      'tags': ['ottawa', 'fracture', 'imagerie'],
      'checked': false,
    },
    {
      'title': 'Ottawa positif : douleur osseuse à la base du 5e métatarsien',
      'severity': 'Élevé',
      'tags': ['ottawa', 'fracture', 'imagerie'],
      'checked': false,
    },
    {
      'title': 'Ottawa positif : douleur osseuse sur le naviculaire',
      'severity': 'Élevé',
      'tags': ['ottawa', 'fracture', 'imagerie'],
      'checked': false,
    },
    {
      'title': 'Déformation évidente ou suspicion de luxation',
      'severity': 'Critique',
      'tags': ['urgence', 'deformation', 'luxation'],
      'checked': false,
    },
    {
      'title': 'Suspicion de fracture ouverte',
      'severity': 'Critique',
      'tags': ['urgence', 'fracture', 'fracture_ouverte'],
      'checked': false,
    },
    {
      'title':
          'Douleur haute ou instabilité évoquant une atteinte syndesmotique importante',
      'severity': 'Élevé',
      'tags': ['syndesmose', 'imagerie'],
      'checked': false,
    },
  ],

  'Respiratoire adulte': [
    {
      'title': 'Dyspnée sévère ou aggravation rapide',
      'severity': 'Critique',
      'tags': ['urgence', 'respiratoire'],
      'checked': false,
    },
    {
      'title': 'Cyanose',
      'severity': 'Critique',
      'tags': ['urgence', 'respiratoire'],
      'checked': false,
    },
    {
      'title': 'Hémoptysie',
      'severity': 'Critique',
      'tags': ['urgence', 'respiratoire'],
      'checked': false,
    },
    {
      'title': 'Fièvre élevée persistante',
      'severity': 'Élevé',
      'tags': ['infection', 'respiratoire'],
      'checked': false,
    },
    {
      'title': 'Douleur thoracique associée',
      'severity': 'Élevé',
      'tags': ['cardiaque', 'respiratoire'],
      'checked': false,
    },
  ],

  'Orthopédie générale': [
    {
      'title': 'Déformation visible',
      'severity': 'Critique',
      'tags': ['urgence', 'deformation', 'fracture'],
      'checked': false,
    },
    {
      'title': 'Suspicion de fracture',
      'severity': 'Élevé',
      'tags': ['fracture', 'imagerie'],
      'checked': false,
    },
    {
      'title': 'Fièvre avec articulation chaude',
      'severity': 'Critique',
      'tags': ['urgence', 'infection'],
      'checked': false,
    },
    {
      'title': 'Blocage complet ou impotence fonctionnelle sévère',
      'severity': 'Élevé',
      'tags': ['orthopedie', 'fonctionnel'],
      'checked': false,
    },
    {
      'title': 'Incapacité d’utiliser le membre',
      'severity': 'Élevé',
      'tags': ['orthopedie', 'fonctionnel'],
      'checked': false,
    },
  ],

  'Cervicalgie': [
    {
      'title': '5D : vertiges importants ou sensation rotatoire',
      'severity': 'Critique',
      'tags': ['urgence', 'neurovasculaire_cervical', '5d'],
      'checked': false,
    },
    {
      'title': '5D : diplopie',
      'severity': 'Critique',
      'tags': ['urgence', 'neurovasculaire_cervical', '5d'],
      'checked': false,
    },
    {
      'title': '5D : dysarthrie',
      'severity': 'Critique',
      'tags': ['urgence', 'neurovasculaire_cervical', '5d'],
      'checked': false,
    },
    {
      'title': '5D : dysphagie',
      'severity': 'Critique',
      'tags': ['urgence', 'neurovasculaire_cervical', '5d'],
      'checked': false,
    },
    {
      'title': '5D : drop attacks ou malaise brutal',
      'severity': 'Critique',
      'tags': ['urgence', 'neurovasculaire_cervical', '5d'],
      'checked': false,
    },
    {
      'title': '3N : nausées importantes',
      'severity': 'Élevé',
      'tags': ['neurovasculaire_cervical', '3n'],
      'checked': false,
    },
    {
      'title': '3N : nystagmus',
      'severity': 'Élevé',
      'tags': ['neurovasculaire_cervical', '3n'],
      'checked': false,
    },
    {
      'title': '3N : paresthésies ou engourdissement facial',
      'severity': 'Élevé',
      'tags': ['neurovasculaire_cervical', '3n', 'neurologique'],
      'checked': false,
    },
    {
      'title': 'Céphalée brutale inhabituelle',
      'severity': 'Critique',
      'tags': ['urgence', 'neurovasculaire_cervical', 'neurologique'],
      'checked': false,
    },
    {
      'title': 'Trouble neurologique récent',
      'severity': 'Critique',
      'tags': ['urgence', 'neurologique'],
      'checked': false,
    },
  ],

  'Cardiaque': [
    {
      'title': 'Douleur thoracique oppressive ou constrictive',
      'severity': 'Critique',
      'tags': ['urgence', 'cardiaque'],
      'checked': false,
    },
    {
      'title': 'Irradiation vers bras gauche, mâchoire ou dos',
      'severity': 'Critique',
      'tags': ['urgence', 'cardiaque'],
      'checked': false,
    },
    {
      'title': 'Dyspnée brutale ou gêne respiratoire',
      'severity': 'Critique',
      'tags': ['urgence', 'cardiaque', 'respiratoire'],
      'checked': false,
    },
    {
      'title': 'Sueurs froides, pâleur ou agitation',
      'severity': 'Critique',
      'tags': ['urgence', 'cardiaque'],
      'checked': false,
    },
    {
      'title': 'Malaise, pré-syncope ou syncope',
      'severity': 'Critique',
      'tags': ['urgence', 'cardiaque'],
      'checked': false,
    },
  ],

  'TVP / Vasculaire': [
    {
      'title': 'Wells TVP : cancer actif ou traitement récent',
      'severity': 'Modéré',
      'tags': ['wells_tvp', 'tvp', 'cancer'],
      'checked': false,
    },
    {
      'title':
          'Wells TVP : paralysie, parésie ou immobilisation récente du membre inférieur',
      'severity': 'Modéré',
      'tags': ['wells_tvp', 'tvp', 'immobilisation'],
      'checked': false,
    },
    {
      'title':
          'Wells TVP : alitement récent de plus de 3 jours ou chirurgie majeure récente',
      'severity': 'Modéré',
      'tags': ['wells_tvp', 'tvp', 'post_operatoire'],
      'checked': false,
    },
    {
      'title': 'Wells TVP : douleur localisée sur le trajet veineux profond',
      'severity': 'Élevé',
      'tags': ['wells_tvp', 'tvp'],
      'checked': false,
    },
    {
      'title': 'Wells TVP : œdème global du membre inférieur',
      'severity': 'Élevé',
      'tags': ['wells_tvp', 'tvp'],
      'checked': false,
    },
    {
      'title': 'Wells TVP : mollet augmenté de volume de plus de 3 cm',
      'severity': 'Élevé',
      'tags': ['wells_tvp', 'tvp'],
      'checked': false,
    },
    {
      'title': 'Wells TVP : œdème prenant le godet',
      'severity': 'Modéré',
      'tags': ['wells_tvp', 'tvp'],
      'checked': false,
    },
    {
      'title':
          'Wells TVP : veines superficielles collatérales non variqueuses',
      'severity': 'Modéré',
      'tags': ['wells_tvp', 'tvp'],
      'checked': false,
    },
    {
      'title': 'Dyspnée brutale, douleur thoracique, malaise ou tachycardie',
      'severity': 'Critique',
      'tags': ['urgence', 'embolie_pulmonaire', 'respiratoire', 'cardiaque'],
      'checked': false,
    },
  ],

  'Post-opératoire': [
    {
      'title': 'Fièvre, frissons ou cicatrice inflammatoire/suintante',
      'severity': 'Critique',
      'tags': ['urgence', 'infection', 'post_operatoire'],
      'checked': false,
    },
    {
      'title': 'Rougeur étendue, chaleur ou œdème croissant',
      'severity': 'Élevé',
      'tags': ['infection', 'post_operatoire'],
      'checked': false,
    },
    {
      'title': 'Douleur du mollet, œdème ou suspicion de TVP',
      'severity': 'Critique',
      'tags': ['urgence', 'tvp', 'post_operatoire'],
      'checked': false,
    },
    {
      'title': 'Pâleur, froideur, cyanose ou pouls diminué',
      'severity': 'Critique',
      'tags': ['urgence', 'vasculaire', 'post_operatoire'],
      'checked': false,
    },
    {
      'title': 'Douleur aiguë soudaine après un geste chirurgical',
      'severity': 'Élevé',
      'tags': ['post_operatoire'],
      'checked': false,
    },
  ],
};
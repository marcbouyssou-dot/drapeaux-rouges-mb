# Contrat d'interface adaptatif V5

Lot V4/V5-UX-00.

Objectif : definir exactement ce que le futur ecran Flutter devra recevoir d'une couche d'adaptation du moteur V5, sans brancher l'UI et sans modifier le moteur V3 historique.

Ce contrat decrit un payload cible affichable. Il ne cree pas encore d'architecture ni de nouveau moteur.

## 1. Etat de session affichable

Le futur ecran doit recevoir un objet de session affichable, par exemple `ClinicalAdaptiveViewStateV5`.

Champs attendus :

| Champ | Type cible | Source actuelle | Role UI |
| --- | --- | --- | --- |
| `sessionId` | `String` | a creer par la future couche applicative | Identifier la session adaptative. |
| `answeredQuestionIds` | `Map<String, bool>` | `ClinicalAdaptiveSessionV5.answeredQuestionIds` | Savoir quelles questions ont deja recu une reponse Oui/Non. |
| `positiveFlagIds` | `List<String>` | `ClinicalAdaptiveSessionV5.positiveFlagIds` | Afficher ou historiser les signaux positifs. |
| `hypothesisProbabilities` | `Map<String, ClinicalQualitativeProbabilityV5>` | `ClinicalAdaptiveSessionV5.hypothesisProbabilities` | Suivre les hypotheses renforcees. |
| `triggeredHardStopIds` | `List<String>` | `ClinicalAdaptiveSessionV5.triggeredHardStopIds` | Bloquer le questionnaire et afficher l'alerte si necessaire. |
| `currentRiskLevel` | `ClinicalDecisionLevel` | derive des Hard Stops puis des hypotheses | Afficher le niveau de risque courant. |
| `isComplete` | `bool` | `nextQuestion == null` ou Hard Stop | Savoir si l'ecran doit proposer une decision finale. |

Regle importante : l'UI ne doit pas deduire seule la gravite clinique. Elle doit recevoir un etat deja interprete par une couche d'adaptation V5.

## 2. Question courante

La question courante correspond a `ClinicalAdaptiveSessionV5.nextQuestion`.

Champs attendus pour l'affichage :

| Champ | Type cible | Source actuelle |
| --- | --- | --- |
| `questionId` | `String` | `nextQuestion.id` |
| `patientText` | `String` | `nextQuestion.text` ou texte patient-compatible adapte |
| `clinicalIntent` | `String` | `nextQuestion.clinicalIntent` |
| `responseType` | `ClinicalQuestionResponseType` | `nextQuestion.responseType` |
| `potentialDecisionLevel` | `ClinicalDecisionLevel` | `nextQuestion.potentialDecisionLevel` |

Si `questionId == null`, l'ecran ne doit plus afficher de question Oui/Non et doit passer en etat final ou Hard Stop.

## 3. Texte patient-compatible

Le texte affiche au patient doit etre :

- court ;
- non alarmiste avant reponse ;
- comprehensible sans jargon ;
- distinct du texte medico-legal ou du raisonnement clinique interne.

Source actuelle acceptable pour V5 preparatoire :

- `ClinicalScreeningQuestionV4.text`

Evolution future recommandee :

- ajouter un champ dedie `patientText` ou un mapping UI sans modifier le texte clinique source.

Exemple attendu :

```text
Avez-vous des troubles urinaires ou fécaux nouveaux, une anesthésie en selle ou une faiblesse importante des jambes ?
```

## 4. Boutons Oui / Non

Chaque question V4 actuelle est de type Oui/Non.

Contrat UI :

| Action UI | Appel moteur cible |
| --- | --- |
| Bouton `Oui` | `answerQuestion(session, questionId, isPositive: true)` |
| Bouton `Non` | `answerQuestion(session, questionId, isPositive: false)` |

Contraintes :

- un appui doit produire une nouvelle session immutable ;
- l'ecran remplace l'ancien etat par le nouvel etat ;
- le bouton doit etre desactive pendant le traitement si un futur stockage async est ajoute ;
- en cas de Hard Stop, les boutons Oui/Non ne doivent plus etre affiches.

## 5. Progression

La progression doit rester informative, pas clinique.

Champs attendus :

| Champ | Type cible | Source actuelle |
| --- | --- | --- |
| `answeredCount` | `int` | `answeredQuestionIds.length` |
| `totalQuestionCount` | `int` | `ClinicalScreeningQuestionnaireV4.questions.length` |
| `progressRatio` | `double` | `answeredCount / totalQuestionCount` |
| `progressLabel` | `String` | ex. `Question 4 sur 9` |

Si un Hard Stop survient, la progression peut etre interrompue avant 100 %. L'UI doit afficher que le questionnaire est interrompu pour raison clinique, pas qu'il est incomplet.

## 6. Niveau de risque courant

Le niveau de risque courant doit etre fourni a l'UI sous forme de `ClinicalDecisionLevel`.

Regle de derivation cible :

1. Si un Hard Stop est declenche, utiliser le `expectedDecisionLevel` du Hard Stop prioritaire.
2. Sinon, utiliser le `targetDecisionLevel` de l'hypothese dominante renforcee.
3. Sinon, retourner `routine`.

Libelles UI recommandes :

| Niveau | Libelle court |
| --- | --- |
| `routine` | Prise en charge habituelle |
| `monitor` | Surveillance renforcee |
| `medicalAdvice` | Avis medical recommande |
| `urgentReferral` | Avis medical rapide necessaire |
| `emergency` | Urgence immediate |

## 7. Hard Stop eventuel

Si `triggeredHardStopIds` n'est pas vide, l'ecran doit recevoir un objet d'alerte.

Champs attendus :

| Champ | Type cible | Source actuelle |
| --- | --- | --- |
| `hardStopId` | `String` | premier ID de `triggeredHardStopIds` ou hard stop prioritaire |
| `title` | `String` | `ClinicalHardStopRuleV5.title` |
| `description` | `String` | `ClinicalHardStopRuleV5.clinicalDescription` |
| `decisionLevel` | `ClinicalDecisionLevel` | `ClinicalHardStopRuleV5.expectedDecisionLevel` |
| `patientInstruction` | `String` | texte UI a definir |

Comportement UI attendu :

- interrompre les questions ;
- afficher l'alerte de maniere claire ;
- ne pas laisser croire que le questionnaire peut exclure une urgence ;
- proposer uniquement une action compatible avec le niveau obtenu.

## 8. Decision finale

La decision finale doit etre disponible quand :

- un Hard Stop est declenche ;
- ou aucune question suivante n'est disponible ;
- ou une future regle de fin explicite est ajoutee.

Champs attendus :

| Champ | Type cible | Role |
| --- | --- | --- |
| `decisionLevel` | `ClinicalDecisionLevel` | Niveau final. |
| `decisionLabel` | `String` | Libelle court affiche. |
| `primaryHypothesisId` | `String?` | Hypothese dominante si presente. |
| `primaryHypothesisTitle` | `String?` | Titre lisible. |
| `probabilityLevel` | `ClinicalQualitativeProbabilityV5?` | Probabilite qualitative obtenue. |
| `hardStopId` | `String?` | Hard Stop causal si present. |
| `isFinal` | `bool` | Controle l'ecran final. |

Le moteur V5 actuel ne calcule pas de pourcentage. L'UI ne doit afficher aucun pourcentage.

## 9. Texte explicatif court

L'ecran doit recevoir un texte court, distinct du `reasoningSummary` technique.

Champs attendus :

| Champ | Type cible | Exemple |
| --- | --- | --- |
| `shortExplanation` | `String` | `Certains elements justifient un avis medical rapide avant de poursuivre.` |
| `technicalSummary` | `String` | `ClinicalAdaptiveSessionV5.reasoningSummary` |

Regles de redaction :

- patient-compatible ;
- 1 a 2 phrases ;
- pas de diagnostic affirme ;
- parler d'hypothese ou de situation a verifier ;
- ne jamais dire qu'une pathologie grave est exclue.

Exemples :

```text
Aucun signal d'alerte V5 n'a ete retrouve dans ce questionnaire. La situation reste a interpreter par le professionnel.
```

```text
L'association de plusieurs elements justifie un avis medical rapide avant une prise en charge exclusive.
```

```text
Un element d'urgence potentielle a ete identifie. Il faut interrompre le questionnaire et suivre la conduite d'urgence.
```

## 10. Donnees a historiser

Les donnees historisees doivent permettre un audit clinique ulterieur sans reconstruire l'etat depuis l'UI.

Champs minimum :

| Champ | Type cible |
| --- | --- |
| `sessionId` | `String` |
| `createdAt` | `DateTime` |
| `completedAt` | `DateTime?` |
| `engineName` | `String` |
| `engineVersion` | `String` |
| `rulesetVersion` | `String` |
| `answeredQuestionIds` | `Map<String, bool>` |
| `positiveFlagIds` | `List<String>` |
| `hypothesisProbabilities` | `Map<String, ClinicalQualitativeProbabilityV5>` |
| `appliedProbabilityUpdateIds` | `List<String>` |
| `triggeredHardStopIds` | `List<String>` |
| `finalDecisionLevel` | `ClinicalDecisionLevel` |
| `primaryHypothesisId` | `String?` |
| `probabilityLevel` | `ClinicalQualitativeProbabilityV5?` |
| `shortExplanation` | `String` |
| `technicalSummary` | `String` |

Donnees a eviter :

- texte libre patient inutile ;
- pourcentages non calcules par le moteur ;
- inference UI non tracee ;
- modification locale des IDs cliniques.

## Contrat minimal cible

Forme conceptuelle du payload attendu par l'ecran :

```dart
class ClinicalAdaptiveViewStateV5 {
  final String sessionId;
  final String? questionId;
  final String? patientQuestionText;
  final bool canAnswer;
  final int answeredCount;
  final int totalQuestionCount;
  final double progressRatio;
  final ClinicalDecisionLevel currentRiskLevel;
  final String currentRiskLabel;
  final String? hardStopId;
  final String? hardStopTitle;
  final ClinicalDecisionLevel? finalDecisionLevel;
  final String? primaryHypothesisId;
  final ClinicalQualitativeProbabilityV5? probabilityLevel;
  final String shortExplanation;
  final String technicalSummary;
}
```

Ce payload doit etre produit par une future couche d'adaptation entre `ClinicalAdaptiveQuestionEngineV5` et l'ecran Flutter. L'ecran ne doit pas consommer directement les catalogues cliniques pour deduire une decision.

# Validation operationnelle V6 - moteur adaptatif V7

## Objet

Ce document synthetise l'etat de validation operationnelle du moteur adaptatif apres les lots V7-A, V7-B et V7-C.

Perimetre :
- moteur adaptatif V5/V7 isole ;
- aucune modification UI requise pour cette validation ;
- aucun remplacement du moteur V3 historique ;
- validation automatisee des scenarios critiques FN et des scenarios FP representables.

## Etat V7-A

V7-A a ajoute les briques minimales necessaires pour aligner le moteur sur les exigences V6.20 a V6.25 :

- scripts cliniques explicites ;
- domaines cervical vasculaire et AAA / vasculaire abdominal ;
- etat de hard stop gradue : `absent`, `suspected`, `confirmed` ;
- garde-fou `canReassure` ;
- impossibilite pour un argument rassurant de neutraliser un signal critique ;
- impossibilite pour le script psychosocial de neutraliser un script organique critique.

Scripts disponibles :
- `SCRIPT_MECANIQUE`
- `SCRIPT_ONCOLOGIQUE`
- `SCRIPT_INFECTIEUX`
- `SCRIPT_FRACTURE`
- `SCRIPT_NEUROLOGIQUE`
- `SCRIPT_QUEUE_DE_CHEVAL`
- `SCRIPT_VASCULAIRE`
- `SCRIPT_PSYCHOSOCIAL`
- `SCRIPT_CERVICAL_VASCULAIRE`
- `SCRIPT_AAA_VASCULAIRE_ABDOMINAL`

## Etat V7-B

V7-B a cree un fichier de validation automatisee dedie aux scenarios V6 :

- `CAS_FN_01` a `CAS_FN_15`
- `CAS_FP_01` a `CAS_FP_15`

Etat initial V7-B :
- 30 scenarios declares ;
- 16 scenarios executables et passes ;
- 14 scenarios skipped, principalement faute de representation des arguments rassurants mecaniques ou psychosociaux ;
- aucun echec critique sur les faux negatifs.

## Etat V7-C

V7-C a ajoute une reassurance mecanique minimale, sans modifier l'UI et sans affaiblir les hard stops.

Elements representes :
- douleur liee au mouvement ;
- douleur reproductible ;
- amelioration au repos ;
- surcharge mecanique coherente ;
- episode mecanique connu stable ;
- absence structuree de signes systemiques.

Principe de securite :
- ces arguments sont stockes separement dans `reassuringFlagIds` ;
- ils ne sont pas ajoutes aux `positiveFlagIds` organiques ;
- ils ne declenchent pas d'hypothese critique ;
- ils ne declenchent pas de hard stop ;
- ils ne peuvent soutenir `canReassure` que si `hardStopState == absent` et si aucun signal critique positif n'est present.

## Resultat operationnel final

Scenarios declares : 30

Scenarios executes : 26

Scenarios passes : 26

Scenarios skipped : 4

Echecs critiques : 0

Raison precise des skipped :
- absence de representation positive dediee au domaine psychosocial avance ;
- absence de representation positive dediee aux yellow flags isoles dans le moteur adaptatif actuel ;
- ces concepts sont volontairement laisses hors perimetre V7-C pour eviter une extension clinique non validee.

## Scenarios FN valides

Les 15 scenarios FN critiques sont executes et passent.

Points couverts :
- urgence immediate isolee ;
- queue de cheval ;
- embolie pulmonaire ;
- fracture ouverte ;
- douleur thoracique avec signe cardio-respiratoire ;
- infection fragile ;
- deficit neurologique progressif ;
- risque fracturaire ;
- TVP ;
- oncologie ;
- cervical vasculaire ;
- AAA / vasculaire abdominal ;
- signaux critiques malgre contexte mecanique ;
- signaux critiques apres reponses negatives initiales.

Conclusion FN : aucun faux negatif critique detecte dans les scenarios automatises representes.

## Scenarios FP valides

Scenarios FP executes et passes :

- `CAS_FP_01`
- `CAS_FP_02`
- `CAS_FP_03`
- `CAS_FP_04`
- `CAS_FP_08`
- `CAS_FP_09`
- `CAS_FP_10`
- `CAS_FP_11`
- `CAS_FP_12`
- `CAS_FP_13`
- `CAS_FP_14`

Ces scenarios confirment que le moteur peut conserver une decision `routine` et `canReassure == true` lorsque les signaux critiques sont absents et que le profil mecanique est rassurant.

## Scenarios non couverts

Scenarios skipped :

- `CAS_FP_05` : contexte psychosocial isole sans signe organique ;
- `CAS_FP_06` : anxiete elevee sans signe clinique critique ;
- `CAS_FP_07` : peur-evitement isolee sans red flag ;
- `CAS_FP_15` : yellow flags isoles sans signal organique.

Ces scenarios ne doivent pas etre forces a passer avant d'avoir ajoute une representation clinique dediee aux facteurs psychosociaux et yellow flags dans le moteur adaptatif.

## Tableau synthetique

| ID | Type | Statut | Decision attendue | Decision obtenue | HardStop attendu | HardStop obtenu | Commentaire |
| --- | --- | --- | --- | --- | --- | --- | --- |
| CAS_FN_01 | FN | Passe | emergency | emergency | confirmed | confirmed | Queue de cheval isolee, urgence immediate confirmee. |
| CAS_FN_02 | FN | Passe | emergency | emergency | confirmed | confirmed | Embolie pulmonaire suspectee isolee. |
| CAS_FN_03 | FN | Passe | emergency | emergency | confirmed | confirmed | Fracture ouverte suspectee. |
| CAS_FN_04 | FN | Passe | emergency | emergency | confirmed | confirmed | Douleur thoracique avec dyspnee ou malaise. |
| CAS_FN_05 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | Infectieux fragile, reassurance bloquee. |
| CAS_FN_06 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | Deficit neurologique progressif. |
| CAS_FN_07 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | Risque fracturaire sur terrain fragile. |
| CAS_FN_08 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | Suspicion TVP. |
| CAS_FN_09 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | Cluster oncologique. |
| CAS_FN_10 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | Cervical vasculaire suspect. |
| CAS_FN_11 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | AAA ou vasculaire abdominal suspect. |
| CAS_FN_12 | FN | Passe | emergency | emergency | confirmed | confirmed | Queue de cheval malgre contexte mecanique. |
| CAS_FN_13 | FN | Passe | emergency | emergency | confirmed | confirmed | Embolie pulmonaire apres premier danger negatif. |
| CAS_FN_14 | FN | Passe | emergency | emergency | confirmed | confirmed | Cardio-respiratoire apres dangers immediats negatifs. |
| CAS_FN_15 | FN | Passe | urgentReferral | urgentReferral | suspected | suspected | Cervical vasculaire apres TVP negative. |
| CAS_FP_01 | FP | Passe | routine | routine | absent | absent | Toutes les questions representees sont negatives. |
| CAS_FP_02 | FP | Passe | routine | routine | absent | absent | Douleur strictement mecanique reproductible. |
| CAS_FP_03 | FP | Passe | routine | routine | absent | absent | Profil mecanique sans signe systemique positif. |
| CAS_FP_04 | FP | Passe | routine | routine | absent | absent | Episode mecanique connu stable. |
| CAS_FP_05 | FP | Skipped | routine | non execute | absent | non execute | Psychosocial isole non represente. |
| CAS_FP_06 | FP | Skipped | routine | non execute | absent | non execute | Anxiete elevee non representee comme entree positive. |
| CAS_FP_07 | FP | Skipped | routine | non execute | absent | non execute | Peur-evitement isolee non representee. |
| CAS_FP_08 | FP | Passe | routine | routine | absent | absent | Douleur chronique stable sans changement recent. |
| CAS_FP_09 | FP | Passe | routine | routine | absent | absent | Trauma mineur sans critere fracturaire positif. |
| CAS_FP_10 | FP | Passe | routine | routine | absent | absent | Cervicalgie mecanique sans signe neurovasculaire. |
| CAS_FP_11 | FP | Passe | routine | routine | absent | absent | Lombalgie mecanique sans signe AAA. |
| CAS_FP_12 | FP | Passe | routine | routine | absent | absent | Symptome vague sans cluster systemique. |
| CAS_FP_13 | FP | Passe | routine | routine | absent | absent | Douleur thoracique musculosquelettique rassurante. |
| CAS_FP_14 | FP | Passe | routine | routine | absent | absent | Mollet douloureux sans criteres TVP. |
| CAS_FP_15 | FP | Skipped | routine | non execute | absent | non execute | Yellow flags isoles non representes dans ce lot. |

## Limites restantes

- Les scenarios psychosociaux ne sont pas encore representes comme entrees positives explicites.
- Les yellow flags isoles ne sont pas encore representes dans le moteur adaptatif V7.
- La validation reste automatisee et technique ; elle ne vaut pas validation clinique externe.
- Les libelles, questions et seuils doivent encore etre relus par un referent metier avant usage clinique reel.
- Les scenarios CAS_01 a CAS_30 de reference ne sont pas tous integres dans ce fichier V7 de validation operationnelle, meme si 11 scenarios V5 historiques existent deja dans les tests.

## Decision

Decision technique : candidat au gel clinique V1 interne pour le noyau de securite FN et la reassurance mecanique minimale.

Decision clinique : non pret pour beta clinique externe sans validation metier formelle, revue des scenarios psychosociaux, revue des yellow flags et verrouillage documentaire des regles.

Recommandation :
- geler provisoirement le comportement critique FN ;
- conserver les 4 skips comme ecarts documentes ;
- ouvrir un lot separe pour psychosocial et yellow flags, avec validation clinique explicite avant implementation.

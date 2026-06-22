# Matrice de validation clinique V1

Validation preparatoire des 11 scenarios cliniques contre `ClinicalAdaptiveQuestionEngineV5`.

La decision obtenue est derivee dans le test de validation depuis les Hard Stops V5 declenches, puis depuis l'hypothese dominante renforcee. Le moteur V5 reste autonome et n'est pas branche a l'UI ni au moteur V3 historique.

| Cas | Decision attendue | Decision obtenue | Hypothese dominante | Hard Stop | Nb questions | Conforme | Commentaire |
| --- | --- | --- | --- | --- | ---: | --- | --- |
| CAS_01_LOMBALGIE_SIMPLE | routine | routine | aucun renforcement | aucun | 9 | oui | Toutes les questions V4 repondues negativement, aucune hypothese V5 renforcee. |
| CAS_02_CANCER | urgentReferral | urgentReferral | v5_hypothesis_pathologie_oncologique, high | v5_hard_stop_oncologique | 9 | oui | Le cluster oncologique V5 declenche une orientation urgente ; le moteur actuel priorise d'abord les hypotheses initialement moderees. |
| CAS_03_DOULEUR_THORACIQUE | emergency | emergency | v5_hypothesis_syndrome_cardiorespiratoire_aigu, veryHigh | v5_hard_stop_cardiorespiratoire | 4 | oui | Douleur thoracique avec signe cardio-respiratoire apres exclusion des dangers immediats precedents. |
| CAS_04_CERVICALGIE_VASCULAIRE | urgentReferral | urgentReferral | v5_hypothesis_tvp, high | v5_hard_stop_vasculaire_tvp | 8 | oui | La couche V5 actuelle ne distingue pas encore cervical vasculaire et TVP ; validation via le cluster vasculaire disponible. |
| CAS_05_TVP | urgentReferral | urgentReferral | v5_hypothesis_tvp, high | v5_hard_stop_vasculaire_tvp | 8 | oui | Suspicion TVP / vasculaire orientee vers avis rapide. |
| CAS_06_INFECTION | urgentReferral | urgentReferral | v5_hypothesis_infection_systemique_fragile, high | v5_hard_stop_infectieux_fragile | 5 | oui | Signes infectieux sur terrain fragile. |
| CAS_07_FRACTURE | urgentReferral | urgentReferral | v5_hypothesis_fracture_fragilite, high | v5_hard_stop_risque_fracturaire | 7 | oui | Risque fracturaire sur terrain fragile apres exclusion de fracture ouverte. |
| CAS_08_DEFICIT_NEUROLOGIQUE | urgentReferral | urgentReferral | v5_hypothesis_atteinte_neurologique_progressive, high | v5_hard_stop_neurologique | 6 | oui | Deficit neurologique progressif oriente vers avis rapide. |
| CAS_09_YELLOW_FLAGS | routine | routine | aucun renforcement | aucun | 9 | oui | Les yellow flags ne sont pas encore representes dans le questionnaire V4/V5 adaptatif ; absence de signal V5 positif. |
| CAS_10_REASSURANCE | routine | routine | aucun renforcement | aucun | 9 | oui | Toutes les questions V4 repondues negativement. |
| CAS_11_QUEUE_DE_CHEVAL | emergency | emergency | v5_hypothesis_queue_cheval, veryHigh | v5_hard_stop_queue_cheval | 1 | oui | Hard Stop immediat des la premiere question. |

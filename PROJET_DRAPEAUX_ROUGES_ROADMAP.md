# PROJET DRAPEAUX ROUGES MK

## Roadmap stratégique, clinique et technique

---

# 1. Vision du projet

## Objectif principal

Créer une application moderne d’aide à la décision clinique destinée aux masseurs-kinésithérapeutes en accès direct.

L’application vise à :

* améliorer la sécurité clinique ;
* standardiser le repérage des drapeaux rouges ;
* faciliter l’orientation médicale ;
* structurer les bilans ;
* générer des exports professionnels ;
* produire à terme des statistiques anonymisées nationales.

---

# 2. Positionnement clinique

## Public cible

* Masseurs-kinésithérapeutes
* Accès direct MK
* Structures libérales
* MSP / CPTS
* Centres de rééducation
* Consultation de première intention

## Utilisation principale

L’application sert d’outil de triage clinique et d’aide au raisonnement.

Elle ne doit jamais être présentée comme :

* un outil diagnostique autonome ;
* une IA médicale ;
* un système de décision automatique.

---

# 3. Fonctionnalités actuelles

## Évaluation clinique

* sélection par motif/pathologie ;
* drapeaux rouges ciblés ;
* score de gravité ;
* moteur décisionnel ;
* synthèse clinique.

## Motifs déjà présents

* Lombalgie
* Entorse de cheville
* Respiratoire adulte
* Orthopédie générale
* Cervicalgie
* Cardiaque
* TVP / vasculaire
* Post-opératoire

## Recommandations intégrées

* Règles d’Ottawa
* Signes neurovasculaires
* Suspicion de queue de cheval
* Suspicion infectieuse
* Signes cardiorespiratoires

## Exports

* PDF clinique professionnel
* CSV
* Historique local

## UX

* Design Apple-like
* Compatible iPhone/iPad
* Navigation moderne
* Interface tactile optimisée

---

# 4. Architecture actuelle Flutter

## Structure actuelle

```text
lib/
 ├── data/
 ├── screens/
 ├── services/
 ├── widgets/
 ├── theme/
 └── main.dart
```

## Services actuels

### Services métier

* clinical_ai_service
* decision_engine_service
* history_service
* csv_service
* pdf_service

### Widgets UI

* header_card
* result_card
* category_card
* decision_card
* action_buttons

---

# 5. Architecture cible recommandée

## Structure cible

```text
lib/
 ├── core/
 │    ├── constants/
 │    ├── utils/
 │    └── theme/
 │
 ├── data/
 │    ├── local/
 │    ├── models/
 │    └── repositories/
 │
 ├── features/
 │    ├── patient/
 │    ├── evaluation/
 │    ├── dashboard/
 │    ├── history/
 │    └── settings/
 │
 ├── services/
 ├── widgets/
 └── main.dart
```

---

# 6. Nouvelle organisation des onglets

## Architecture future

### 1. Patient

Contenu :

* titre application ;
* consentement RGPD ;
* informations locales patient ;
* pseudonymisation ;
* création du dossier local.

### 2. Évaluation

Contenu :

* motif/pathologie ;
* drapeaux rouges ;
* score ;
* moteur décisionnel ;
* synthèse ;
* export PDF.

### 3. Historique

Contenu :

* liste des évaluations ;
* recherche ;
* suppression ;
* exports.

### 4. Dashboard

Contenu :

* statistiques ;
* fréquences ;
* répartition ;
* suivi clinique.

### 5. Paramètres

Contenu :

* informations application ;
* RGPD ;
* version ;
* préférences ;
* mentions légales.

---

# 7. Données patient et RGPD

## Objectif

Permettre un suivi clinique local sans transmission nominative.

## Données locales possibles

* nom ;
* prénom ;
* date de naissance ;
* notes cliniques ;
* historique.

## Règles essentielles

Ces données doivent :

* rester uniquement sur l’appareil ;
* ne jamais être exportées automatiquement ;
* ne jamais être transmises sans consentement.

---

# 8. Pseudonymisation

## Fonctionnement souhaité

L’application génère automatiquement un identifiant pseudonymisé.

Exemple :

```text
MK-4F7A92B1
```

Ce code servira :

* aux exports ;
* aux statistiques ;
* aux dashboards ;
* aux futures synchronisations.

---

# 9. Différence pseudonymisation / anonymisation

## Pseudonymisation

Le patient reste potentiellement identifiable localement.

Le code patient permet un suivi.

=> Le RGPD continue de s’appliquer.

## Anonymisation réelle

Impossible de retrouver le patient.

=> données non ré-identifiables.

---

# 10. Vision cloud HDS

## Objectif futur

Créer une infrastructure nationale sécurisée.

## Fonctionnalités futures

* comptes professionnels ;
* synchronisation ;
* sauvegarde cloud ;
* statistiques nationales ;
* dashboard régional ;
* recherche clinique.

## Hébergement

Hébergement HDS obligatoire si données de santé.

---

# 11. Standardisation nationale

## Vision long terme

Chaque professionnel utilise :

* la même structure ;
* les mêmes questionnaires ;
* les mêmes scores ;
* les mêmes exports.

## Possibilités futures

* observatoire national ;
* indicateurs de sécurité ;
* suivi accès direct ;
* statistiques anonymisées.

---

# 12. Sources scientifiques de référence

## Sources principales

* HAS
* URPS
* CMK
* IFOMPT
* Recommandations accès direct
* Règles d’Ottawa
* Score de Wells
* Recommandations rachis
* Recommandations cervicales

## Futur système

Chaque questionnaire pourra contenir :

* source ;
* date ;
* niveau de preuve ;
* lien scientifique.

---

# 13. Roadmap produit

## Phase 1 — Application locale premium

### Objectifs

* UX Apple-like
* architecture propre
* stockage local
* dossier patient
* PDF premium
* dashboard
* navigation swipe

### Statut

En cours.

---

## Phase 2 — Architecture professionnelle

### Objectifs

* SQLite propre
* modèles Dart structurés
* vraie base locale
* sauvegardes
* authentification professionnelle
* multi-utilisateurs

### Statut

À planifier.

---

## Phase 3 — Cloud HDS

### Objectifs

* synchronisation ;
* hébergement sécurisé ;
* partage clinique ;
* statistiques.

### Statut

Vision long terme.

---

## Phase 4 — IA clinique avancée

### Objectifs

* aide au raisonnement ;
* recommandations ;
* analyses prédictives ;
* génération de synthèses.

### Important

Toujours conserver :

* validation humaine ;
* supervision clinique ;
* prudence réglementaire.

---

# 14. Dette technique actuelle

## Points à améliorer

### HomeScreen trop volumineux

À découper.

### Mélange logique/UI

Créer :

* modèles ;
* repositories ;
* controllers.

### Historique

Passer vers SQLite.

### PDF

Créer templates séparés.

### Dashboard

Créer vraie couche analytics.

---

# 15. Évolutions UX recommandées

## Court terme

* swipe horizontal ;
* animations ;
* mode sombre ;
* responsive tablette ;
* transitions fluides.

## Moyen terme

* recherche intelligente ;
* favoris ;
* filtres ;
* widgets rapides.

## Long terme

* Siri shortcuts ;
* widgets iOS ;
* dictée vocale ;
* IA conversationnelle.

---

# 16. Vision finale

Créer une plateforme moderne de sécurité clinique MK.

Objectifs finaux :

* sécuriser l’accès direct ;
* standardiser les pratiques ;
* produire des données utiles ;
* améliorer l’orientation ;
* développer un écosystème national.

---

# 17. Priorités immédiates

## Priorité 1

Créer le nouvel onglet Patient.

## Priorité 2

Déplacer RGPD et identité patient.

## Priorité 3

Navigation swipe.

## Priorité 4

Refactor architecture.

## Priorité 5

SQLite locale.

---

# 18. Important — prudence réglementaire

L’application doit toujours afficher clairement :

* qu’elle constitue une aide clinique ;
* qu’elle ne pose pas de diagnostic ;
* qu’elle ne remplace pas un avis médical.

---

# 19. Nom du projet

## Nom actuel

Accès Direct MK — Drapeaux Rouges

## Possibilités futures

* MK Safe
* Red Flags MK
* Triage MK
* Accès Direct Clinical
* Sentinel MK
* Vigilance MK

---

# 20. Conclusion

Le projet a désormais :

* une vraie logique produit ;
* une vision clinique ;
* une architecture logicielle ;
* une stratégie RGPD ;
* une roadmap technique.

Le prochain objectif est maintenant de transformer l’application actuelle en véritable plateforme clinique structurée.

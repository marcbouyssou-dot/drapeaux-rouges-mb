# Mode hors ligne

## Principe

L'application reste locale-first. Après un premier chargement en ligne et une
authentification réussie, elle enregistre uniquement un état minimal autorisant
l'accès hors ligne sur cet appareil.

## Première connexion obligatoire

Une première connexion avec internet est nécessaire. Tant qu'elle n'a pas eu
lieu, l'application affiche :

- `Première connexion requise`
- `Vous devez vous identifier une première fois avec une connexion internet.`

Le mot de passe n'est jamais stocké localement.

## Session hors ligne

Après une authentification réussie, l'application stocke :

- `authenticatedOnce: true`
- `lastSuccessfulLoginAt`
- une date d'expiration locale

La durée de validité actuelle est de 90 jours. Si cette durée est dépassée :

- en ligne : le login classique est demandé ;
- hors ligne : l'écran `Connexion requise pour renouveler la session` est
  affiché.

## Fonctions disponibles hors ligne

Les fonctions locales restent disponibles après une première connexion :

- création et consultation patient locale ;
- évaluations ;
- Clinical Reasoning local ;
- historique local ;
- prescriptions locales ;
- attestations locales ;
- courriers médicaux locaux ;
- génération PDF locale ;
- réglages locaux.

Un badge discret `Hors ligne` est affiché dans la navigation principale.

## Fonctions indisponibles hors ligne

Toute fonction nécessitant un serveur distant doit être désactivée ou retardée.
Dans cette version, aucun stockage distant n'est configuré. La synchronisation
prépare donc la file locale sans transmettre de données vers un serveur.

## File de synchronisation

Chaque évaluation créée hors ligne reçoit des métadonnées locales :

- `localId`
- `idempotencyKey`
- `syncStatus`
- `createdAt`
- `updatedAt`
- `syncedAt`
- `lastSyncError`

Les statuts possibles sont :

- `localOnly` : donnée locale créée en ligne, sans backend distant configuré ;
- `pendingSync` : donnée créée hors ligne, en attente ;
- `syncing` : synchronisation en cours ;
- `synced` : confirmation distante reçue ;
- `syncFailed` : tentative échouée, donnée conservée localement.

L'application ne supprime jamais une donnée locale tant qu'un serveur n'a pas
confirmé sa réception. L'`idempotencyKey` permet d'éviter les doublons lorsqu'un
backend sera raccordé.

## Retour en ligne

Quand le réseau revient, l'application relance la file de synchronisation des
évaluations `pendingSync` ou `syncFailed`. Un bouton `Synchroniser maintenant`
est aussi disponible dans les réglages.

Si aucune destination distante n'est configurée, les données restent locales et
la tentative peut être marquée en échec avec un message explicite.

## Conflits

Aucun mécanisme de résolution de conflit distant n'est actif dans cette version.
La règle conservatrice est de préserver la donnée locale et de ne la marquer
comme synchronisée qu'après confirmation serveur.

## Procédure de test

1. Ouvrir l'application en ligne.
2. Se connecter.
3. Couper le réseau ou activer le mode avion.
4. Fermer puis relancer la PWA.
5. Vérifier que l'application démarre sans boucle sur le login.
6. Vérifier le badge `Hors ligne`.
7. Créer une évaluation.
8. Vérifier dans l'historique que l'évaluation est en attente de sync.
9. Réactiver le réseau.
10. Utiliser `Synchroniser maintenant` dans les réglages ou attendre la relance
    automatique.

## Limites actuelles

Le service distant n'est pas encore raccordé. La file est prête pour un futur
backend, mais aucune donnée patient n'est transmise dans cette version.

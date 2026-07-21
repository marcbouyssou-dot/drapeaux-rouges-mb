# Déploiement Radar RC1

## Pré-requis

- Flutter installé
- Accès au dépôt GitHub
- Compte Netlify

## Build local

```bash
flutter build web --release --target lib/main_radar.dart
```

## Branche

La branche `radar-rc1` n'existe pas encore localement ni sur `origin` au moment de cet audit.

```bash
git switch -c radar-rc1
```

## Netlify

```text
Branch to deploy: radar-rc1
Build command: flutter build web --release --target lib/main_radar.dart
Publish directory: build/web
```

## Test après déploiement

- ouvrir URL sur Mac ;
- ouvrir URL sur Safari iPhone ;
- ajouter à l'écran d'accueil ;
- tester un cas simple ;
- tester un Hard Stop ;
- ouvrir le BDK ;
- tester le PDF ;
- ne pas utiliser de patient réel.

## Limite officielle

Cette version utilise `lib/main_radar.dart` et `RadarDemoShell`.
Elle constitue une préproduction RC1.1 destinée aux tests internes.

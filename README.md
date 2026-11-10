# MATCH REPORT 62 — Starter Flutter

Prototype initial Flutter pour l'application de reporting football MATCH REPORT 62.

## Contenu actuel
- Tableau de bord de démonstration
- Effectif local : ajout et suppression de joueurs
- Écran de match : chronomètre et boutons d'événements
- Sélection facultative d'un joueur après un événement
- Thème clair/sombre
- Interface français/anglais

## Limites importantes
Cette version est un prototype local. Elle n'est pas encore connectée à Firebase.
Les joueurs et événements sont conservés uniquement en mémoire et sont perdus à la fermeture.
Aucune authentification, synchronisation multi-téléphones ou base persistante n'est encore implémentée.

## Identité Android prévue
Application : MATCH REPORT 62
Application ID / package : fr.matchreport62.app

## Générer les dossiers natifs
Dans un environnement avec Flutter installé, à la racine du projet :

```bash
flutter create --platforms=android,ios --org fr.matchreport62 --project-name app .
```

Le fichier `codemagic.yaml` ajuste ensuite l'identifiant Android à `fr.matchreport62.app` avant la compilation. Si tu exécutes les commandes manuellement, vérifie `namespace` et `applicationId` dans `android/app/build.gradle.kts` et définis-les tous les deux à `fr.matchreport62.app`.

## Préparer Firebase ensuite
1. Installer FlutterFire CLI dans l'environnement de développement.
2. Exécuter `flutterfire configure` et sélectionner le projet Firebase MATCH REPORT 62.
3. Sélectionner Android (et iOS lors de la phase iPhone).
4. Ajouter les dépendances `firebase_core`, `firebase_auth` et `cloud_firestore`.
5. Initialiser Firebase avec `DefaultFirebaseOptions.currentPlatform`.
6. Configurer les règles Firestore avant toute utilisation réelle.

Ne pas placer de clés privées ou de comptes de service dans ce dépôt.

## Compilation Android
Après création des dossiers natifs et configuration Flutter :

```bash
flutter build apk --release
```

APK attendu :
`build/app/outputs/flutter-apk/app-release.apk`

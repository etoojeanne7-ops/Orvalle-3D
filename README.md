# Orvalle 3D

Projet de jeu d'aventure 3D avec une cible native Godot 4 et un workflow de validation continue.

> **État réel du transfert :** le dépôt est en cours d'initialisation. Le paquet complet préparé dans ChatGPT doit encore être importé dans ce dépôt. Les fichiers de CI ci-dessous attendent le dossier `OrvalleNative/`.

## Structure attendue

- `OrvalleNative/project.godot` — projet natif Godot.
- `OrvalleNative/scenes/Main.tscn` — scène de démarrage.
- `OrvalleNative/scripts/` — gameplay, terrain, joueur, acteurs.
- `OrvalleNative/tests/` — tests automatisés.
- `.github/workflows/orvalle-godot-check.yml` — validation Godot automatisée.

## Lancer localement

1. Installer Godot 4.3 ou une version compatible.
2. Ouvrir `OrvalleNative/project.godot` dans Godot.
3. Lancer la scène principale.
4. Exécuter les tests headless décrits dans le workflow GitHub Actions.

## Qualité et limites connues

Les workflows sont des contrôles automatiques, pas une preuve de qualité graphique ou de compatibilité sur appareil. Les personnages doivent être considérés comme provisoires tant que de vrais modèles 3D riggés et photoréalistes ne sont pas intégrés et validés. Les exports Android/Windows et les tests sur appareils réels doivent être confirmés par des exécutions réussies.

## Transfert des fichiers

Le paquet complet du workspace préparé est disponible dans la conversation sous le nom `Orvalle-3D-CI-Prepared.zip`. Il doit être importé à la racine du dépôt en conservant les dossiers du projet. Ne pas importer le dossier parent `orvalle-workspace` comme seul niveau du jeu : les chemins du workflow supposent que `OrvalleNative/` et `.github/` sont à la racine.

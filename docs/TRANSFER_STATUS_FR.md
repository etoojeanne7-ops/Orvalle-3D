# Orvalle — état du transfert

Date de préparation : 13 octobre 2026.

## Déjà ajouté à ce dépôt

- README de dépôt.
- Workflow GitHub Actions pour vérifier les fichiers, importer le projet Godot, lancer les tests de parité terrain et exécuter un test de démarrage headless.
- Fichier .gitignore pour les fichiers générés par Godot.

## En attente d'importation

Le paquet `Orvalle-3D-CI-Prepared.zip` contient le workspace préparé, dont le dossier `OrvalleNative/`, les scripts GDScript, la scène principale, les images et les tests. Le paquet complet n'est pas encore décompressé dans l'arborescence GitHub. Il faut importer les fichiers du dossier interne `orvalle-workspace/` à la racine du dépôt en préservant leurs chemins.

## Ce qui n'est pas encore validé

- La compilation et l'exécution Godot.
- Les exports APK/AAB et Windows EXE.
- Les performances sur appareil réel.
- La présence de modèles 3D photoréalistes définitifs : le rapport de QA précise que les mannequins procéduraux sont provisoires.

Un workflow en place ne signifie pas qu'il a déjà réussi. Consulter l'onglet **Actions** pour l'état réel après importation du projet.

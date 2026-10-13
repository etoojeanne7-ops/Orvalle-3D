# Orvalle 3D

Projet d'aventure 3D basé sur Godot 4, avec validation automatisée par GitHub Actions.

## Importer le projet préparé

Le dépôt contient déjà le workflow `.github/workflows/orvalle-godot-check.yml`. Pour transférer l'ensemble du workspace préparé depuis ChatGPT, téléverse le fichier **`Orvalle-3D-CI-Prepared.zip` à la racine de ce dépôt**. Le workflow sait ouvrir cette archive dans l'environnement de CI et rechercher le projet natif à l'intérieur.

Lien du dépôt : https://github.com/etoojeanne7-ops/Orvalle-3D

### Import via le site GitHub

1. Ouvre l'onglet **Code**.
2. Appuie sur **Add file → Upload files**.
3. Sélectionne `Orvalle-3D-CI-Prepared.zip` depuis ton appareil.
4. Valide le commit sur la branche `main`.
5. Ouvre l'onglet **Actions** pour voir le résultat réel du workflow.

Le ZIP est une archive de transfert : si tu veux que chaque script et ressource apparaisse comme un fichier normal dans l'arborescence GitHub, il faudra ensuite importer le contenu du dossier interne `orvalle-workspace/` à la racine, ou faire un push Git depuis un environnement local.

## Workflow de validation

Le workflow tente de :
- localiser le projet Godot directement dans `OrvalleNative/` ou dans le ZIP ;
- importer et analyser le projet avec Godot 4.3 en mode headless ;
- exécuter les tests de parité du terrain ;
- lancer un test de démarrage de la scène principale.

Un workflow ajouté n'est pas la preuve qu'il a réussi. Le résultat n'est confirmé que lorsque GitHub Actions termine avec le statut **Success**.

## Limites connues

- Les exports Android (APK/AAB) et Windows (EXE) ne sont pas encore configurés ni validés.
- Les tests de performance doivent être effectués sur appareils réels.
- Les modèles de personnages photoréalistes définitifs ne sont pas encore intégrés ; le rapport de QA du paquet précise que les acteurs procéduraux sont provisoires.

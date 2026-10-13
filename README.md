# Orvalle 3D

Projet d'aventure 3D basé sur Godot 4, avec validation automatisée par GitHub Actions.

## Pipeline personnages 3D réalistes

Le dépôt comprend maintenant :
- [Guide de production 3D en français](docs/PIPELINE_3D_FR.md)
- [Exporteur Blender vers GLB](tools/blender_export_character.py)
- [Contrôle structurel GLB](tools/validate_character_glb.py)
- [Workflow de validation des personnages](.github/workflows/character-realism-gate.yml)

Les fichiers finaux attendus sont `OrvalleNative/characters/Lena.glb` et `OrvalleNative/characters/Marec.glb`. Le contrôle échoue volontairement tant qu'ils sont absents ou incomplets. Un PASS structurel ne prouve pas le photoréalisme : une revue visuelle et des tests en jeu restent nécessaires.

## Importer le projet préparé

Le workflow `.github/workflows/orvalle-godot-check.yml` sait rechercher le projet natif dans le dossier `OrvalleNative/` ou dans l'archive de transfert. Le workspace complet n'est pas encore décompressé dans l'arborescence GitHub.

Lien du dépôt : https://github.com/etoojeanne7-ops/Orvalle-3D

### Import via le site GitHub
1. Ouvre l'onglet **Code**.
2. Appuie sur **Add file → Upload files**.
3. Sélectionne `Orvalle-3D-CI-Prepared-Realism-Pipeline.zip` depuis ton appareil.
4. Valide le commit sur la branche `main`.
5. Ouvre l'onglet **Actions** pour voir les résultats réels.

L'archive contient des ressources binaires qui ne sont pas encore intégrées dans le dépôt. Le workflow Godot échoue donc tant que l'import complet n'est pas réalisé.

## État de validation

Le workflow de personnages a été exécuté par GitHub Actions et a échoué pour la raison attendue : les modèles `Lena.glb` et `Marec.glb` sont absents. Résultat réel : [exécution du contrôle des personnages](https://github.com/etoojeanne7-ops/Orvalle-3D/actions/runs/38454234566).

Les exports Android/Windows, la compilation Godot, les performances sur appareils réels et le photoréalisme des personnages ne sont pas validés à ce stade.

# Orvalle 3D

Projet d'aventure 3D basé sur Godot 4, avec validation automatisée par GitHub Actions.

## Pipeline personnages 3D réalistes

Le dépôt comprend :
- [Guide de production 3D en français](docs/PIPELINE_3D_FR.md)
- [Exporteur Blender vers GLB](tools/blender_export_character.py)
- [Validateur structurel GLB](tools/validate_character_glb.py)
- [Tests du validateur](tools/test_validate_character_glb.py)
- [Workflow de validation des personnages](.github/workflows/character-realism-gate.yml)

Les fichiers finaux attendus sont `OrvalleNative/characters/Lena.glb` et `OrvalleNative/characters/Marec.glb`. Les tests unitaires du validateur passent sur GitHub Actions. Le contrôle des personnages échoue encore volontairement tant que les modèles finaux sont absents ou incomplets. Un PASS structurel ne prouve pas le photoréalisme : une revue visuelle et des tests en jeu restent nécessaires.

## Importer le projet préparé

Le workflow `.github/workflows/orvalle-godot-check.yml` recherche le projet natif dans `OrvalleNative/` ou dans l'archive de transfert. Le workspace complet n'est pas encore décompressé dans l'arborescence GitHub.

Lien du dépôt : https://github.com/etoojeanne7-ops/Orvalle-3D

### Import via le site GitHub
1. Ouvre l'onglet **Code**.
2. Appuie sur **Add file → Upload files**.
3. Sélectionne `Orvalle-3D-CI-Prepared-Realism-Pipeline.zip` depuis ton appareil.
4. Valide le commit sur la branche `main`.
5. Ouvre l'onglet **Actions** pour voir les résultats réels.

L'archive préparée contient les scripts du jeu et les ressources binaires du workspace. Elle n'a pas pu être importée automatiquement dans le dépôt par la connexion GitHub disponible dans cette session. Le workflow Godot échoue donc tant que l'import complet n'est pas réalisé.

## État de validation

Exécution la plus récente du contrôle de personnages : [GitHub Actions — run 4](https://github.com/etoojeanne7-ops/Orvalle-3D/actions/runs/38454871128).

Résultat réel : les tests unitaires du validateur ont réussi, puis le contrôle des modèles a échoué parce que `Lena.glb` et `Marec.glb` sont absents. La compilation Godot échoue séparément avant de démarrer, car le projet complet n'est pas encore présent dans le dépôt.

Les exports Android/Windows, la compilation Godot, les performances sur appareils réels et le photoréalisme des personnages ne sont pas validés à ce stade.

# Orvalle — état du transfert

Date de mise à jour : 13 octobre 2026.

## Ajouts réalisés dans GitHub
- Guide de chaîne de production 3D et critères de réalisme.
- Script Blender d'export des personnages sélectionnés vers GLB.
- Validateur GLB sans dépendances, qui vérifie maillage, matériaux, textures, skinning, animation et scène.
- Workflow GitHub Actions dédié au contrôle des modèles.

## Résultat CI observé
L'exécution du contrôle des personnages s'est terminée en échec car les fichiers requis Lena.glb et Marec.glb ne sont pas encore dans le dépôt. C'est un échec réel et attendu : il empêche de faire passer les placeholders pour des personnages finis.

Lien du résultat : https://github.com/etoojeanne7-ops/Orvalle-3D/actions/runs/38454234566

## En attente
- Importer le workspace Godot complet et ses ressources binaires depuis Orvalle-3D-CI-Prepared-Realism-Pipeline.zip.
- Créer ou acquérir légalement les modèles 3D finaux, les riguer, les texturer et exporter les animations.
- Valider visuellement les visages, la peau, les cheveux, les mains, les déformations et le jeu d'acteur.
- Tester Godot, les performances sur le matériel cible et les exports APK/AAB et Windows EXE.

Aucun modèle photoréaliste ni build du jeu n'est déclaré terminé avant disponibilité des fichiers et vérification effective.

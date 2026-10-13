# Orvalle — projet natif Godot 4.3

Ce dossier contient le socle jouable du jeu : terrain 3D généré par bruit, collisions, éclairage avec ombres, ciel, végétation, rochers, contrôleur de déplacement et caméra.

## Lancement
Ouvrir ce dossier dans Godot 4.3 et lancer `scenes/main.tscn`. Le workflow GitHub Actions copie automatiquement la base humaine sous licence CC0 dans `characters/` après vérification du fichier source.

## Contrôles
- WASD ou flèches : déplacement.
- Souris : orientation de la caméra.
- Échap : libérer la souris ; clic : la recapturer.

## Personnages et niveau de réalisme
Le jeu charge `characters/orvalle_human_base_cc0.glb` si le fichier est présent et tente de jouer une animation disponible. En cas d'absence du GLB, il affiche un proxy capsule pour les tests. Le modèle CC0 actuel est un **modèle humain de base riggé**, pas un humain photoréaliste final. Il ne faut pas le présenter comme Lena ou Marec ni comme un personnage fini.

Le terrain utilise une texture PBR réelle « Forest Ground 01 » de Poly Haven (albedo et roughness 2K, licence CC0), avec variation procédurale complémentaire, relief/collision, ciel et ombres. Les arbres et rochers restent actuellement procéduraux : le niveau global n'est donc pas encore photoréaliste. Les modèles 3D Poly Haven sont également CC0, mais chaque asset doit être choisi selon son poids et son niveau de détail avant intégration.

## Critères avant de déclarer le jeu terminé
- Remplacer la base humaine par des personnages réalistes avec visage détaillé, yeux, cheveux, vêtements, rig et animations testés.
- Vérifier visuellement l'échelle et l'orientation du GLB dans Godot.
- Utiliser des textures PBR et des assets environnementaux sous licence vérifiée.
- Passer les contrôles de chargement, de mouvement, d'animation et de performance sur l'appareil cible.

Les personnages Lena et Marec ne sont pas déclarés terminés tant que leurs modèles finaux n'existent pas et ne passent pas les tests visuels, de rig, d'animation et d'intégration.

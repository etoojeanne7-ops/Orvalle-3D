# Orvalle — projet natif Godot

Ce dossier contient le socle natif jouable d'Orvalle : scène 3D, éclairage, terrain procédural, contrôleur de déplacement, caméra et HUD.

## Lancer
Ouvrir ce dossier dans Godot 4.3, puis lancer la scène principale `scenes/main.tscn`.

## Contrôles
- WASD ou flèches : déplacement.
- Souris : orientation de la caméra.
- Échap : libérer la souris ; clic : la recapturer.

## État honnête
Le mannequin visible actuellement est un proxy technique simple, pas un personnage photoréaliste final. Le modèle humain CC0 stocké dans `../assets/characters/` est un asset de base distinct. Les personnages Lena et Marec ne sont pas considérés terminés tant que leurs GLB finaux n'existent pas et ne passent pas les contrôles visuels, de rig, d'animation et d'intégration.

# Orvalle — chaîne de production 3D réaliste

## Objectif
Produire de vrais personnages 3D skinnés, animés et texturés, intégrables au jeu. Aucun mannequin procédural ou portrait 2D ne doit être présenté comme un personnage photoréaliste fini.

## Chaîne recommandée
1. Blender (gratuit) : modélisation, sculpt, retopologie, UV, rigging, actions d'animation et export GLB.
2. Nomad Sculpt (option tablette) ou ZBrush (payant) : sculpture détaillée si disponible; facultatif.
3. Substance 3D Painter (licence à vérifier) : textures PBR. Alternative sans achat : peinture et baking dans Blender.
4. Godot 4 (moteur actuel) : import GLB, matériaux, animation, éclairage et profiling. Garder Godot comme cible par défaut pour éviter une migration coûteuse.
5. Unreal Engine / Unity : évaluation sur prototype séparé uniquement si des exigences visuelles mesurées ne sont pas atteignables dans Godot. Une migration n'est pas autorisée par simple préférence esthétique.

Maya, 3ds Max et Cinema 4D sont des options professionnelles, mais non nécessaires pour démarrer et ne doivent pas être achetés automatiquement.

## Contrat des modèles
Les fichiers attendus sont OrvalleNative/characters/Lena.glb et OrvalleNative/characters/Marec.glb.
- maillage humain propre, topologie adaptée aux expressions et aux déformations;
- armature humanoïde, poids contrôlés, mains et doigts articulés;
- visage avec asymétries crédibles, yeux/cornée/iris, paupières et bouche;
- textures PBR de peau (base color, roughness, normal), cheveux, tissus et équipements;
- animations exportées (au minimum Idle et Walk; idéalement Run, Crouch, Talk et React);
- échelle en mètres, orientation et origine cohérentes;
- niveau de détail, textures et matériaux compatibles avec le budget mémoire/GPU cible.

## Export Blender
Dans Blender, sélectionne les maillages du personnage et son armature, puis exécute :
blender --background personnage.blend --python tools/blender_export_character.py -- --output OrvalleNative/characters/Lena.glb

Adapte le nom de sortie pour Marec. Le script exporte ce qui existe dans le fichier; il ne crée pas automatiquement le modèle.

## Contrôle automatisé
Exécuter depuis la racine du dépôt :
python tools/validate_character_glb.py OrvalleNative/characters

Le contrôle vérifie la structure GLB et la présence de maillage, matériau, textures, skin et animation. Il ne peut pas juger à lui seul le photoréalisme, la ressemblance, les expressions, le lip-sync, les pieds qui glissent ou la qualité artistique. Ces critères demandent une revue visuelle et des tests dans le moteur.

## Porte qualité honnête
- BLOCKED : modèle absent ou export structurellement incomplet.
- STRUCTURE PASS : GLB contient les composants requis; cela ne signifie pas photoréalisme confirmé.
- VISUAL REVIEW PASS : revue humaine du visage, peau, cheveux, mains, déformations, animation, lumière et performances documentée séparément.

## Comparaison moteur
- Godot : choix initial, déjà utilisé par Orvalle; import GLB et CI plus simple, aucun portage nécessaire.
- Unreal Engine : à tester si le jeu exige des fonctionnalités de rendu haut de gamme et si le matériel cible les supporte.
- Unity : alternative viable mais nécessite une réimplémentation des scènes/scripts.
La décision finale doit être fondée sur un même personnage, une même scène, une même résolution et des mesures GPU/RAM sur le matériel visé. Aucun moteur ne transforme automatiquement un modèle basique en humain photoréaliste.

## Limites vérifiées
Les modèles finaux ne sont pas encore présents dans le workspace préparé. Les outils de sculpture/rendu locaux ne sont pas garantis installés. Ne jamais annoncer un modèle ou un build comme terminé sans fichier et test vérifiables.

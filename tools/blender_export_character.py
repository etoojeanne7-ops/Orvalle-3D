"""Export the currently selected Orvalle character from Blender to GLB.

Usage:
  blender --background character.blend --python tools/blender_export_character.py -- --output OrvalleNative/characters/Lena.glb

Select the character mesh(es) and its armature before running. This helper
exports assets; it does not sculpt, rig, or make a character photorealistic.
"""
from pathlib import Path
import sys

import bpy


def argument_after(flag: str, default: str) -> str:
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    try:
        return args[args.index(flag) + 1]
    except (ValueError, IndexError):
        return default


def main() -> None:
    output = Path(argument_after("--output", "OrvalleNative/characters/Character.glb")).resolve()
    selected = list(bpy.context.selected_objects)
    meshes = [obj for obj in selected if obj.type == "MESH"]
    armatures = [obj for obj in selected if obj.type == "ARMATURE"]
    if not meshes:
        raise RuntimeError("Export annulé : sélectionne au moins un maillage du personnage.")
    if not armatures:
        raise RuntimeError("Export annulé : sélectionne aussi l'armature humanoïde.")
    if not any(mod.type == "ARMATURE" for mesh in meshes for mod in mesh.modifiers):
        print("AVERTISSEMENT : aucun modificateur Armature détecté sur les maillages sélectionnés.")
    actions = [action.name for action in bpy.data.actions if action.users > 0]
    if not actions:
        print("AVERTISSEMENT : aucune action d'animation Blender active/utilisée détectée.")
    output.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=str(output),
        export_format="GLB",
        use_selection=True,
        export_apply=False,
        export_texcoords=True,
        export_normals=True,
        export_tangents=True,
        export_materials="EXPORT",
        export_image_format="AUTO",
        export_skins=True,
        export_animations=True,
        export_frame_range=True,
        export_force_sampling=True,
        export_yup=True,
    )
    if not output.is_file() or output.stat().st_size < 1024:
        raise RuntimeError(f"Export GLB absent ou trop petit : {output}")
    print(f"Export GLB créé : {output} ({output.stat().st_size} octets)")
    print("Étape suivante obligatoire : python tools/validate_character_glb.py OrvalleNative/characters")


if __name__ == "__main__":
    main()

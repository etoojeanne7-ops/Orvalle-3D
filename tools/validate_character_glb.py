#!/usr/bin/env python3
"""Structural quality gate for Orvalle humanoid GLB assets.

This checks basic glTF 2.0 structure and expected components. It does NOT certify
photorealism, likeness, rig quality, lip-sync, animation quality or visual correctness.
"""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path
from typing import Any

MAGIC = 0x46546C67
VERSION = 2
JSON_CHUNK = 0x4E4F534A
BIN_CHUNK = 0x004E4942
REQUIRED = ("Lena.glb", "Marec.glb")


def _list(doc: dict[str, Any], key: str) -> list[Any]:
    value = doc.get(key, [])
    return value if isinstance(value, list) else []


def inspect_glb(path: Path) -> list[str]:
    errors: list[str] = []
    try:
        data = path.read_bytes()
    except OSError as exc:
        return [f"{path}: lecture impossible ({exc})"]

    if len(data) < 20:
        return [f"{path}: fichier trop court pour être un GLB valide"]

    magic, version, declared_length = struct.unpack_from("<III", data, 0)
    if magic != MAGIC:
        return [f"{path}: signature GLB invalide"]
    if version != VERSION:
        errors.append(f"{path}: version GLB {version}; version 2 requise")
    if declared_length != len(data):
        errors.append(f"{path}: longueur déclarée {declared_length}, réelle {len(data)}")

    offset = 12
    json_doc: dict[str, Any] | None = None
    chunk_types: list[int] = []
    while offset + 8 <= min(len(data), declared_length):
        chunk_length, chunk_type = struct.unpack_from("<II", data, offset)
        offset += 8
        end = offset + chunk_length
        if end > len(data):
            errors.append(f"{path}: chunk tronqué")
            break
        chunk = data[offset:end]
        chunk_types.append(chunk_type)
        if len(chunk_types) == 1:
            if chunk_type != JSON_CHUNK:
                errors.append(f"{path}: le premier chunk n'est pas JSON")
            else:
                try:
                    parsed = json.loads(chunk.decode("utf-8").rstrip(" \t\r\n\x00"))
                    if isinstance(parsed, dict):
                        json_doc = parsed
                    else:
                        errors.append(f"{path}: la racine JSON doit être un objet")
                except (UnicodeDecodeError, json.JSONDecodeError) as exc:
                    errors.append(f"{path}: JSON glTF invalide ({exc})")
        offset = end

    if offset != declared_length:
        errors.append(f"{path}: structure de chunks incohérente")
    if JSON_CHUNK not in chunk_types:
        errors.append(f"{path}: chunk JSON absent")
    if json_doc is None:
        return errors or [f"{path}: document glTF absent"]

    meshes = _list(json_doc, "meshes")
    materials = _list(json_doc, "materials")
    textures = _list(json_doc, "textures")
    images = _list(json_doc, "images")
    skins = _list(json_doc, "skins")
    animations = _list(json_doc, "animations")
    nodes = _list(json_doc, "nodes")
    scenes = _list(json_doc, "scenes")
    buffers = _list(json_doc, "buffers")

    has_mesh_primitives = any(
        isinstance(mesh, dict) and isinstance(mesh.get("primitives"), list) and mesh["primitives"]
        for mesh in meshes
    )
    has_skinned_node = any(
        isinstance(node, dict) and isinstance(node.get("skin"), int)
        for node in nodes
    )
    has_skin_joints = any(
        isinstance(skin, dict) and isinstance(skin.get("joints"), list) and len(skin["joints"]) >= 3
        for skin in skins
    )
    has_animation_channels = any(
        isinstance(animation, dict)
        and isinstance(animation.get("channels"), list) and animation["channels"]
        and isinstance(animation.get("samplers"), list) and animation["samplers"]
        for animation in animations
    )
    has_material_textures = any(
        isinstance(material, dict)
        and isinstance(material.get("pbrMetallicRoughness"), dict)
        and isinstance(material["pbrMetallicRoughness"].get("baseColorTexture"), dict)
        for material in materials
    )
    has_texture_source = any(
        isinstance(texture, dict) and isinstance(texture.get("source"), int)
        and 0 <= texture["source"] < len(images)
        for texture in textures
    )
    has_embedded_binary = BIN_CHUNK in chunk_types
    has_scene_nodes = any(
        isinstance(scene, dict) and isinstance(scene.get("nodes"), list) and scene["nodes"]
        for scene in scenes
    )

    print(
        f"{path}: meshes={len(meshes)}, materials={len(materials)}, "
        f"textures={len(textures)}, images={len(images)}, skins={len(skins)}, "
        f"animations={len(animations)}, buffers={len(buffers)}, bin_chunk={has_embedded_binary}"
    )

    if not has_mesh_primitives:
        errors.append(f"{path}: aucun maillage avec primitives")
    if not materials:
        errors.append(f"{path}: aucun matériau exporté")
    if not images or not textures or not has_texture_source:
        errors.append(f"{path}: texture glTF sans image source valide; vérifier les textures PBR")
    if not has_material_textures:
        errors.append(f"{path}: aucun matériau PBR ne référence de texture couleur")
    if not skins or not has_skinned_node or not has_skin_joints:
        errors.append(f"{path}: armature/skinning humanoïde incomplet (nœud skinné et au moins 3 joints requis)")
    if not has_animation_channels:
        errors.append(f"{path}: aucune animation avec canaux et échantillonneurs")
    if not scenes or not has_scene_nodes:
        errors.append(f"{path}: aucune scène contenant des nœuds")
    if not buffers or not has_embedded_binary:
        errors.append(f"{path}: buffer binaire GLB absent")
    return errors


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("OrvalleNative/characters")
    failures: list[str] = []
    for name in REQUIRED:
        path = root / name
        if not path.is_file():
            failures.append(f"{path}: MODÈLE MANQUANT — le placeholder ne doit pas être présenté comme photoréaliste")
        else:
            failures.extend(inspect_glb(path))
    if failures:
        print("\nÉCHEC DU CONTRÔLE STRUCTUREL :")
        for failure in failures:
            print(f" - {failure}")
        print("\nCe contrôle technique ne remplace pas une revue visuelle humaine.")
        return 1
    print("\nPASS structurel uniquement. Le photoréalisme et la qualité artistique restent à valider visuellement.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

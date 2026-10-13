#!/usr/bin/env python3
"""Strict, dependency-free structural gate for Orvalle humanoid GLB assets.

This verifies file structure and required glTF features; it does NOT certify
photorealism, likeness, animation quality, or visual correctness.
"""
from __future__ import annotations
import json
import struct
import sys
from pathlib import Path

MAGIC = 0x46546C67
VERSION = 2
REQUIRED = ("Lena.glb", "Marec.glb")


def inspect_glb(path: Path) -> list[str]:
    errors: list[str] = []
    data = path.read_bytes()
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
    json_doc = None
    first_chunk = True
    while offset + 8 <= min(len(data), declared_length):
        chunk_length, chunk_type = struct.unpack_from("<II", data, offset)
        offset += 8
        end = offset + chunk_length
        if end > len(data):
            errors.append(f"{path}: chunk tronqué")
            break
        chunk = data[offset:end]
        if first_chunk:
            if chunk_type != 0x4E4F534A:
                errors.append(f"{path}: le premier chunk n'est pas JSON")
            else:
                try:
                    json_doc = json.loads(chunk.decode("utf-8").rstrip(" \\t\\r\\n\\x00"))
                except (UnicodeDecodeError, json.JSONDecodeError) as exc:
                    errors.append(f"{path}: JSON glTF invalide ({exc})")
            first_chunk = False
        offset = end
    if offset != declared_length:
        errors.append(f"{path}: structure de chunks incohérente")
    if not isinstance(json_doc, dict):
        return errors or [f"{path}: document glTF absent"]

    def count(key: str) -> int:
        value = json_doc.get(key, [])
        return len(value) if isinstance(value, list) else 0

    meshes, materials = count("meshes"), count("materials")
    textures, images = count("textures"), count("images")
    skins, animations = count("skins"), count("animations")
    nodes = json_doc.get("nodes", [])
    has_skinned_node = isinstance(nodes, list) and any(
        isinstance(node, dict) and isinstance(node.get("skin"), int)
        for node in nodes
    )
    print(f"{path}: meshes={meshes}, materials={materials}, textures={textures}, "
          f"images={images}, skins={skins}, animations={animations}")
    if meshes < 1:
        errors.append(f"{path}: aucun maillage")
    if materials < 1:
        errors.append(f"{path}: aucun matériau exporté")
    if textures < 1 or images < 1:
        errors.append(f"{path}: aucune texture embarquée/référencée; contrôler les textures PBR")
    if skins < 1 or not has_skinned_node:
        errors.append(f"{path}: aucun nœud skinné/armature glTF détecté")
    if animations < 1:
        errors.append(f"{path}: aucune animation exportée")
    if not json_doc.get("scenes"):
        errors.append(f"{path}: aucune scène glTF")
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
        print("\\nÉCHEC DU CONTRÔLE STRUCTUREL :")
        for failure in failures:
            print(f" - {failure}")
        print("\\nCe contrôle technique ne remplace pas une revue visuelle humaine.")
        return 1
    print("\\nPASS structurel uniquement. La fidélité visuelle, le rig, les expressions, le jeu d'acteur et les performances restent à contrôler.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

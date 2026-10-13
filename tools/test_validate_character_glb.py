#!/usr/bin/env python3
"""Unit tests for the Orvalle GLB validator; uses only the Python standard library."""
import json
import struct
import tempfile
import unittest
from pathlib import Path

from validate_character_glb import inspect_glb

MAGIC = 0x46546C67
JSON_CHUNK = 0x4E4F534A
BIN_CHUNK = 0x004E4942


def make_glb(document: dict) -> bytes:
    raw_json = json.dumps(document, separators=(",", ":")).encode("utf-8")
    raw_json += b" " * ((4 - len(raw_json) % 4) % 4)
    binary = b"\x00\x00\x00\x00"
    chunks = struct.pack("<II", len(raw_json), JSON_CHUNK) + raw_json
    chunks += struct.pack("<II", len(binary), BIN_CHUNK) + binary
    return struct.pack("<III", MAGIC, 2, 12 + len(chunks)) + chunks


def valid_document() -> dict:
    return {
        "asset": {"version": "2.0"},
        "scene": 0,
        "scenes": [{"nodes": [0, 1]}],
        "nodes": [{"mesh": 0, "skin": 0}, {"name": "joint-root"}, {"name": "joint-spine"}, {"name": "joint-head"}],
        "meshes": [{"primitives": [{"attributes": {"POSITION": 0}, "material": 0}]}],
        "materials": [{"pbrMetallicRoughness": {"baseColorTexture": {"index": 0}}}],
        "textures": [{"source": 0}],
        "images": [{"bufferView": 0, "mimeType": "image/png"}],
        "skins": [{"joints": [1, 2, 3]}],
        "animations": [{"samplers": [{"input": 1, "output": 2}], "channels": [{"sampler": 0, "target": {"node": 0, "path": "rotation"}}]}],
        "buffers": [{"byteLength": 4}],
        "bufferViews": [{"buffer": 0, "byteLength": 4}],
        "accessors": [{"componentType": 5126, "count": 1, "type": "VEC3"}],
    }


class CharacterGlbValidatorTests(unittest.TestCase):
    def test_valid_minimum_structure_passes(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "fixture.glb"
            path.write_bytes(make_glb(valid_document()))
            self.assertEqual(inspect_glb(path), [])

    def test_missing_skin_and_animation_are_reported(self):
        doc = valid_document()
        doc["skins"] = []
        doc["animations"] = []
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "incomplete.glb"
            path.write_bytes(make_glb(doc))
            errors = inspect_glb(path)
            self.assertTrue(any("skinning" in item for item in errors))
            self.assertTrue(any("animation" in item for item in errors))

    def test_bad_signature_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "bad.glb"
            path.write_bytes(b"not-a-glb-file-long-enough")
            self.assertTrue(any("signature" in item for item in inspect_glb(path)))

    def test_truncated_chunk_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "truncated.glb"
            path.write_bytes(struct.pack("<III", MAGIC, 2, 40) + struct.pack("<II", 100, JSON_CHUNK))
            self.assertTrue(any("tronqué" in item for item in inspect_glb(path)))


if __name__ == "__main__":
    unittest.main(verbosity=2)

#!/usr/bin/env python3
"""
Migrate MoveEntry `children` → `variants` in all character YAML files.
For each child displayName, strip the parent's displayName from the beginning
or end (if present) to produce a short variant label.
"""

import sys
from pathlib import Path
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap, CommentedSeq

YAML_DIR = Path(__file__).parent.parent / "RedBlocking" / "Resources" / "CharacterData"


def simplify(child_name: str, parent_name: str) -> str:
    """Strip the parent name as a prefix or suffix from the child name."""
    if child_name == parent_name:
        return child_name
    if child_name.endswith(parent_name):
        result = child_name[: -len(parent_name)].strip()
        if result:
            return result
    if child_name.startswith(parent_name):
        result = child_name[len(parent_name) :].strip()
        if result:
            return result
    return child_name


def migrate_entries(entries: CommentedSeq) -> None:
    for entry in entries:
        if not isinstance(entry, CommentedMap):
            continue
        if "children" in entry:
            parent_name = entry.get("displayName", "")
            children = entry["children"]
            # Rename key: insert `variants` at the same position, remove `children`
            idx = list(entry.keys()).index("children")
            variants = CommentedSeq()
            for child in children:
                variant = CommentedMap()
                variant["id"] = child["id"]
                variant["displayName"] = simplify(child.get("displayName", ""), parent_name)
                variant["detail"] = child["detail"]
                variants.append(variant)
            # Insert `variants` at the same position as `children`
            keys = list(entry.keys())
            new_entry = CommentedMap()
            for i, key in enumerate(keys):
                if key == "children":
                    new_entry["variants"] = variants
                else:
                    new_entry[key] = entry[key]
            entry.clear()
            entry.update(new_entry)


def process_file(path: Path) -> None:
    yaml = YAML()
    yaml.preserve_quotes = True
    yaml.width = 4096  # prevent line wrapping

    with path.open("r", encoding="utf-8") as f:
        data = yaml.load(f)

    if not isinstance(data, CommentedMap):
        return

    move_groups = data.get("moveGroups", [])
    for group in move_groups:
        if group.get("id") not in ("air_normals", "ground_normals"):
            continue
        entries = group.get("entries", [])
        if entries:
            migrate_entries(entries)

    with path.open("w", encoding="utf-8") as f:
        yaml.dump(data, f)

    print(f"Migrated: {path.name}")


def main():
    yml_files = sorted(YAML_DIR.glob("*.yml"))
    # Skip Characters.yml — it's just a list of character IDs
    yml_files = [f for f in yml_files if f.name != "Characters.yml"]
    for path in yml_files:
        process_file(path)


if __name__ == "__main__":
    main()

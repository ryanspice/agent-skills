#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

FRONTMATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*", re.DOTALL)


def now_iso() -> str:
    return datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")


def relpath(root: Path, path: Path) -> str:
    return path.relative_to(root).as_posix()


def parse_scalar(value: str) -> Any:
    value = value.strip()
    if not value:
        return ""
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [item.strip().strip("'\"") for item in inner.split(",")]
    return value.strip("'\"")


def read_frontmatter(skill_path: Path) -> dict[str, Any]:
    try:
        text = skill_path.read_text(encoding="utf-8-sig")
    except UnicodeDecodeError:
        text = skill_path.read_text(encoding="utf-8", errors="replace")

    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}

    data: dict[str, Any] = {}
    for raw_line in match.group(1).splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = parse_scalar(value)
    return data


def descriptor_path_for(skill_path: Path) -> Path | None:
    candidate = skill_path.parent / "mcp-skill.json"
    return candidate if candidate.exists() else None


def canonical_entry(ai_wiki_root: Path, skill_path: Path) -> dict[str, Any]:
    rel = relpath(ai_wiki_root, skill_path)
    parts = rel.split("/")
    fm = read_frontmatter(skill_path)

    scope = "universal"
    project = None

    if len(parts) >= 4 and parts[0] == "04_skills" and parts[1] == "projects":
        scope = "project"
        project = parts[2]

    descriptor = descriptor_path_for(skill_path)
    slug = fm.get("name") or skill_path.parent.name

    return {
        "slug": str(slug),
        "name": str(fm.get("name") or slug),
        "version": str(fm.get("version") or ""),
        "type": str(fm.get("type") or ("project-agent-skill" if scope == "project" else "universal-agent-skill")),
        "status": str(fm.get("status") or "active"),
        "scope": scope,
        "project": project,
        "path": rel,
        "descriptor": relpath(ai_wiki_root, descriptor) if descriptor else None,
        "description": str(fm.get("description") or ""),
        "platforms": fm.get("platforms") or [],
        "tags": fm.get("tags") or [],
    }


def mirror_entry(ai_wiki_root: Path, skill_path: Path) -> dict[str, Any]:
    rel = relpath(ai_wiki_root, skill_path)
    parts = rel.split("/")
    fm = read_frontmatter(skill_path)

    warnings: list[str] = []
    project = None

    if (
        len(parts) >= 6
        and parts[0] == "07_Projects"
        and parts[2] == ".ai"
        and parts[3] == "skills"
        and parts[-1] == "SKILL.md"
    ):
        project = parts[1]
    else:
        warnings.append("Unexpected mirror path shape.")

    if fm.get("type") != "pointer":
        warnings.append("Mirror SKILL.md should use type: pointer.")
    if fm.get("status") != "mirror":
        warnings.append("Mirror SKILL.md should use status: mirror.")
    if not fm.get("canonical_path"):
        warnings.append("Mirror SKILL.md should include canonical_path.")

    return {
        "slug": str(fm.get("name") or skill_path.parent.name),
        "project": project,
        "path": rel,
        "canonical_path": str(fm.get("canonical_path") or ""),
        "type": str(fm.get("type") or ""),
        "status": str(fm.get("status") or ""),
        "is_valid_pointer": len(warnings) == 0,
        "warnings": warnings,
    }


def collect_canonical_skills(ai_wiki_root: Path) -> list[dict[str, Any]]:
    roots = [
        ai_wiki_root / "04_skills" / "universal",
        ai_wiki_root / "04_skills" / "projects",
    ]

    skills: list[dict[str, Any]] = []
    seen_paths: set[str] = set()

    for root in roots:
        if not root.exists():
            continue
        for skill_path in sorted(root.rglob("SKILL.md")):
            rel = relpath(ai_wiki_root, skill_path)
            if rel in seen_paths:
                continue
            seen_paths.add(rel)
            skills.append(canonical_entry(ai_wiki_root, skill_path))

    return skills


def collect_mirrors(ai_wiki_root: Path) -> list[dict[str, Any]]:
    mirror_root = ai_wiki_root / "07_Projects"
    mirrors: list[dict[str, Any]] = []

    if not mirror_root.exists():
        return mirrors

    for skill_path in sorted(mirror_root.glob("*/.ai/skills/*/SKILL.md")):
        mirrors.append(mirror_entry(ai_wiki_root, skill_path))

    return mirrors


def build_registry(ai_wiki_root: Path) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "generated_at": now_iso(),
        "ai_wiki_root": ai_wiki_root.as_posix(),
        "skill_roots": [
            "04_skills/universal",
            "04_skills/projects",
        ],
        "skills": collect_canonical_skills(ai_wiki_root),
    }


def build_mirror_map(ai_wiki_root: Path) -> dict[str, Any]:
    return {
        "schema_version": "1.0.0",
        "generated_at": now_iso(),
        "ai_wiki_root": ai_wiki_root.as_posix(),
        "mirror_roots": [
            "07_Projects/<slug>/.ai/skills",
        ],
        "mirrors": collect_mirrors(ai_wiki_root),
    }


def backup_existing(path: Path) -> None:
    if not path.exists():
        return
    backup = path.with_name(f"{path.name}.bak-{datetime.now().strftime('%Y%m%d-%H%M%S')}")
    shutil.copy2(path, backup)
    print(f"Backup: {backup}")


def write_json(path: Path, payload: dict[str, Any], backup: bool) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if backup:
        backup_existing(path)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Rebuild AI Wiki skill registry and mirror map.")
    parser.add_argument("--ai-wiki-root", required=True)
    parser.add_argument("--dry-run", action="store_true", help="Preview only; default when --apply is omitted.")
    parser.add_argument("--apply", action="store_true", help="Write registry and mirror map.")
    parser.add_argument("--backup", action="store_true", help="Back up existing outputs before overwrite.")
    parser.add_argument("--out", help="Override skills-registry.json output path.")
    parser.add_argument("--mirrors-out", help="Override skill-mirrors.json output path.")
    args = parser.parse_args()

    if args.apply and args.dry_run:
        parser.error("Use either --apply or --dry-run, not both.")

    ai_wiki_root = Path(args.ai_wiki_root).expanduser().resolve()
    if not ai_wiki_root.exists():
        raise SystemExit(f"AI Wiki root not found: {ai_wiki_root}")

    registry = build_registry(ai_wiki_root)
    mirror_map = build_mirror_map(ai_wiki_root)

    out_path = Path(args.out).expanduser().resolve() if args.out else ai_wiki_root / "03_Indexes" / "skills" / "skills-registry.json"
    mirrors_out_path = Path(args.mirrors_out).expanduser().resolve() if args.mirrors_out else ai_wiki_root / "03_Indexes" / "skills" / "skill-mirrors.json"

    print("AI Wiki skill registry rebuild")
    print(f"Root:      {ai_wiki_root}")
    print(f"Registry:  {out_path}")
    print(f"Mirrors:   {mirrors_out_path}")
    print(f"Skills:    {len(registry['skills'])}")
    print(f"Mirrors:   {len(mirror_map['mirrors'])}")

    invalid_mirrors = [m for m in mirror_map["mirrors"] if not m.get("is_valid_pointer")]
    if invalid_mirrors:
        print(f"WARN: Invalid mirror pointers: {len(invalid_mirrors)}")
        for item in invalid_mirrors[:10]:
            print(f"  - {item['path']}: {'; '.join(item['warnings'])}")

    if not args.apply:
        print("[DRY RUN] No files written. Pass --apply to write outputs.")
        return 0

    write_json(out_path, registry, backup=args.backup)
    write_json(mirrors_out_path, mirror_map, backup=args.backup)

    print(f"Wrote registry: {out_path}")
    print(f"Wrote mirror map: {mirrors_out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

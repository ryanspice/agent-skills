#!/usr/bin/env python3
"""
Dependency-free agent skill validator.

Usage:
  python validate_skill.py path/to/skill-folder
  python validate_skill.py path/to/SKILL.md
  python validate_skill.py <AI_WIKI_ROOT> --scan
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Dict, Iterable, List, Tuple

NAME_RE = re.compile(r"^[a-z0-9-]{1,64}$")
XML_RE = re.compile(r"</?[a-zA-Z][^>]*>")
RESERVED_NAME_WORDS = {"anthropic", "claude"}
TRIGGER_RE = re.compile(r"\b(use when|when the user|when working|for .+ when|use for)\b", re.I)

DEFAULT_SCAN_ROOTS = [
    "04_skills/universal",
    "skills/projects",
    "projects",
]

def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")

def read_skill_md(path: Path) -> Tuple[Path, str]:
    if path.is_dir():
        path = path / "SKILL.md"
    if not path.exists():
        raise FileNotFoundError(f"Missing SKILL.md: {path}")
    return path, read_text(path)

def parse_scalar(value: str) -> Any:
    value = value.strip()
    if not value:
        return ""
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        return [part.strip().strip('"').strip("'") for part in inner.split(",")]
    if value.lower() == "true":
        return True
    if value.lower() == "false":
        return False
    return value.strip('"').strip("'")

def parse_frontmatter(text: str) -> Tuple[Dict[str, Any], str]:
    if not text.startswith("---\n"):
        raise ValueError("SKILL.md must start with YAML frontmatter opening '---'")

    end = text.find("\n---", 4)
    if end == -1:
        raise ValueError("SKILL.md is missing closing frontmatter '---'")

    raw = text[4:end].strip()
    body = text[end + len("\n---"):].lstrip("\n")
    data: Dict[str, Any] = {}

    for line in raw.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            stripped = line.strip()
            if stripped.startswith("- ") or line.startswith(" "):
                continue
            raise ValueError(f"Unsupported frontmatter line, expected key: value: {line!r}")
        key, value = line.split(":", 1)
        data[key.strip()] = parse_scalar(value)

    return data, body

def rel(path: Path, root: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except Exception:
        return path.as_posix()

def discover_skill_files(root: Path) -> List[Path]:
    if (root / "SKILL.md").exists():
        return [root / "SKILL.md"]
    if root.name.lower() == "skill.md":
        return [root]

    candidates: List[Path] = []
    for scan_rel in DEFAULT_SCAN_ROOTS:
        scan_root = root / scan_rel
        if scan_root.exists():
            candidates.extend(scan_root.rglob("SKILL.md"))

    if not candidates:
        candidates.extend(root.rglob("SKILL.md"))

    # Exclude templates from registry-like scans but still allow explicit validation.
    return sorted(
        [p for p in candidates if "/templates/" not in p.as_posix().lower().replace("\\", "/")],
        key=lambda p: p.as_posix().lower(),
    )

def validate_one(path: Path, ai_wiki_root: Path | None = None) -> Dict[str, Any]:
    skill_path, text = read_skill_md(path)
    root = skill_path.parent
    errors: List[str] = []
    warnings: List[str] = []

    try:
        fm, body = parse_frontmatter(text)
    except Exception as exc:
        return {
            "ok": False,
            "path": str(skill_path),
            "errors": [str(exc)],
            "warnings": warnings,
        }

    name = str(fm.get("name", ""))
    description = str(fm.get("description", ""))
    version = str(fm.get("version", ""))

    if not name:
        errors.append("Missing required frontmatter field: name")
    elif not NAME_RE.match(name):
        errors.append("Skill name must be 1-64 chars using only lowercase letters, numbers, and hyphens")

    if any(word in name.split("-") for word in RESERVED_NAME_WORDS):
        warnings.append("Skill name contains a vendor/model word; confirm this is intentional")

    if XML_RE.search(name):
        errors.append("Skill name must not contain XML tags")

    if not description:
        errors.append("Missing required frontmatter field: description")
    elif len(description) > 1024:
        errors.append("Description must be 1024 characters or fewer")

    if XML_RE.search(description):
        errors.append("Description must not contain XML tags")

    if description and not TRIGGER_RE.search(description):
        warnings.append("Description should include trigger/context language such as 'Use when...'")

    if description and re.search(r"\b(I can|you can use this|this helps)\b", description, re.I):
        warnings.append("Description should be third-person and routing-oriented, not conversational")

    if re.search(r"allowed-tools:\s*Bash\(\*\)", text):
        warnings.append("Broad allowed-tools Bash(*) detected. Review before trusting this skill.")

    if re.search(r"\\scripts\\|\\reference\\|\\templates\\", text):
        warnings.append("Windows-style paths detected. Prefer forward-slash paths inside skill docs.")

    if "â" in text:
        warnings.append("Possible mojibake/encoding artifact detected, such as box-drawing characters corrupted to â sequences.")

    lines = text.splitlines()
    if len(lines) > 500:
        warnings.append(f"SKILL.md has {len(lines)} lines. Consider moving detail into reference/ files.")

    if len(body.strip()) < 120:
        warnings.append("SKILL.md body is very short; confirm it contains enough procedural guidance.")

    ref_dir = root / "reference"
    scripts_dir = root / "scripts"
    templates_dir = root / "templates"
    examples_dir = root / "examples"

    if ref_dir.exists() and "reference/" not in text:
        warnings.append("reference/ exists but SKILL.md does not mention reference/ files.")

    if scripts_dir.exists() and "scripts/" not in text:
        warnings.append("scripts/ exists but SKILL.md does not mention scripts/ files.")

    if templates_dir.exists() and "templates/" not in text:
        warnings.append("templates/ exists but SKILL.md does not mention templates/ files.")

    if examples_dir.exists() and "examples/" not in text and "eval" not in text.lower():
        warnings.append("examples/ exists but SKILL.md does not mention examples/evals.")

    descriptor = root / "mcp-skill.json"
    descriptor_data: Dict[str, Any] | None = None
    if descriptor.exists():
        try:
            descriptor_data = json.loads(read_text(descriptor))
            if descriptor_data.get("slug") and descriptor_data.get("slug") != name:
                warnings.append("mcp-skill.json slug differs from SKILL.md name.")
            if version and descriptor_data.get("version") and descriptor_data.get("version") != version:
                warnings.append("mcp-skill.json version differs from SKILL.md version.")
            policy = str(descriptor_data.get("write_policy", ""))
            if "06_Inbound" in policy or "06_inbound" in policy:
                warnings.append("mcp-skill.json write_policy references 06_Inbound; expected 07_inbound/proposed for this AI Wiki.")
        except Exception as exc:
            warnings.append(f"Could not parse mcp-skill.json: {exc}")

    return {
        "ok": not errors,
        "path": str(skill_path),
        "relative_path": rel(skill_path, ai_wiki_root) if ai_wiki_root else skill_path.as_posix(),
        "frontmatter": fm,
        "descriptor": descriptor_data,
        "errors": errors,
        "warnings": warnings,
        "stats": {
            "lines": len(lines),
            "description_chars": len(description),
            "has_reference_dir": ref_dir.exists(),
            "has_scripts_dir": scripts_dir.exists(),
            "has_templates_dir": templates_dir.exists(),
            "has_examples_dir": examples_dir.exists(),
            "has_mcp_descriptor": descriptor.exists(),
        },
    }

def validate_registry(ai_wiki_root: Path) -> Dict[str, Any]:
    path = ai_wiki_root / "03_indexes/skills/skills-registry.json"
    errors: List[str] = []
    warnings: List[str] = []

    if not path.exists():
        return {"ok": False, "path": str(path), "errors": ["Missing skills registry"], "warnings": warnings}

    try:
        data = json.loads(read_text(path))
    except Exception as exc:
        return {"ok": False, "path": str(path), "errors": [f"Invalid JSON: {exc}"], "warnings": warnings}

    if isinstance(data, list):
        warnings.append("Registry is a raw array. Prefer object with schema metadata and skills array.")
        skills = data
    elif isinstance(data, dict) and "skills" in data:
        skills = data.get("skills", [])
    elif isinstance(data, dict) and "slug" in data:
        errors.append("Registry contains a single skill object. Rebuild it into a metadata object with a skills array.")
        skills = [data]
    else:
        errors.append("Registry shape is not recognized.")
        skills = []

    if not isinstance(skills, list):
        errors.append("Registry 'skills' must be an array.")
        skills = []

    seen: set[str] = set()
    for item in skills:
        if not isinstance(item, dict):
            warnings.append("Registry contains a non-object skill entry.")
            continue
        slug = item.get("slug")
        if not slug:
            warnings.append("Registry skill entry missing slug.")
            continue
        if slug in seen:
            warnings.append(f"Duplicate registry slug: {slug}")
        seen.add(slug)
        rel_path = item.get("path")
        if rel_path and not (ai_wiki_root / str(rel_path).replace("/", "\\")).exists():
            warnings.append(f"Registry path missing on disk: {rel_path}")

    return {"ok": not errors, "path": str(path), "errors": errors, "warnings": warnings, "skill_count": len(skills)}

def print_result(result: Dict[str, Any]) -> None:
    status = "PASS" if result["ok"] else "FAIL"
    print(f"{status}: {result['path']}")

    if result.get("errors"):
        print("\nErrors:")
        for item in result["errors"]:
            print(f"  - {item}")

    if result.get("warnings"):
        print("\nWarnings:")
        for item in result["warnings"]:
            print(f"  - {item}")

    if result.get("stats"):
        print("\nStats:")
        for key, value in result["stats"].items():
            print(f"  {key}: {value}")

def main() -> int:
    parser = argparse.ArgumentParser(description="Validate agent skill folders, SKILL.md files, or an AI Wiki skill shelf")
    parser.add_argument("path", help="Path to skill folder, SKILL.md, or AI Wiki root")
    parser.add_argument("--scan", action="store_true", help="Scan for SKILL.md files under known AI Wiki skill roots")
    parser.add_argument("--registry", action="store_true", help="Also validate 03_indexes/skills/skills-registry.json")
    parser.add_argument("--json", action="store_true", help="Print JSON output")
    args = parser.parse_args()

    root = Path(args.path)

    if args.scan:
        skill_files = discover_skill_files(root)
        results = [validate_one(path, ai_wiki_root=root) for path in skill_files]
        registry_result = validate_registry(root) if args.registry else None
        ok = all(item["ok"] for item in results) and (registry_result["ok"] if registry_result else True)
        output = {"ok": ok, "root": str(root), "count": len(results), "results": results, "registry": registry_result}

        if args.json:
            print(json.dumps(output, indent=2))
        else:
            print(f"Skill scan: {len(results)} skills")
            for item in results:
                print_result(item)
                print("")
            if registry_result:
                print_result(registry_result)

        return 0 if ok else 1

    result = validate_one(root)
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print_result(result)

    return 0 if result["ok"] else 1

if __name__ == "__main__":
    raise SystemExit(main())

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

REQUIRED = [
    "SKILL.md",
    "README.md",
    "CHANGELOG.md",
    ".thoughts",
    "mcp-skill.json",
    "reference/research-summary.md",
    "reference/architecture-patterns.md",
    "reference/safety-and-trust-boundaries.md",
    "reference/windows-script-patterns.md",
    "reference/install-surfaces.md",
]

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.S)


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    raise SystemExit(1)


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    if not root.exists():
        fail(f"path not found: {root}")

    for rel in REQUIRED:
        if not (root / rel).exists():
            fail(f"missing required file: {rel}")

    skill = (root / "SKILL.md").read_text(encoding="utf-8")
    match = FRONTMATTER_RE.match(skill)
    if not match:
        fail("SKILL.md missing YAML-style frontmatter block")

    fm = match.group(1)
    for key in ["name:", "description:", "version:"]:
        if key not in fm:
            fail(f"SKILL.md frontmatter missing {key}")

    name_line = next((line for line in fm.splitlines() if line.startswith("name:")), "")
    name = name_line.split(":", 1)[1].strip()
    if not re.fullmatch(r"[a-z0-9-]{1,64}", name):
        fail(f"invalid skill name: {name}")

    metadata = json.loads((root / "mcp-skill.json").read_text(encoding="utf-8"))
    if metadata.get("slug") != name:
        fail("mcp-skill.json slug does not match SKILL.md name")

    evals = list((root / "examples" / "evals").glob("*.json"))
    if len(evals) < 3:
        fail("expected at least 3 eval json files")

    for eval_file in evals:
        json.loads(eval_file.read_text(encoding="utf-8"))

    print("OK: skill package validation passed")
    print(f"Root: {root}")
    print(f"Skill: {name}")
    print(f"Evals: {len(evals)}")


if __name__ == "__main__":
    main()

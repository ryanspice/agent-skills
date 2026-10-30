#!/usr/bin/env python3
"""Validate this WAYFINDER package without third-party dependencies or model calls.

This deliberately supports only the simple quoted-scalar frontmatter authored in
this package. It is not a general YAML parser or the official skills-ref validator.
Reads the package; never edits it, connects to providers, or executes project code.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

REQUIRED = (
    'SKILL.md', 'README.md', 'NOTICE.md', 'LICENSE.txt', 'VERIFICATION.md',
    'agents/openai.yaml', 'references/ryan-profile.md',
    'references/decision-protocol.md', 'references/verification.md',
    'references/harness-integration.md', 'assets/MAP.template.md',
    'assets/DECISION.template.md', 'assets/HANDOFF.template.md',
    'assets/WORKER.template.md', 'assets/claude-wrapper.template.md',
    'scripts/Get-WayfinderContext.ps1', 'scripts/verify_package.py',
    'tests/test_verify_package.py', 'evals/scenarios.json', 'evals/README.md',
    'examples/EXAMPLES.md', '.thoughts/CONTINUATION.md', 'CHANGELOG.md',
)
# Existing owned repository provenance extensions; other unknown fields still fail.
TOP_FIELDS = {'name', 'description', 'license', 'compatibility', 'metadata',
              'version', 'status', 'provenance_origin', 'provenance_source_path',
              'provenance_credit', 'provenance_ingested_as', 'provenance_upstream',
              'provenance_note'}
SKILL_NAME = re.compile(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')
LINK = re.compile(r'(?<!!)\[[^\]\n]+\]\(([^)\n]+)\)')


def scalar(raw: str) -> str:
    """Parse the package's restricted scalar format; reject booleans/nesting."""
    raw = raw.strip()
    if raw.startswith('"'):
        value = json.loads(raw)
        if not isinstance(value, str):
            raise ValueError('Expected a string scalar')
        return value
    if not raw or raw.lower() in {'true', 'false', 'null', '~'}:
        raise ValueError('Expected a nonempty string; quote metadata strings')
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_. /-]*', raw):
        raise ValueError('Unsupported scalar syntax; use a JSON-style quoted string')
    return raw


def parse_frontmatter(text: str) -> dict[str, object]:
    lines = text.splitlines()
    if not lines or lines[0] != '---':
        raise ValueError('SKILL.md must start with a frontmatter delimiter')
    try:
        end = lines.index('---', 1)
    except ValueError as exc:
        raise ValueError('Missing closing frontmatter delimiter') from exc
    result: dict[str, object] = {}
    metadata: dict[str, str] | None = None
    for line in lines[1:end]:
        if not line.strip():
            continue
        if line.startswith('  '):
            if metadata is None:
                raise ValueError('Nested field outside metadata')
            match = re.fullmatch(r'  ([A-Za-z0-9_/-]+):\s*(.*)', line)
            if not match:
                raise ValueError('Unsupported metadata syntax')
            key, raw = match.groups()
            if key in metadata:
                raise ValueError(f'Duplicate metadata key: {key}')
            metadata[key] = scalar(raw)
            continue
        match = re.fullmatch(r'([a-z][a-z_-]*):\s*(.*)', line)
        if not match:
            raise ValueError('Unsupported frontmatter syntax')
        key, raw = match.groups()
        if key not in TOP_FIELDS or key in result:
            raise ValueError(f'Unknown or duplicate frontmatter key: {key}')
        if key == 'metadata':
            if raw:
                raise ValueError('metadata must be a string-to-string block')
            metadata = {}
            result[key] = metadata
        else:
            metadata = None
            result[key] = scalar(raw)
    return result


def payload_files(root: Path) -> list[Path]:
    return sorted(p for p in root.rglob('*') if p.is_file()
                  and '__pycache__' not in p.parts and p.suffix != '.pyc')


def inside(root: Path, path: Path) -> bool:
    try:
        path.resolve().relative_to(root.resolve())
        return True
    except ValueError:
        return False


def markdown_links(text: str) -> list[str]:
    """Ignore illustrative code fences when checking local resource links."""
    output: list[str] = []
    fence: str | None = None
    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith(('```', '~~~')):
            marker = stripped[:3]
            fence = None if fence == marker else (marker if fence is None else fence)
            continue
        if fence is None:
            output.extend(LINK.findall(line))
    return output


def validate_hashes(root: Path) -> list[str]:
    issues: list[str] = []
    manifest = root / 'MANIFEST.sha256'
    if not manifest.is_file():
        return ['Missing MANIFEST.sha256']
    listed: set[str] = set()
    for number, line in enumerate(manifest.read_text(encoding='utf-8').splitlines(), 1):
        match = re.fullmatch(r'([0-9a-f]{64})  (.+)', line)
        if not match:
            issues.append(f'Malformed manifest line {number}')
            continue
        digest, relative = match.groups()
        path = root / relative
        # The manifest format uses portable relative POSIX paths only.
        if ('\\' in relative or ':' in relative or relative.startswith('/')
                or '..' in Path(relative).parts or not inside(root, path)
                or relative == 'MANIFEST.sha256'):
            issues.append(f'Unsafe manifest path at line {number}')
            continue
        if relative in listed:
            issues.append(f'Duplicate manifest entry: {relative}')
            continue
        listed.add(relative)
        if not path.is_file():
            issues.append(f'Manifest file missing: {relative}')
        elif hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            issues.append(f'Hash mismatch: {relative}')
    actual = {p.relative_to(root).as_posix() for p in payload_files(root)
              if p.name != 'MANIFEST.sha256'}
    for relative in sorted(actual - listed):
        issues.append(f'Unlisted payload file: {relative}')
    return issues


def validate(root: Path, *, check_hashes: bool = True) -> list[str]:
    root = root.resolve()
    issues: list[str] = []
    if not root.is_dir():
        return ['Package root is not a directory']
    for relative in REQUIRED:
        if not (root / relative).is_file():
            issues.append(f'Missing required file: {relative}')
    for path in root.rglob('*'):
        if path.is_symlink():
            issues.append(f'Package payload must not contain symlinks: {path.name}')
    skill = root / 'SKILL.md'
    if skill.is_file():
        try:
            text = skill.read_text(encoding='utf-8')
            data = parse_frontmatter(text)
            name = data.get('name', '')
            if not isinstance(name, str) or not SKILL_NAME.fullmatch(name) or len(name) > 64:
                issues.append('Invalid skill name')
            if name != root.name:
                issues.append('Skill name must match its parent directory')
            description = data.get('description', '')
            if not isinstance(description, str) or not 1 <= len(description) <= 1024:
                issues.append('Description must contain 1–1024 characters')
            compatibility = data.get('compatibility', '')
            if not isinstance(compatibility, str) or len(compatibility) > 500:
                issues.append('Compatibility must be a string of at most 500 characters')
            if len(text.splitlines()) >= 500:
                issues.append('Core skill must remain under 500 lines')
            metadata = data.get('metadata', {})
            if not isinstance(metadata, dict) or metadata.get('opencode/autoinvoke') != 'false':
                issues.append('OpenCode manual-invocation metadata is missing or incorrect')
            if not isinstance(metadata, dict) or metadata.get('opencode/slash') != 'true':
                issues.append('OpenCode slash metadata is missing or incorrect')
        except (ValueError, UnicodeError, TypeError) as exc:
            issues.append(f'Invalid package frontmatter: {exc}')
    native = root / 'agents/openai.yaml'
    if native.is_file() and not re.search(r'^  allow_implicit_invocation: false\s*$', native.read_text(encoding='utf-8'), re.M):
        issues.append('Codex explicit-invocation policy is missing or incorrect')
    wrapper = root / 'assets/claude-wrapper.template.md'
    if wrapper.is_file() and '\ndisable-model-invocation: true\n' not in wrapper.read_text(encoding='utf-8'):
        issues.append('Claude manual wrapper flag is missing or incorrect')
    for path in payload_files(root):
        if path.suffix != '.md':
            continue
        try:
            text = path.read_text(encoding='utf-8')
        except UnicodeError:
            issues.append(f'Non-UTF8 Markdown: {path.relative_to(root)}')
            continue
        if '\x00' in text:
            issues.append(f'NUL character in Markdown: {path.relative_to(root)}')
        for raw in markdown_links(text):
            if raw.startswith('<') or raw.startswith('#'):
                continue
            target = unquote(raw)
            if urlsplit(target).scheme:
                if urlsplit(target).scheme not in {'http', 'https', 'mailto'}:
                    issues.append(f'Nonportable link in {path.relative_to(root)}: {raw}')
                continue
            relative = target.split('#', 1)[0].split('?', 1)[0]
            target_path = path.parent / relative
            if not inside(root, target_path) or not target_path.exists():
                issues.append(f'Broken or escaping link in {path.relative_to(root)}: {raw}')
    evaluations = root / 'evals/scenarios.json'
    if evaluations.is_file():
        try:
            data = json.loads(evaluations.read_text(encoding='utf-8'))
            cases = data['cases']
            if not isinstance(cases, list) or len(cases) < 6:
                raise ValueError('Expected at least six behavioral cases')
            seen: set[str] = set()
            for case in cases:
                if not isinstance(case, dict):
                    raise ValueError('Cases must be objects')
                for field in ('id', 'prompt', 'fixture'):
                    if not isinstance(case.get(field), str) or not case[field].strip():
                        raise ValueError(f'Empty/invalid case field: {field}')
                if case['id'] in seen:
                    raise ValueError('Duplicate behavioral case ID')
                seen.add(case['id'])
                for field in ('checks', 'failure_on'):
                    values = case.get(field)
                    if not isinstance(values, list) or not values or not all(isinstance(x, str) and x.strip() for x in values):
                        raise ValueError(f'Invalid behavioral rubric: {field}')
        except (ValueError, KeyError, TypeError) as exc:
            issues.append(f'Invalid behavioral fixtures: {exc}')
    if check_hashes:
        try:
            issues.extend(validate_hashes(root))
        except (OSError, UnicodeError) as exc:
            issues.append(f'Unable to verify manifest: {type(exc).__name__}')
    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', nargs='?', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--skip-hashes', action='store_true', help='Development-only structural check')
    parser.add_argument('--json', action='store_true', help='Emit a machine-readable result')
    args = parser.parse_args()
    try:
        issues = validate(args.root, check_hashes=not args.skip_hashes)
    except OSError as exc:
        issues = [f'Unable to read package: {type(exc).__name__}']
    result = {'status': 'FAIL' if issues else 'PASS', 'issues': issues,
              'checks': 'structure, references, invocation policy, eval fixtures' + ('' if args.skip_hashes else ', SHA-256 manifest'),
              'behavioral_model_evals_executed': False}
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print(f"{result['status']}: {result['checks']}")
        for issue in issues:
            print(f'- {issue}')
        print('Live harness discovery, Windows runtime, and model behavior are separate acceptance checks.')
    return 1 if issues else 0


if __name__ == '__main__':
    sys.exit(main())

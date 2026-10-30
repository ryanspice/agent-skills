"""Regression tests for the package validator, not for live agent behavior."""
from __future__ import annotations
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('wayfinder_verify', SOURCE / 'scripts/verify_package.py')
assert spec is not None and spec.loader is not None
verify = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verify)


class PackageValidationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'wayfinder-spice'
        shutil.copytree(SOURCE, self.root, ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))

    def edit(self, relative, old, new):
        path = self.root / relative
        text = path.read_text(encoding='utf-8')
        self.assertIn(old, text)
        path.write_text(text.replace(old, new), encoding='utf-8')

    def structural(self):
        return verify.validate(self.root, check_hashes=False)

    def assertIssue(self, fragment, issues=None):
        values = self.structural() if issues is None else issues
        self.assertTrue(any(fragment in issue for issue in values), values)

    def test_valid_package(self):
        self.assertEqual([], self.structural())

    def test_full_manifest_passes(self):
        self.assertEqual([], verify.validate(self.root))

    def test_name_must_match_directory(self):
        self.edit('SKILL.md', 'name: wayfinder-spice', 'name: different-skill')
        self.assertIssue('parent directory')

    def test_invalid_skill_name(self):
        self.edit('SKILL.md', 'name: wayfinder-spice', 'name: Bad--Name')
        self.assertIssue('Invalid skill name')

    def test_unknown_frontmatter_field(self):
        self.edit('SKILL.md', 'license: MIT', 'unsupported: value\nlicense: MIT')
        self.assertIssue('Unknown or duplicate')

    def test_unquoted_boolean_metadata_rejected(self):
        self.edit('SKILL.md', 'opencode/autoinvoke: "false"', 'opencode/autoinvoke: false')
        self.assertIssue('Invalid package frontmatter')

    def test_duplicate_metadata_rejected(self):
        self.edit('SKILL.md', 'opencode/slash: "true"', 'opencode/slash: "true"\n  opencode/slash: "true"')
        self.assertIssue('Duplicate metadata key')

    def test_long_description_rejected(self):
        path = self.root / 'SKILL.md'
        text = path.read_text(encoding='utf-8')
        line = next(x for x in text.splitlines() if x.startswith('description:'))
        path.write_text(text.replace(line, 'description: "' + 'x' * 1025 + '"'), encoding='utf-8')
        self.assertIssue('Description must')

    def test_missing_core_template(self):
        (self.root / 'assets/DECISION.template.md').unlink()
        self.assertIssue('Missing required file')

    def test_broken_relative_link(self):
        with (self.root / 'README.md').open('a', encoding='utf-8') as handle:
            handle.write('\n[Broken](references/absent.md)\n')
        self.assertIssue('Broken or escaping link')

    def test_escaping_relative_link(self):
        with (self.root / 'README.md').open('a', encoding='utf-8') as handle:
            handle.write('\n[Outside](../outside.md)\n')
        self.assertIssue('Broken or escaping link')

    def test_examples_inside_code_fences_are_ignored(self):
        with (self.root / 'README.md').open('a', encoding='utf-8') as handle:
            handle.write('\n```text\n[Illustration](does-not-exist.md)\n```\n')
        self.assertEqual([], self.structural())

    def test_codex_policy_required(self):
        self.edit('agents/openai.yaml', 'allow_implicit_invocation: false', 'allow_implicit_invocation: true')
        self.assertIssue('Codex explicit-invocation')

    def test_opencode_policy_required(self):
        self.edit('SKILL.md', 'opencode/autoinvoke: "false"', 'opencode/autoinvoke: "true"')
        self.assertIssue('OpenCode manual-invocation')

    def test_claude_policy_required(self):
        self.edit('assets/claude-wrapper.template.md', 'disable-model-invocation: true', 'disable-model-invocation: false')
        self.assertIssue('Claude manual wrapper')

    def test_duplicate_behavioral_id_rejected(self):
        path = self.root / 'evals/scenarios.json'
        data = json.loads(path.read_text(encoding='utf-8'))
        data['cases'][1]['id'] = data['cases'][0]['id']
        path.write_text(json.dumps(data), encoding='utf-8')
        self.assertIssue('Duplicate behavioral case ID')

    def test_empty_rubric_rejected(self):
        path = self.root / 'evals/scenarios.json'
        data = json.loads(path.read_text(encoding='utf-8'))
        data['cases'][0]['checks'] = []
        path.write_text(json.dumps(data), encoding='utf-8')
        self.assertIssue('Invalid behavioral rubric')

    def test_hash_mismatch_rejected(self):
        with (self.root / 'README.md').open('a', encoding='utf-8') as handle:
            handle.write('\nChanged.\n')
        self.assertIssue('Hash mismatch: README.md', verify.validate(self.root))

    def test_unlisted_payload_rejected(self):
        (self.root / 'unexpected.txt').write_text('unexpected', encoding='utf-8')
        self.assertIssue('Unlisted payload file', verify.validate(self.root))

    def test_manifest_traversal_rejected(self):
        with (self.root / 'MANIFEST.sha256').open('a', encoding='utf-8') as handle:
            handle.write('0' * 64 + '  ../outside.txt\n')
        self.assertIssue('Unsafe manifest path', verify.validate(self.root))

    def test_malformed_manifest_rejected(self):
        with (self.root / 'MANIFEST.sha256').open('a', encoding='utf-8') as handle:
            handle.write('not-a-hash README.md\n')
        self.assertIssue('Malformed manifest', verify.validate(self.root))

    def test_duplicate_manifest_rejected(self):
        path = self.root / 'MANIFEST.sha256'
        first = path.read_text(encoding='utf-8').splitlines()[0]
        with path.open('a', encoding='utf-8') as handle:
            handle.write(first + '\n')
        self.assertIssue('Duplicate manifest entry', verify.validate(self.root))

    def test_symlink_payload_rejected(self):
        link = self.root / 'alias.md'
        try:
            link.symlink_to(self.root / 'README.md')
        except (OSError, NotImplementedError):
            self.skipTest('Symlink creation not permitted on this host')
        self.assertIssue('must not contain symlinks')

    def test_missing_frontmatter_delimiter(self):
        path = self.root / 'SKILL.md'
        path.write_text(path.read_text(encoding='utf-8')[4:], encoding='utf-8')
        self.assertIssue('must start with')


if __name__ == '__main__':
    unittest.main()

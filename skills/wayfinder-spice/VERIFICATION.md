# Verification — 2026-10-16

## Executed checks

Environment: Linux build container, Python 3.13.5. This is not Ryan's
Windows computer, a live repository, or an authenticated coding-agent harness.

| Check | Result |
| --- | --- |
| Restricted package frontmatter and standard field shape | PASS |
| Required files and relative Markdown resource references | PASS |
| Codex/OpenCode manual policy values and Claude wrapper flag | PASS, static values only |
| Evaluation fixture structure | PASS; 18 cases present |
| SHA-256 manifest | PASS |
| Package validator regression tests | PASS; 24 tests, no failures |
| TAR.GZ member safety, extraction, and extracted-package validation | PASS |

PASS: independent YAML parsing with PyYAML 6.0.3 already present in the build environment.

Commands run from the built package or its extracted verification copy:

```text
python -B scripts/verify_package.py --json
python -B -m unittest discover -s tests -v
```

The validator tests cover valid input, naming, frontmatter errors, metadata types,
missing templates, broken/escaping links, invocation settings, malformed behavioral
fixtures, tampered hashes, extra files, unsafe manifest paths, and symlink payloads.
These are tests of the validator, not 24 successful LLM workflows.

## Not executed / not claimed

- PowerShell context probe: reviewed, but not parsed or executed by PowerShell here;
  no PowerShell runtime was available. Windows 5.1/7 runtime acceptance is outstanding.
- Native skill discovery and explicit invocation in Ryan's Codex, Claude Code,
  OpenCode, T3 Code, Hermes, or dot environments.
- The 18 behavioral scenarios against a live or mocked LLM harness.
- Hardware inventory, installed versions, auth/capabilities, quotas, or provider canaries.
- Repository diagnosis, source edits, tracker mutations, builds, CI, or device tests for
  any project mentioned in the examples.
- AI-Wiki registration, per-host installation, or promotion to an active personal skill.

## Integrity and interpretation

MANIFEST.sha256 covers all packaged payload files except itself. It detects accidental
changes; it does not authenticate the publisher or replace review before executing scripts.
Changing metadata, templates, or wrappers requires regenerating the manifest through
the established packaging workflow. Do not disable hash checks to label a changed
package identical to this release. No model calls or third-party runtime dependencies
are required for the bundled Python validator.

The skill is built and package-validated. It remains a candidate pending local discovery
and behavioral acceptance. Improved productivity or model equivalence has not been measured.

## Local 1.0.1 adaptation

The results above belong to the supplied 1.0.0 artifact. Current Windows package,
probe, installation, and observed harness results are recorded in the AI Wiki
ingestion receipt and the local fleet evidence directory. They do not establish
all 18 model-behavior scenarios or acceptance in untested harnesses.

## Repository recovery — 2026-10-30

The maintained local package matched the 1.0.1 archive in all 24 files. The archive
SHA-256 was `d8e2639f10a9956538b0124315fd853613c00d6ac84a35d8d634bfcdd2ae7c0f`;
the supplied 1.0.0 archive SHA-256 was
`e301f9d36265f181b644f66d65b264fc36874568510033cd627e482af5fd4d8e`.
The public adaptation changes selected documentation and regenerates the manifest;
it is not byte-identical to the archive. Historical host results are not current
harness acceptance. See the integration PR for current source-validation results.

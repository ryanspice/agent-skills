# GPT-5.5 Web App Builder / Codex Bridge Skill

Version: 0.1.0

This package contains a generated AI Wiki skill for using ChatGPT/GPT-5.5 web sessions as a practical Codex-style builder bridge.

It does **not** make ChatGPT web execute local commands directly. It standardizes a safer human-in-the-loop workflow using:

- reviewable PowerShell scripts,
- small Python utilities,
- clipboard handoffs,
- TAR.GZ packages,
- manifests and hashes,
- temp/self-cleanup hygiene,
- explicit approval gates.

## Canonical install target

```txt
<AI_WIKI_ROOT>\04_skills\generated\gpt55-webapp-builder-codex-bridge\SKILL.md
```

## Dry-run install

From `<DOWNLOADS_ROOT>` or wherever you downloaded the files:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<DOWNLOADS_ROOT>\install-gpt55-webapp-builder-codex-bridge-v0.1.0.ps1" -DryRun
```

## Apply install

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<DOWNLOADS_ROOT>\install-gpt55-webapp-builder-codex-bridge-v0.1.0.ps1" -Force -CleanTemp
```

## Verify after install

```powershell
Test-Path "<AI_WIKI_ROOT>\04_skills\generated\gpt55-webapp-builder-codex-bridge\SKILL.md"
Get-Content "<AI_WIKI_ROOT>\04_skills\generated\gpt55-webapp-builder-codex-bridge\SKILL.md" -TotalCount 20
```

## Package contents

```txt
gpt55-webapp-builder-codex-bridge-v0.1.0/
  SKILL.md
  README.md
  CHANGELOG.md
  .thoughts
  manifest.json
  hashes.sha256
  mcp-skill.json
  reference/
  templates/
  examples/evals/
  scripts/
```

## Notes

- The install script updates the repo-backed source under `04_skills/agent-skills/skills`, not `04_skills/universal`.
- Repo-local `.ai/skills` copies should be mirrors/pointers unless you explicitly promote this skill.
- Self-cleanup is treated as temp hygiene, not secure deletion.

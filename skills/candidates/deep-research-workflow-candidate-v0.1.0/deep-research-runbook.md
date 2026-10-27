# Deep Research Runbook v0.1.0

## Minimal Workflow

```powershell
# 1. Create a working folder in or near the project
$Root = "<SEARCH_ROOT>\research-runs\deep-research-test"
New-Item -ItemType Directory -Force $Root | Out-Null
Set-Location $Root

# 2. Create the core files
@'
# Research Question

## User ask

## Decision this supports

## Source lanes
- AI Wiki local notes/skills
- web primary/current
- repo/code if relevant
'@ | Set-Content .\question.md -Encoding UTF8

@'
topic: example
mode: standard
items: []
execution:
  output_dir: ./results
  search_lanes:
    - local.skill-search
    - local.project-notes
    - web.primary
    - web.recent
'@ | Set-Content .\outline.yaml -Encoding UTF8

@'
fields:
  - name: summary
  - name: evidence
  - name: source_quality
  - name: relevance_to_user
  - name: risks_or_counterevidence
  - name: reusable_patterns
  - name: uncertain
'@ | Set-Content .\fields.yaml -Encoding UTF8
```

## Output Contract

```text
results/
├─ sources.jsonl
├─ evidence-matrix.md
├─ claims-ledger.md
├─ report.md
└─ research-state.json
```

## Verification

```powershell
# Cheap checks before handoff
Get-ChildItem . -Recurse | Select-Object FullName, Length
Select-String -Path .\report.md -Pattern "TODO|TBD|citation needed|source?" -CaseSensitive:$false
```

## Practical Rule

If the work is about your AI Wiki, search local notes/skills first. If the work is about current public facts, web comes in early. If both matter, do both and keep the source lanes labeled.

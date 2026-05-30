# Tool Candidate: deep-research-broker v0.1.0

## Status

Candidate spec, not implemented.

## Goal

Add a research-oriented mode to the local search stack that turns a fuzzy question into a grounded research folder with source lanes, evidence, and a resumable state file.

## Command Sketch

```powershell
Search -Mode Research -Query "{question}" -Profile aiwiki -Out "<SEARCH_ROOT>\research-runs\{slug}" -Open
```

## Inputs

| Param | Required | Notes |
|---|---:|---|
| `-Query` | yes | research question |
| `-Profile` | no | `aiwiki`, `dev-default`, `web-current`, etc. |
| `-Out` | no | run folder |
| `-Lanes` | no | force lanes if broker guesses badly |
| `-Depth` | no | quick/standard/deep |
| `-Open` | no | open output folder |

## Outputs

```text
question.md
outline.yaml
fields.yaml
sources.jsonl
evidence-matrix.md
claims-ledger.md
report.md
research-state.json
```

## State Schema

See `deep-research-state.schema.json`.

## Validation Rules

- No final factual claim without at least one source record or explicit inference label.
- Current/changing claims require current source lane.
- High-risk claims need primary source or explicit uncertainty.
- Report must contain caveats/limitations.
- No TODO/TBD placeholders.

## Implementation Notes

The broker can be lightweight at first:

1. Generate query angles.
2. Run existing rg/Everything/Elastic lanes.
3. Let web/current search be manual or handled by the chat model until local web tooling exists.
4. Write structured Markdown/JSONL files.
5. Add a report generation prompt instead of full automation.

Avoid building a giant agent swamp before the search picker/copy workflow exists. The picker is the sharp tool.

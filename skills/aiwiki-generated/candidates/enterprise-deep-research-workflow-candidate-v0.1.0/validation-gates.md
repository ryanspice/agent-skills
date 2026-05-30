---
title: Enterprise Research Validation Gates
version: 0.1.0
status: candidate
---

# Validation Gates

## Structure Gate

- Executive summary exists for reports longer than 1,000 words.
- Findings are grouped by decision relevance, not random source order.
- Recommendations are separated from evidence.
- Limitations are explicit.

## Evidence Gate

- Major claims appear in `claims-ledger.md`.
- High-impact claims have multiple sources or are labelled as inference.
- Primary/official sources are preferred where available.
- Stale sources are flagged.
- Conflicting evidence is not hidden.

## Citation / Source Gate

- No fake links.
- No placeholder citations.
- URLs/paths/file refs are present in `sources.json`.
- User-provided files and private sources are clearly separated from public web sources.

## Safety / Privacy Gate

- No secrets copied into reports.
- Client/private details are not unnecessarily exposed in general-purpose notes.
- Generated packages avoid credential files, tokens, local env files, and private raw dumps.

## Usefulness Gate

- The output changes the next action.
- The report avoids “research theatre.”
- The user gets a practical recommendation, not just a pile of facts.

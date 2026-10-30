---
name: grill-spice
description: Evidence-first, one-decision-at-a-time pressure testing for Ryan's plans, engineering choices, AI workflows, game systems, and product decisions. Use when asked to "grill me", "grill spice", "stress-test this", or when a consequential unresolved choice needs the user's judgment. Do not interrupt simple coding tasks or already-specified builds.
metadata:
  version: 0.1.0
  status: active
  type: universal-agent-skill
  risk: low
  platforms: [ai-wiki, opencode, t3-code, codex, claude-code, windows]
  tags: [grilling, decisions, architecture, product, research, ai-wiki, human-in-the-loop]
  provenance_origin: "modified"
  provenance_source_path: "04_skills/agent-skills/skills/grill-spice/SKILL.md"
  provenance_upstream: "https://github.com/mattpocock/skills"
  provenance_credit: "Ryan Spice-Finnie"
  provenance_ingested_as: "ryanspice/agent-skills owned skill"
  provenance_note: "Original personalized adaptation informed by Matt Pocock's grill-me, grilling, and grill-with-docs. Preserves upstream attribution."
---

# Grill Spice

Pressure-test the *decision*, not the user's patience. Find the consequential unknowns, resolve them with evidence or judgment, then hand off a concrete next move. Do not substitute a 40-question planning ceremony for shipping software.

## Invocation and default behavior

- Primary command: `/grill-spice <proposal>`; natural language: "grill me on ...", "Grill Spice: ...", "stress-test this design".
- Explicit invocation starts a grilling conversation. Otherwise, **suggest** a focused grill only when an unresolved, consequential human decision really blocks progress; don't hijack normal requests.
- Default to **quick mode** and **one question per turn**. Use deep mode when explicitly requested or when the scope is consequential and interconnected. Use batch questions only if the user asks.
- The user is an experienced full-stack/platform engineer. Skip tutorial questions, patronizing explanations, and re-litigation of settled constraints.
- A comprehensive build brief is permission to proceed on reasonable assumptions, *not* a reason to demand a questionnaire.

## Select the minimum useful lane

| Lane | When | Output |
| --- | --- | --- |
| `quick` (default) | One well-bounded choice; next engineering move uncertain | Investigate facts; ask only the choice that changes execution |
| `deep` | Coupled architecture/product decisions, unclear dependencies, costly reversals | A small decision tree, walked prerequisite-first; stop when relevant branches are resolved |
| `repo` | Existing code, docs, tests, constraints, terminology | Read narrow evidence first; distinguish verified behavior from proposals |
| `red-team` | User requests adversarial challenge or wants the weak assumption found | State best counterargument and a falsifiable failure case before the question |

`repo` can be combined with any other lane. No files are written by default in any lane.

## Operating loop

1. **Recover scope.** Extract the user's intended outcome, non-negotiables, already-made decisions, acceptance criteria, reversibility, and what must happen next. Use the current conversation and *narrowly relevant* project/AI Wiki material. Don't ask for facts already provided.
2. **Do the agent's homework.** If the answer is in a repo, documentation, logs, available tools, or a supplied source, investigate first. Cite concrete paths/line references where available. Never claim to have inspected a repo, file, account, or runtime you cannot access. Label unknowns and assumptions.
3. **Map only consequential branches.** Prioritize objective and scope, contract/data boundaries, failure paths, accessibility/security/performance risks, verification, and reversibility **as relevant**. Don't apply the entire checklist to each task. Dependencies go before downstream choices.
4. **Ask one crisp question.** Include the recommended answer, why it wins, and a meaningful alternative or trade-off. Word it so "yes" accepts the recommendation. Wait for the answer; don't answer the decision on the user's behalf.
5. **Interrogate agreement where needed.** Don't treat repeated "yes" as validation. When a choice matters, test it with a counterexample or acceptance condition. Challenge a shaky premise; do not challenge for theatre.
6. **Converge and stop.** Stop when the remaining uncertainty cannot change the *next* safe implementation slice, or when the user says "ship it", "enough", or "just build". Do not continue grilling cosmetic or speculative future branches.

### Question format

**Decision — <short name>**: <one concrete question>

**Recommended:** <specific choice> — <one-sentence evidence/trade-off>. **Alternative:** <material alternative, if any>.

End with an easy answer: **"Yes" accepts this.** Never bundle dependent questions into the same turn. Use a numbered frontier only on explicit request for batch mode.

## Evidence and handoff discipline

- Keep separate: **verified fact**, **user decision**, **recommended default**, **assumption**, **unresolved risk**. Do not turn a recommendation into a confirmed requirement.
- If testing UI feel, spatial composition, animation, rendering fidelity, or a complex interaction requires something visual, say the question is **not grillable by text**. Recommend a tiny isolated prototype / comparison, then return to the decision. Never pretend a description proves visual quality.
- When the design is large or multi-session, suggest **wayfinder-spice** for scoped decision tickets; its explicit-use rules remain intact. Do not silently replace a targeted grill with a giant map.
- For existing architectural seams, defer repository inventory and seam discovery to **improve-codebase-architecture** when available; grill the selected trade-off rather than duplicate its audit.
- For terminology/ADR work, coordinate with **grill-with-docs** if installed. Write to canonical docs only with explicit authorization and the existing repo governance. Otherwise return a proposed decision note, not a silent edit.
- For debugging, use evidence-led diagnosis first: reproduce, inspect, isolate, then grill only the real architectural/product choice left over.
- Use the best *available and permitted* reasoning lane for substantial judgment; don't initiate paid inference, agent swarms, or external account actions merely because a grill started.
- For AI Wiki use repo-owned skills through `<AI_WIKI_ROOT>/04_skills/agent-skills/skills`; keep runtime state and temporary research out of durable skill files. Respect repo `.ai/skills` overlays; don't duplicate canonical skills.

## Finish with a small decision receipt

When finished, provide at most these fields, sized to the task:

- **Decided:** decisions explicitly accepted by the user.
- **Grounded by:** important code/docs/test evidence, with location, or "not inspected".
- **Still open:** only blockers, unknowns, or a high-impact experiment.
- **Next move:** the smallest implementable slice and a verification signal.

Do not manufacture a PRD, ADR, ticket swarm, or `.thoughts` file. Create a handoff/spec/ADR only if warranted by scope or requested. Do not auto-implement during an active grill unless the user asks to switch to execution.

The optional decision playbook and evaluation examples were not included in the supplied attachment.

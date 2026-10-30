---
name: code-and-plan
description: Turn a likely-to-be-built feature or architecture idea into a compact, implementation-ready plan by looping consequential questions through code sketches, then using what the code reveals to revise decisions, integration seams, and feature slices. Compose Wayfinder Spice and Grill Spice where available. Use when explicitly asked for "Code n' Plan", "code-and-plan", or code-backed feature planning; not for routine fixes or an automatic build.
license: MIT
metadata:
  compatibility: "Filesystem skills for OpenCode, Claude Code, Codex and other Agent Skills-compatible hosts; no commands, providers or repository writes are assumed."
  provenance_origin: "original"
  provenance_source_path: "04_skills/agent-skills/skills/code-and-plan/SKILL.md"
  provenance_credit: "Ryan Spice-Finnie"
  provenance_ingested_as: "ryanspice/agent-skills owned skill"
  provenance_note: "Imported from the user-provided skill attachment."
  version: "0.1.0"
  status: "candidate"
  origin: "Ryan Spice agent-skills composition"
---

# Code n' Plan

**Question -> code -> new question -> better plan -> implementation handoff.**

Purpose: do most of the technical thinking for a feature the user probably intends to build, **without making the user supervise every detail or mistaking speculative code for working software**. The output is a small set of code-backed, ordered feature slices, not a giant PRD or a patch.

## Activation and authority

- Explicit invocations: `Code n' Plan: <goal>`, `code-and-plan <goal>`, or "plan this with implementation sketches." Alias for people: **Code n' Plan**; filesystem ID: `code-and-plan`.
- Do not hijack an ordinary fix, audit, or already-approved build. If a small task is straightforward, say **"No planning loop needed"**, give the concrete action and follow the original request.
- **Default mode: plan-only.** Read permitted project evidence and author example code *in the response or a requested planning artifact*. No product source edits, package installs, destructive probes, branches, commits, pushes, paid inference, provider changes, or deployment merely because this skill was invoked.
- If implementation or an isolated executable probe is explicitly authorized, define and enforce its own scope; do not infer permission for production edits from permission to draft snippets. Treat test execution and writing files as distinct from simply proposing code. Repo instructions and host permissions override this skill.
- Never label hypothetical code as built, tested, integrated, or compatible with unseen files. Never treat agent recommendations as owner-accepted decisions.

## Compose existing skills; don't clone them

1. Discover and read `wayfinder-spice/SKILL.md` and `grill-spice/SKILL.md` (or the repository's explicitly routed `grill-me` -> `grilling`) **when accessible**. The request for Code n' Plan explicitly requests their *planning roles*; it does not override their write/implementation gates.
2. **Wayfinder Spice** owns destination, evidence, decision dependencies, reuse of one canonical map, uncertainty and ordered implementation handoff. Use a map only for material interdependent uncertainties; reuse the current plan/tracker instead of starting another.
3. **Grill Spice** challenges consequential assumptions and owner-only trade-offs, one focused question at a time, with a recommended default. Facts answerable from source or safe analysis are the agent's responsibility.
4. Add Code n' Plan's distinctive **code-as-probe feedback loop** between the two. Load `improve-codebase-architecture` only when an existing integration seam genuinely needs examination. Use the host's actual skill-loading mechanism rather than pretending a name is an executable command.
5. If a dependency is missing, say which one was unavailable. Continue with the small equivalent behavior described here and label it a fallback. Do not invent installed skill content, permission, or repo findings.

## Workflow (one coordinator, minimum useful scope)

### 1. Orient and ground

From the request and narrowly relevant repo material, identify: **outcome**, **hard constraints**, **existing implementation/integration seam**, **acceptance signal**, **authorized operations**. Prefer `AGENTS.md`, applicable policies/intent, active plan, representative source/tests, manifests, and version-specific docs. Respect `.thoughts` whether file or folder. Distinguish **observed / decided / proposed / assumed / not verified**.

If the repository is inaccessible, give portable sketches and label target paths *suggested, not inspected*. Never invent existing APIs or file paths. Do not ask the user for a detail a repo read would answer.

### 2. Start a small decision frontier

Map at most **three active questions** by default. Order prerequisite decisions first. For each: the likely answer, competing approach (including reuse/no-change), evidence required, and who owns the decision. Proceed on a clearly labeled reversible assumption for low-risk choices. Ask the owner only when a consequential preference, permission, cost, security exposure, or irreversible design boundary blocks the *next* slice. Otherwise continue autonomously.

### 3. Sketch code to interrogate the plan

For each material unknown, choose the **smallest code probe** that could change the decision:

- interface/data contract, representative function, component seam, event/data flow, migration sketch, or test/pseudotest;
- use the project's actual language and idioms if observed; otherwise state the illustrative stack;
- name expected inputs/outputs, the **suggested or verified** integration location, and the evidence that would falsify the approach;
- produce a concise snippet (normally 10-40 lines), not full feature code or a speculative subsystem.

Snippets are **proposed** by default. An authorized disposable execution can establish narrow runtime facts; explicitly record commands, environment, result, and limits. Never claim an unrun snippet compiles.

### 4. Feed code discoveries back into the questions

After each sketch, explicitly ask internally:

- What hidden dependency, invariant, edge case, compatibility assumption, or missing contract did this code expose?
- Does that change the recommended option, add one blocker, or make a previous question irrelevant?
- What is the smallest check (code, test, source read, or one user choice) that resolves it?

Update the existing frontier and the plan *before* producing more code. Preserve causal links: **Q1 -> sketch S1 -> finding F1 -> plan revision P1**. Reopen a settled decision only on genuinely new evidence, not because another agent prefers a different style.

Default to **one focused probe per meaningful uncertainty, and at most two feedback passes** without new evidence. After two failed speculative approaches, stop thrashing: name the missing fact and one diagnostic next move.

### 5. Build code-backed feature slices

When scope warrants a saved plan, use the compact feature-card fields below. The referenced template was not included in the supplied attachment. Each slice should include:

- user-visible result and explicit non-goal;
- verified integration seam/target path, or `suggested; repo not inspected`;
- relevant decision and why this approach won;
- implementation-shaped code contract/snippet with **proposal vs verified** status;
- dependency on earlier slices and integration steps;
- acceptance check, failure/rollback strategy, and one relevant test;
- newly exposed questions and their resolution or owner.

Keep **three to five** slices unless the feature truly needs more; the initial response may be only one screen. For visual/interaction uncertainty, propose a tiny renderable comparison rather than text pretending to establish appearance.

### 6. Finish where implementation can begin

Deliver, in this order, sized to task:

1. **Recommended design** and what evidence supports it.
2. **Code-backed feature plan** in dependency order (short snippets or links to saved examples).
3. **Code changed the plan:** the material questions and revisions generated by sketches.
4. **Still open:** only owner decisions or decisive unknowns; if none, say so.
5. **First executable slice:** likely files, instructions, verification, and rollback. Label any invented paths.

Stop when remaining uncertainty cannot change the next safe slice. Do **not** require an empty backlog or universal certainty. Separate `decision-ready`, `implementation-ready`, `implemented`, `verified`, and `owner-accepted` states. Plan completion alone never grants implementation authority.

## Modes and handoff

- `quick` (default): one or two uncertainties, compact sketches, a practical first slice; no formal map when unnecessary.
- `deep`: interconnected architecture/product work, code probes across boundaries, explicit dependency map and staged delivery.
- `repo`: combine either mode with read-only source inventory and verified file/test references.
- `resume`: load the *existing* plan and decision receipts; continue the earliest unresolved, dependency-satisfied question. Never create a competing ledger.
- `handoff`: compress evidence, accepted decisions, ordered slices, illustrative code, exact verified commands (or `not verified`), and one next move for another coding agent.
- `execute`: only when the user separately authorizes building; follow the repo's execution workflow. This skill does not itself grant such authorization.

For large handoffs, package a `.tar.gz` with README, concise source/snippet files, verification notes and continuation guidance. Put ephemeral state in the existing runtime/worktree location; keep durable authored skill content in the AI Wiki's canonical skill lane, not duplicated across the fleet.

## Anti-patterns

No 40-question interview; no automatic swarm; no code dump without integration evidence; no fictional compile/test results; no speculative architecture rewrite for an ordinary fix; no second map; no silent promotion of code sketches to production; no user consent inferred from a recommended default; no copying Wayfinder or Grill Spice instructions into this skill.

The optional article-queue example and evaluation cases were not included in the supplied attachment.

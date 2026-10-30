---
name: cjk-ui-lab
description: Use when building, auditing, or expanding a CJK-native Japanese/Korean SvelteKit UI lab, design-system token pipeline, typography/localization test screens, accessibility rubrics, or agent prompts for CJK UI research and implementation.
status: active
type: universal-agent-skill
risk: medium
tags: ["cjk-ui", "japanese-ui", "korean-ui", "sveltekit", "design-system", "accessibility"]
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/cjk-ui-lab/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki local skill credited to Ryan Spice-Finnie."
metadata:
  hermes:
    tags: [cjk-ui, japanese-ui, korean-ui, sveltekit, design-system, accessibility]
    related_skills: [sveltekit2-svelte5-engineering, image-to-ui-sveltekit]
---

# CJK UI Lab

## Purpose

Build CJK-native product interfaces and labs for Japanese and Korean users. The target is not decorative "Asian" styling. The target is product taste plus engineering discipline: typography, density, hierarchy, language behavior, tokens, accessibility, and verification all fit the locale.

Use this skill for `cjk-ui-lab` work, CJK design-system prompts, Japanese/Korean UI audits, CJK typography experiments, and SvelteKit implementation passes that need language-aware layout.

## Source Discipline

Prefer official or primary references first. Read `references/research-sources.md` when the task depends on current design-system, layout, token, or accessibility claims.

Baseline source families:

- Japan: Digital Agency Design System, Digital Agency design tokens, JLReq, SmartHR/LINE style material when relevant.
- Korea: KRDS, KLReq, KWCAG/WCAG references, Toss/SOCARFRAME/Kakao/Naver product-system examples when relevant.
- Global: WCAG 2.2, Design Tokens Community Group, MDN CSS text/ruby/lang docs, Noto font docs, SvelteKit/Svelte docs.

Do not treat Japanese and Korean UI as one aesthetic. Share the engineering substrate, then tune typography, copy, navigation, density, and interaction patterns separately.

## Workflow

1. **Inspect the project.** Confirm package manager, Svelte/SvelteKit versions, scripts, route shape, token/style conventions, and existing docs. For a new empty repo, use SvelteKit 2 + Svelte 5 + TypeScript with Bun unless local signals say otherwise.
2. **Ground the design direction.** Pick the mode before building: JP editorial-commerce, JP dense service, KR fintech/clean, KR commerce/search, or public-service CJK. Record the reference basis in a short doc or route note.
3. **Design the token substrate.** Create primitive, semantic, and component tokens for type, spacing, radius, color, elevation, motion, and state. Keep fonts language-aware with `:lang(ja)` and `:lang(ko)`.
4. **Build screens as product workflows.** Include real Japanese/Korean text, long and short labels, loading, empty, error, disabled, mobile, desktop, dark, and high-contrast states.
5. **Componentize only after the first vertical slice.** Extract primitives and repeated product surfaces when they remove duplication or clarify state. Avoid a huge one-file demo, but do not build a full design-system package before there are screens to serve.
6. **Verify accessibility and layout.** Check headings, landmarks, focus, keyboard operation, labels, contrast, reduced motion, `lang`, CJK line-breaking, Hangul wrapping, ruby/furigana where used, and mobile text fit.
7. **Package the learning.** Keep docs that explain what changed and why: source notes, token architecture, audit rubric scores, implementation decisions, and next experiments.

Completion criteria:

- Four starter screens exist or have been intentionally scoped down: Japanese lifestyle product detail, Japanese long-form article, Korean fintech dashboard, Korean commerce search/results.
- At least one shared token module and one shared component primitive are used by multiple screens.
- JP/KR text is real enough to stress wrapping, labels, prices/numbers, validation, and hierarchy.
- `bun run check` and `bun run build` pass, or failures are reported with exact causes.

## Implementation Pattern

Read `references/sveltekit-implementation-pattern.md` before creating or restructuring the lab.

Recommended shape:

```txt
src/
  lib/
    components/
    data/
    tokens/
    typography/
    themes/
  routes/
    +layout.svelte
    +page.svelte
    ja/
    ko/
    lab/
docs/
  research/
  teardowns/
  accessibility/
  decisions/
```

Use routes for user-facing examples and docs for source notes. Keep generated screenshots and build outputs out of source control unless the repo convention says otherwise.

## CJK Typography Rules

- Use `lang` on every localized section, not just the root document.
- Use language-specific font stacks. Prefer system CJK fonts first and Noto as a studied fallback, not an automatic heavy webfont dependency.
- Keep CJK letter spacing at `0` unless a concrete font/brand case proves otherwise.
- Use `line-break: strict` for Japanese examples where punctuation rules matter.
- Use `word-break: keep-all` for Korean, with overflow guards for narrow UI.
- Avoid italics for Japanese/Korean emphasis. Use weight, color, badge, border, or layout.
- Test mixed script: kanji/kana/romaji/numerals and Hangul/Latin/numbers/currency.
- Include long form labels, validation text, and mobile cards that force wrapping.

## Product Modes

### Japanese Editorial-Commerce

Use calm rhythm, high-quality imagery, restrained type, article-to-product flow, explicit trust details, careful price/tax/shipping metadata, and polite microcopy. Avoid hiding critical purchase detail behind minimalism.

### Japanese Dense Service UI

Use complete labels, visible process state, precise validation, reassuring confirmation, and information grouping. Dense does not mean chaotic; it means every visible item earns its place.

### Korean Fintech/Clean

Use decisive hierarchy, fast task completion, clean cards, big numbers, strong CTAs, status clarity, and compact but breathable modules.

### Korean Commerce/Search

Use search-first navigation, price/ranking hierarchy, filters, promo velocity, and mobile-first scanning. Preserve Hangul wrapping and do not over-letterspace labels.

### Public-Service CJK

Use conservative tokens, clear components, forms, summaries, accessibility, error prevention, and reusable implementation contracts. Reference Digital Agency and KRDS before inventing patterns.

## Agent Surface Notes

Canonical source is this agent-skills folder. Tool-specific copies should be junctions, pointers, or faithful mirrors:

- Codex local mirror: link by explicit `--name cjk-ui-lab` selection, preferably with the existing `aiwiki-gen-` prefix convention.
- Claude local mirror: one skill folder named `cjk-ui-lab` with this `SKILL.md`.
- Hermes local mirror: place under the software-development skill category unless a dedicated design category already exists.

Do not fork behavior across tools unless the tool format requires it. If a mirror needs tool-specific frontmatter, keep the body behavior equivalent and note the divergence.

## Quality Gates

Read `references/audit-rubric.md` for scoring.

Minimum gates:

- Typography: no obvious CJK wrapping, clipping, line-height, or language attribute failures.
- Hierarchy: primary user action is clear in JP and KR without English-only assumptions.
- Native feel: layout decisions are explained through product behavior and local conventions, not motifs.
- Accessibility: keyboard, labels, contrast, focus, motion, and screen-reader basics are handled.
- System quality: tokens and components are reusable enough for the next screen.

## Common Pitfalls

- Using Japanese/Korean characters, motifs, colors, or mascots as decoration instead of product logic.
- Hardcoding English-first layout widths and then translating labels after the fact.
- Treating JP and KR typography as interchangeable because both are CJK-adjacent.
- Loading huge CJK webfonts before proving the need and performance strategy.
- Making only pretty normal states; missing empty, loading, error, disabled, long text, and mobile states.
- Adding a component library before the lab has enough screens to reveal real patterns.
- Claiming accessibility quality without running build/check and inspecting rendered behavior.

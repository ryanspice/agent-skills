# CJK UI Audit Rubric

Use this rubric for lab screens, teardowns, and final review. Score from 0 to the category maximum, then write one sentence explaining the main evidence.

| Category | Points | Check |
|---|---:|---|
| Typography | 20 | Font stack, line height, CJK line breaking, Hangul wrapping, mixed-script rhythm, labels, truncation. |
| Hierarchy | 15 | Primary action, scan path, grouping, price/number emphasis, title/body/meta distinction. |
| Layout Density | 15 | Information-rich without visual sludge; mobile density remains useful. |
| Native Product Feel | 15 | Local product conventions, copy length, navigation, trust/status patterns, no shallow motifs. |
| Accessibility | 15 | Contrast, focus, keyboard, labels, `lang`, screen-reader behavior, reduced motion. |
| Motion/Feedback | 10 | State changes, loading, validation, transition clarity, no motion dependency. |
| System Quality | 10 | Tokens, reusable components, states, documentation, verification discipline. |

## Score Bands

- 90-100: strong enough to dissect as a model.
- 75-89: good direction, needs targeted fixes.
- 60-74: useful prototype, not portfolio-ready.
- Below 60: redesign the workflow before polishing visuals.

## Audit Template

```txt
Screen:
Locale:
Mode:
Primary user job:
Typography /20:
Hierarchy /15:
Layout density /15:
Native product feel /15:
Accessibility /15:
Motion/feedback /10:
System quality /10:
Total:
Keep:
Fix next:
Evidence:
```

## Red Flags

- JP/KR content appears only as decoration or sample filler.
- Product cards, buttons, or form rows clip long localized labels.
- Korean text breaks syllable/word rhythm in narrow components.
- Japanese punctuation creates awkward leading/trailing line breaks.
- The design depends on English headings to understand hierarchy.
- Color is the only state indicator.
- No loading, empty, error, or validation state exists.
- Token choices are undocumented one-offs.

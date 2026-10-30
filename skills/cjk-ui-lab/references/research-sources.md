# CJK UI Lab Research Sources

Last reviewed: 2026-06-25.

Use this file to ground CJK UI lab decisions. Re-check live sources before making claims about latest versions, current releases, or legal/accessibility requirements.

## Japan

- Digital Agency Design System: https://www.digital.go.jp/en/policies/servicedesign/designsystem
  - Use as the public-service baseline for usability, accessibility, searchability, and reusable design-system practice.
- Digital Agency Design System beta resources: https://design.digital.go.jp/dads/resources/
  - Reviewed page showed beta v2.15.0, updated 2025-02-28, with Figma data, HTML snippets, React snippets, and a Tailwind plugin based on tokens.
- Digital Agency design tokens: https://github.com/digital-go-jp/design-tokens
  - Use for token pipeline study. The repository documents CSS/JavaScript-friendly assets and a Tokens Studio for Figma -> GitHub -> Style Dictionary -> npm flow. Reviewed page showed latest release v2.0.1 on 2026-05-28.
- JLReq: https://www.w3.org/TR/jlreq/?lang=en
  - Use for Japanese layout requirements, especially line breaking, punctuation, spacing, mixed text, and ruby implications.
- Japanese script resources: https://w3c.github.io/jlreq/jpan/
  - Use as a resource index when Japanese script support questions go beyond a single CSS property.

## Korea

- KRDS about: https://www.krds.go.kr/html/eng/utility/utility_01.html
  - Use as the Korean public-sector design-system baseline: rules, principles, components, style guides, patterns, and tools for consistent UX and efficient design/development.
- KRDS getting started: https://www.krds.go.kr/html/eng/outline/outline_01.html
  - Use for KRDS positioning around designers, developers, government officials, guidelines, and code.
- KRDS accessibility: https://www.krds.go.kr/html/eng/utility/utility_04.html
  - Use for Korean public-service accessibility alignment. Verify current KWCAG/WCAG wording before citing.
- KLReq: https://www.w3.org/TR/klreq/
  - Use for Hangul text layout and typography. Reviewed latest published version was a W3C Group Note Draft dated 2026-03-21.

## Global Technical Foundations

- WCAG 2.2: https://www.w3.org/TR/WCAG22/
  - Use as the accessibility baseline for web UI. Pair with local JIS/KWCAG rules when the target market requires them.
- W3C/WAI WCAG overview: https://www.w3.org/WAI/standards-guidelines/wcag/
  - Use to confirm current guidance and relationships between WCAG versions.
- Design Tokens Community Group stable spec note: https://www.w3.org/community/design-tokens/2025/10/28/design-tokens-specification-reaches-first-stable-version/
  - Use for the 2025.10 stable specification milestone and vendor-neutral design-token framing.
- DTCG format spec: https://www.designtokens.org/TR/2025.10/format/
  - Use when shaping token JSON that may move across tools.
- MDN `line-break`: https://developer.mozilla.org/en-US/docs/Web/CSS/line-break
  - Use when implementing CJK punctuation/line-breaking behavior.
- MDN `:lang()`: https://developer.mozilla.org/en-US/docs/Web/CSS/:lang
  - Use when styling language-specific regions.
- MDN ruby layout: https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_ruby_layout
  - Use when adding furigana/ruby examples.
- Noto docs: https://notofonts.github.io/noto-docs/website/use/
  - Use for font-family strategy and fallback study.

## Product-System References

- Toss Design System article: https://toss.tech/article/toss-design-system
  - Use for Korean product-system thinking around real cases, aesthetics, and usability.
- SOCARFRAME: https://socarframe.socar.kr/
  - Use as a Korean product-system example.
- LINE Design System: https://designsystem.line.me/
  - Use as a Japanese/Korean-adjacent product-system reference when messaging/super-app patterns matter.

## Research Behavior

- Prefer official design-system docs for component/tokens/accessibility claims.
- Use product sites/apps for taste teardown, not as normative accessibility sources.
- Capture source, date reviewed, screen type, and what the lab actually learned from it.
- Do not paste long copyrighted source text into the lab. Summarize decisions and link to the source.
- If a source is in Japanese or Korean, keep the original term when it changes implementation behavior.

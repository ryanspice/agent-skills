---
name: social-preview-unfurl-verification
description: Diagnoses, implements, and verifies Open Graph and Twitter/X link-preview metadata, raster share images, crawler access, and cache refresh behavior. Use when a public URL has no preview, shows the wrong image in Facebook or Messenger, differs across sharing apps, or needs social SEO metadata tested before release.
metadata:
  version: "0.1.0"
  platforms: [windows, web, sveltekit, static-sites]
  tags: [seo, open-graph, social-preview, unfurl, facebook, messenger]
  risk: low
  provenance_origin: "original"
  provenance_source_path: "04_skills/agent-skills/skills/social-preview-unfurl-verification/SKILL.md"
  provenance_credit: "Ryan Spice-Finnie"
  provenance_ingested_as: "ryanspice/agent-skills owned skill"
  provenance_note: "Original AI Wiki skill derived from production social-preview diagnosis and verification work."
---

# Social Preview Unfurl Verification

Make social cards reliable by testing the public response a crawler receives, not only the source component or hydrated browser DOM.

## Boundaries

- Treat social previews, search indexing, and on-page SEO as related but separate surfaces.
- Do not promise that a passing protocol check proves a particular app UI. Meta's backend can pass while an existing Facebook or Messenger conversation still displays cached data.
- Do not expose a private page, title, description, or image merely to make a preview work. A share image is a public asset.
- Do not deploy, purge a CDN, log into a platform, or request a new scrape unless the user has authorized that external action.

## Workflow

1. Inspect the current repository, its scoped instructions, framework metadata surface, build mode, and deploy configuration.
2. Capture the exact failing URL, expected image, affected apps, and whether the report concerns a fresh share or an existing cached message.
3. Inspect both source metadata and asset generation, then initial built or live HTML plus the live image response.
4. Add or correct the smallest metadata set and a share-specific raster asset. Metadata must exist in the initial HTML without requiring JavaScript hydration.
5. Build or prerender the affected route, then inspect the produced HTML. A source component is not proof that static output contains the tags.
6. Run the bundled verifier against the live URL or a locally served build:

   ```powershell
   node scripts/verify-social-preview.mjs --url "https://example.com/page/"
   ```

   Use `--image`, `--expect-width`, or `--expect-height` only when the page deliberately differs from the 1200 by 630 default. Use `--json` for machine-readable evidence.
7. Verify in a real browser and, when Meta is affected, in the official Sharing Debugger. Request a new scrape only after the live response is correct.
8. Test a fresh standalone share in the affected app. Record app/device proof separately from crawler proof.

Read [references/platform-notes.md](references/platform-notes.md) when implementing the tag set, diagnosing Meta/iOS Messenger behavior, or handling a stale preview cache.

## Required implementation qualities

- Absolute HTTPS canonical, `og:url`, and image URLs.
- Open Graph title, description, type, URL, image, image MIME type, dimensions, and meaningful image alt text.
- `twitter:card` set to `summary_large_image`, with matching title, description, image, and image alt text.
- A dedicated PNG or JPEG share image, normally 1200 by 630 (about 1.91:1), visually checked at small card size.
- Correct public `Content-Type` and successful crawler-style GETs for both HTML and image.
- No authentication, WAF rule, hotlink protection, redirect loop, or response-header policy preventing the preview crawler from receiving the asset.
- A versioned image filename when the image bytes materially change. Updating only the bytes at an already cached URL is unreliable.

## Diagnosis order

Use this order so cache symptoms do not trigger unnecessary code changes:

1. Missing or conflicting tags in initial HTML.
2. Relative, redirected, inaccessible, non-raster, or incorrectly typed image URL.
3. Wrong dimensions or composition.
4. Crawler-specific HTTP, compression, range, robots-header, CDN, or WAF behavior.
5. Platform cache.
6. App-specific rendering difference.

If live crawler checks pass but a previously shared message remains wrong, label cache as the leading explanation and test a fresh conversation or the platform debugger before changing metadata again.

## Evidence to report

State exactly which layers passed:

- source metadata inspected;
- built or prerendered HTML inspected;
- live page fetched with crawler user agent;
- live image fetched and dimensions decoded;
- platform debugger refreshed;
- real Facebook, Messenger, or iOS share observed.

Never collapse these into a single claim such as "Messenger verified" unless the actual app share was observed.

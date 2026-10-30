---
name: blog-publish
description: Publishes articles to blog.ryanspice.com and blog.canopydigital.ca. Use when writing, formatting, creating diagrams, committing, pushing, or deploying blog posts. Works from any project — the skill handles cross-repo coordination.
version: 0.1.0
status: active
type: universal-agent-skill
risk: high
platforms: [windows, ai-wiki, mcp, blog]
tags: [blog, publishing, sveltekit, deployment, verification]
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/blog-publish/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Universal blog publishing skill for blog.ryanspice.com and blog.canopydigital.ca."
---

# Blog Publish

Streamlined workflow for publishing articles to both blogs from any project.

## Editorial contract

- Inspect the current repo state, `docs/WRITING.md`, the project-local skill, and a recent rendered article before editing. Preserve unrelated working-tree changes.
- Draft a complete, reviewable article with `status: "draft"`; do not turn a draft into a public post, commit, push, merge, or deploy unless the user asks. Research notes alone are not an article.
- Use a short lead and descriptive sections so readers can scan or enter mid-article. Split a long story into separately linked posts when the parts answer distinct questions, serve different audiences, or need independent evidence and updates. Give each part a standalone lead.
- Put descriptive inline links beside meaningful claims, figures, named tools, and related concepts. Prefer primary sources; identify vendor claims, independent findings, and inference. Use `references` as a source index and `further_reading` for optional next reads; neither substitutes for links in the prose. Link relevant existing posts naturally, verify targets, and avoid repetitive or indiscriminate links.
- Add a project-bound focal image when useful and a separate in-body diagram, screenshot, chart, or other figure when it explains the text. Place figures near the relevant section, introduce the takeaway, provide alt text, caption/credit/source as applicable, and make dense diagrams available full size. Do not repeat the hero as the first body figure by default.
- For time-sensitive claims, include when they were checked and what readers can verify now. Keep EN/FR article and metadata parity where translations exist. For revisions, update `updated_date` while retaining original `date` and release metadata unless the user requests a new edition.
- Review rendered Ryan and Canopy article routes, mobile width, links, figures, captions, metadata, Sources/Further reading, SEO and sitemap output. State separately which checks were source/build, browser, and live deployment checks.

## Blog repo location

```
<AI_WIKI_ROOT>/07_Projects/blog.ryanspice.com
```

Always work in this repo regardless of which project triggered the article.

## Article structure

Articles live at:

```
src/lib/content/articles/<slug>.md
```

Images live at:

```
static/img/articles/<slug>/
```

## Frontmatter contract

Every published article needs:

```yaml
---
title: "Article Title"
seo_title: "SEO-optimized title (optional, defaults to title)"
slug: "url-slug"
status: "published"                    # "draft" or "published"
draft_type: "field-note"               # field-note, essay, build-log, case-study, research-note, etc.
date: "2026-08-26"
updated_date: "2026-08-26"
publish_at: "2026-08-26T21:00"         # optional scheduling
release_date: "2026-08-26"
release_time: "21:00"
summary: "One-line summary for cards and SEO"
seo_description: "Longer description for meta tags"
accent: "#00d4aa"                      # theme accent color
image: "/img/articles/<slug>/hero.svg" # hero/portrait image
image_alt: "Alt text"
image_credit: "Credit line"
image_source: "/img/articles/<slug>/hero.svg"
image_position: "center top"
row_image: "https://images.unsplash.com/..." # card thumbnail
row_image_alt: "Alt text"
row_image_credit: "Unsplash"
row_image_source: "https://unsplash.com/photos/..."
row_image_position: "center center"
background_image: "https://images.unsplash.com/..." # optional background
background_image_alt: "Alt text"
background_image_credit: "Unsplash"
background_image_source: "https://unsplash.com/photos/..."
background_image_position: "center center"
audience:
  - "target audience 1"
  - "target audience 2"
tags:
  - "Tag1"
  - "Tag2"
credits:
  - "Author Name"
references:
  - "Original article diagrams|/img/articles/<slug>/diagram.svg"
  - "Source name|https://url"
related_posts:
  - "related-article-slug"
---
```

## SVG diagram style (when using SVG)

All diagrams follow this style:

- Dark background: `#07111f` to `#12283a` gradient
- Inner panel: `#0b1928` with `#28445b` stroke
- Font: `Segoe UI, Arial, sans-serif`
- Title: 34px, `#f8fafc`, weight 700
- Subtitle: 20px, `#a8bed0`
- Bar/chart colors: gradients from existing palette
  - Cyan: `#48c5d6` to `#2f9bc2` (new/featured items)
  - Gold: `#f4c273` to `#f59e69` (flat-rate/subscription)
  - Purple: `#a78bfa` to `#7c3aed` (GLM/reasoning)
  - Blue: `#8f9fff` to `#6678e8` (DeepSeek/paid)
  - Gray: `#6b7280` to `#4b5563` (deprecated/old)
  - Green: `#a3e635` (free tier/success)
- Drop shadows: `feDropShadow dx="0" dy="10" stdDeviation="16" flood-opacity="0.28"`
- Always include `role="img"` with `aria-labelledby="title desc"`
- ViewBox: `0 0 1200 720` for charts, `0 0 1600 900` for architecture diagrams

## Publishing workflow

### 1. Write the article

Create `src/lib/content/articles/<slug>.md` with full frontmatter and body.

### 2. Create explanatory figures where useful

Create a diagram, screenshot, chart, or other figure under `static/img/articles/<slug>/` when it clarifies the article. The SVG style above applies only to new SVG diagrams.

### 3. Update frontmatter with image references

Add `image`, `image_alt`, `image_credit`, `image_source`, `row_image`, and diagram references.

### 4. Release only when requested

The following branch, PR, merge, and deployment steps apply only when the user has asked to publish or deploy. Inspect current branch and dirty state first; do not run `git checkout main` or `git pull` over unrelated work. Use the repo's current release process if it differs from this example.

#### Commit and push to a branch

```powershell
cd "<AI_WIKI_ROOT>/07_Projects/blog.ryanspice.com"
git checkout main
git pull
git checkout -b blog/<slug>
git add src/lib/content/articles/<slug>.md static/img/articles/<slug>/
git commit -m "feat: <article title>"
git push -u origin blog/<slug>
```

### 5. Create PR to main

```powershell
gh pr create --title "feat: <article title>" --body "..." --base main
```

### 6. Merge PR

```powershell
gh pr merge <number> --merge
```

### 7. Create PR from main to production

```powershell
gh pr create --title "Deploy: <article title>" --body "..." --base production --head main
gh pr merge <number> --merge
```

### 8. Verify deployment

Watch the deploy workflow:

```powershell
gh run list --branch production --limit 1 --json databaseId --jq '.[0].databaseId'
gh run watch <id> --exit-status
```

Verify both sites:
- `https://blog.ryanspice.com/<year>/<month>/<day>/<slug>/`
- `https://blog.canopydigital.ca/<year>/<month>/<day>/<slug>/`

## CI fix: Playwright for mermaid tests

If mermaid tests fail in CI, add this step to `.github/workflows/test-blog.yml`:

```yaml
- name: Install Playwright browsers
  run: pnpm exec playwright install chromium --with-deps
```

## Common issues

### 404 on article

- Check `status: "published"` (not `"draft"`)
- Check the URL includes the date path: `/<year>/<month>/<day>/<slug>/`
- Verify deploy workflow completed successfully

### CI test failures

- Mermaid tests need Playwright chromium installed in CI
- Node.js 20 deprecation warning is cosmetic — tests still pass

### Images not showing

- Verify SVG files are in `static/img/articles/<slug>/`
- Check frontmatter `image` path starts with `/img/articles/`
- Ensure SVG has proper `xmlns` attribute

## Verification

After publishing:

```powershell
# Check both sites are live
Invoke-WebRequest -Uri "https://blog.ryanspice.com/<year>/<month>/<day>/<slug>/" -UseBasicParsing | Select-Object StatusCode
Invoke-WebRequest -Uri "https://blog.canopydigital.ca/<year>/<month>/<day>/<slug>/" -UseBasicParsing | Select-Object StatusCode
```

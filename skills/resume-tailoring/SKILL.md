---
name: resume-tailoring
description: Tailor resumes from career.json for specific job postings.
version: 1.0.0
author: Ryan Spice-Finnie (ryanspice), Hermes Agent
license: MIT
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [resume, career, jobs, applications, tailoring]
    related_skills: [seo-live-audit]
---

# Resume Tailoring Skill

Generate job-specific resumes from the canonical career data, preserving fidelity rules while emphasizing the most relevant evidence for each posting.

## When to Use

- Creating a tailored resume for a specific job posting
- Batch-generating resumes for a queue of jobs
- Reviewing job fit against career evidence
- Auditing resume content for claim fidelity

Don't use for: rewriting career history, inventing experience, or generating cover letters (separate workflow).

## Prerequisites

- `content/career.json` — single source of truth for all career data
- `documents/Ryan-Spice-Finnie-CV.html` — full 4-page CV (source for evidence)
- `documents/Ryan-Spice-Finnie-Resume.html` — 2-page compact resume (base template)
- Job posting URL or description text

## How to Run

### Single job tailoring

```python
# 1. Extract requirements from job posting
# 2. Map requirements to career.json evidence
# 3. Generate tailored HTML from base template
# 4. Deploy to documents/ directory
```

### Batch tailoring

```python
# 1. Read job queue CSV
# 2. For each job: extract requirements, map evidence, generate HTML
# 3. Write all tailored resumes to documents/
# 4. Deploy all at once
```

## Procedure

### 1. Extract job requirements

Read the job posting (via `web_extract` or browser). Identify:
- **Must-have**: years of experience, specific technologies, role type
- **Nice-to-have**: domain experience, certifications, specific tools
- **Stack**: primary languages, frameworks, testing tools, infrastructure
- **Role type**: frontend, full-stack, backend, platform, lead

### 2. Map to career.json evidence

For each requirement, find the strongest evidence:

| Requirement type | Where to look |
|-----------------|---------------|
| Technology years | Count roles using that technology across career |
| Leadership | ADESA (cross-team adoption), Indegene (hired/led devs), Canopy (principal) |
| Specific framework | Match to role environments and bullets |
| Testing | Manulife (Storybook), OCS (Storybook), ADESA (Mocha/Chai), Canopy (Vitest) |
| Cloud/infra | Canopy (Azure), AutoTrader (Azure SWA), Indegene (Azure/.NET) |
| AI tooling | Canopy (MCP, Fugu, harnesses) — only if job mentions AI/agentic |
| Accessibility | OCS (AODA/WCAG), Manulife (AODA), Canopy (accessible delivery) |
| Payments/commerce | Canopy (Stripe, Moneris), OCS (Shopify) |

### 3. Generate tailored HTML

Start from the base compact resume template. Adjust:

**Title line**: Match the job's title when truthful. "Senior Frontend Engineer" for frontend roles, "Senior Software Engineer" for full-stack, "Senior Full Stack Engineer" for backend-leaning.

**Tagline**: Lead with the technologies the job emphasizes. React/TypeScript for React roles, Angular for Angular roles, etc.

**Profile paragraph**: Rewrite to lead with the most relevant experience. Keep it to2-3 sentences.

**Technical capabilities**: Reorder to lead with the job's stack. Add missing technologies only if genuinely used.

**Experience bullets**: 
- Promote the most relevant roles to full bullets
- Compress less relevant roles to "Additional experience" line
- Use `compact_bullets` from career.json for compressed roles
- Use full `bullets` for promoted roles

**Additional experience**: Include roles that demonstrate breadth but aren't the primary evidence.

### 4. Fidelity rules (NEVER violate)

- AutoTrader Angular 19 prerelease SSR — keep distinct from ADESA SSR
- ADESA reverse-engineered Java OAuth — keep "reverse-engineered", not "integrated"
- Azure since 2024 — don't inflate to3 continuous years
- .NET exposure — don't invent C# depth
- Indegene Azure/.NET — calibrated as environment, not ownership
- Tracer 6-month build — don't invent contract months
- Three.js/PixiJS — independent work, not production game engine
- Fugu local ≠ Fusion public — keep distinct
- Education C++ — not commercial game tenure
- No stocked/inventoried shop claim for Shopify demo
- No unproved Canadian data-residency guarantee

### 5. Deploy

```bash
/c/Windows/System32/OpenSSH/scp.exe -i ~/.ssh/id_ed25519_ryanspice \
  documents/Ryan-Spice-Finnie-Resume-{COMPANY}.html \
  rspice@ryanspice.com:/home/rspice/domains/ryanspice.com/public_html/documents/
```

## Template structure

```html
<!doctype html>
<html lang="en">
<head>
  <!-- Same meta/CSS as base compact resume -->
  <title>Ryan Spice-Finnie | {Job Title} — {Company} Application</title>
  <meta name="description" content="{Tailored description}">
</head>
<body>
  <nav><!-- Portfolio | Generic resume | Full CV --></nav>
  <main>
    <h1>Ryan Spice-Finnie</h1>
    <p><b>{Job Title}</b></p>
    <p>{Technology1} · {Technology2} · {Key Skill1} · {Key Skill2}</p>
    <p>contact | phone</p>
    <p>portfolio | linkedin | github | writing</p>
    <p>location | availability</p>
    
    <h2>Professional profile</h2>
    <p>{2-3 sentences, led with most relevant experience}</p>
    
    <h2>Technical capabilities</h2>
    <p><b>{Category1}:</b> {skills led by job's stack}</p>
    <p><b>{Category2}:</b> {next most relevant}</p>
    <p><b>{Category3}:</b> {testing/quality}</p>
    <p><b>{Category4}:</b> {cloud/infra if relevant}</p>
    
    <h2>Recent experience</h2>
    <!-- Full bullets for promoted roles -->
    
    <h2>Professional experience continued</h2>
    <!-- Compressed roles -->
    
    <p><b>Additional experience:</b> {one-line summary of older roles}</p>
    
    <h2>Education and independent work</h2>
    <p>{Education}</p>
    <p>{Recent independent work, led by relevant projects}</p>
  </main>
</body>
</html>
```

## Pitfalls

- **Don't over-tailor.** If the compact resume already covers80%+ of requirements, use it as-is. Over-tailoring creates maintenance burden and risks inconsistencies.
- **Don't reorder chronology.** Keep reverse-chronological order. Promoting a role means giving it more bullets, not moving it above newer roles.
- **Don't invent technologies.** If the job asks for Kubernetes and you've never used it, don't add it. Address the gap in a cover letter or skip the application.
- **Don't duplicate SSR.** ADESA SSR and AutoTrader SSR are distinct evidence. Don't merge them into one claim.
- **Don't confuse Fugu and Fusion.** Fugu is local orchestration. Fusion is the public Canopy workspace. Keep them distinct.
- **Watch the page count.** The compact resume should stay at2 pages. If tailoring pushes it to3, compress older roles further.

## Verification

Before deploying a tailored resume:
1. Every claim traceable to career.json or confirmed user evidence
2. No technologies added that aren't in career.json environments
3. Chronological order preserved
4. Page count matches target (2 for compact, 4 for CV)
5. Contact info is correct (contact@ryanspice.com, exact LinkedIn URL)
6. Title is truthful (don't claim "Staff" if the role was "Senior")

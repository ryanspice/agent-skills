---
name: seo-live-audit
description: Run SEO audits against live sites, write regression tests, and fix common score drags.
version: 1.1.0
author: Ryan Spice-Finnie (ryanspice), Hermes Agent
license: MIT
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [seo, audit, testing, deployment, headers, html]
    related_skills: []
---

# SEO Live Audit Skill

Run the `seo_audit` Python tool against a live deployment, write regression tests that enforce minimum scores and issue boundaries, and apply the fixes that move the needle most.

## When to Use

- Auditing a live site's SEO score and fixing issues
- Writing regression tests that prevent SEO score regressions
- Deploying security headers (HSTS, CSP, X-Frame-Options)
- Adding missing meta tags, canonical URLs, favicons, and landmarks to HTML documents

Don't use for: keyword research, backlink analysis, or traffic estimation — the tool doesn't do those.

## Prerequisites

- `seo_audit` Python tool installed at `B:\Dev\seo_audit_python` (or equivalent)
- Python 3.11+ with `pymupdf`, `pytest` installed in the seo_audit venv
- SSH access to the target server (for deploying fixes)
- The site's HTML source files in the local repo

## Quick Reference

```bash
# Run a homepage-only audit (default — scope to base page)
cd B:\Dev\seo_audit_python
.venv\Scripts\python.exe -m seo_audit https://example.com --match "/" --max-pages 1 --no-render --no-knowledge-compiler --audit-environment production --out ./report

# Run a full-site audit (all linked pages)
.venv\Scripts\python.exe -m seo_audit https://example.com --max-pages 25 --no-render --no-knowledge-compiler --audit-environment production --out ./report

# Run SEO regression tests
.venv\Scripts\python.exe -m pytest path\to\test_seo_live.py -v

# Check current scores from latest report
python -c "import json,glob; d=json.load(open(sorted(glob.glob('report/*/report.json'))[-1])); print(d['site_score'], d['category_scores'])"
```

## Procedure

### 1. Run the audit and read the report

Run the audit against the live site. **Default to `--match "/" --max-pages 1`** to scope to the base page — subpages (CV, Resume, legacy pages) drag the score down with issues that don't reflect the primary landing page. Use `--max-pages 25` only when explicitly auditing the full site.

Use `--no-render` for speed unless you need rendered checks. Use `--audit-environment production` so local-only findings don't inflate the score.

Read `report.json` from the output directory. Key fields:
- `site_score` — overall 0-100 score
- `grade` — letter grade (A/B/C/D/F)
- `category_scores` — per-category scores (seo, security, page_quality, content, etc.)
- `issues` — list of findings with `title`, `severity`, `category`, `affected_urls`, `suppressed_by_default`, `environment_scope`

### 2. Identify the biggest score drags

Sort issues by severity (critical > high > medium > low > info). Cross-reference with category scores. The biggest drags are usually:

| Category | Common issues | Fix |
|----------|--------------|-----|
| **seo** (often lowest) | Missing canonical, meta desc, H1, JSON-LD, favicon | Add tags to HTML `<head>` |
| **security** | Missing HSTS, CSP, X-Frame-Options, Permissions-Policy | Add headers to `.htaccess` |
| **page_quality** | Weak canonical signals, duplicate content, thin pages | Add noindex to legacy pages |
| **content** | No H1, thin text, weak title/H1 alignment | Add H1, improve content |
| **social** | Incomplete OG, missing Twitter cards | Add OG/Twitter meta tags |

### 3. Fix security headers in .htaccess

Add these headers to the server's `.htaccess` (inside `<IfModule mod_headers.c>`):

```apache
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains" env=HTTPS
Header always set X-Content-Type-Options "nosniff"
Header always set Referrer-Policy "strict-origin-when-cross-origin"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set Permissions-Policy "camera=(), microphone=(), geolocation=()"
Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://fonts.googleapis.com https://images.unsplash.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https://images.unsplash.com; font-src 'self' https://fonts.gstatic.com; connect-src 'self'; frame-ancestors 'self'"
```

CSP must be tuned per-site — `unsafe-inline` and `unsafe-eval` are needed for sites with inline CSS/JS. Remove them if the site uses only external scripts.

### 4. Fix HTML meta tags

For every page the audit crawls, ensure:

```html
<head>
  <title>Descriptive Title | Site Name</title>
  <meta name="description" content="120-160 character description with keywords.">
  <meta name="robots" content="index,follow">  <!-- or noindex,follow for legacy pages -->
  <link rel="canonical" href="https://example.com/page">
  <link rel="icon" href="data:image/svg+xml,...">  <!-- inline SVG or /favicon.ico -->
  <meta property="og:title" content="Page Title">
  <meta property="og:description" content="Description for social sharing.">
  <meta property="og:url" content="https://example.com/page">
  <meta property="og:image" content="https://example.com/social-card.png">
  <meta property="og:site_name" content="Site Name">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Page Title">
  <meta name="twitter:description" content="Description for Twitter.">
  <meta name="twitter:image" content="https://example.com/social-card.png">
  <script type="application/ld+json">{"@context":"https://schema.org","@type":"ProfilePage","mainEntity":{"@type":"Person","name":"Name","jobTitle":"Title"}}</script>
</head>
```

For legacy/retired pages that shouldn't be indexed:
- Add `<meta name="robots" content="noindex,follow">`
- Add `<link rel="canonical" href="https://example.com/">` pointing to the homepage
- Add a descriptive `<title>` and `<meta name="description">`
- Add an `<h1>` (even if visually hidden: `style="position:absolute;left:-9999px"`)

### 5. Add semantic landmarks

The audit checks for `<nav>`, `<main>`, `<header>`, `<footer>` landmarks. For document pages (CV, resume, etc.):

```html
<body>
  <nav aria-label="Document navigation">...</nav>
  <main>
    <h1>Page Title</h1>
    <!-- content -->
  </main>
  <footer><p><a href="/">site.com</a></p></footer>
</body>
```

### 6. Write regression tests

Create `tests/test_seo_live.py` scoped to the base page. Use `--match "/" --max-pages 1` to avoid subpage noise:

```python
"""Live-deployment SEO regression tests for the homepage."""
import json, subprocess, tempfile, unittest
from pathlib import Path

LIVE_URL = "https://example.com"
SEO_AUDIT_DIR = Path(r"B:\Dev\seo_audit_python")
PYTHON = SEO_AUDIT_DIR / ".venv" / "Scripts" / "python.exe"

SCORE_FLOORS = {
    "seo": 85, "security": 95, "page_quality": 90,
    "accessibility": 95, "content": 85, "crawl": 95,
    "analytics": 65, "ux": 95, "quality": 95, "social": 95,
}

BANNED_ISSUE_TITLES = [
    "Missing canonical tag", "Missing meta description",
    "Missing HSTS header", "Missing X-Content-Type-Options header",
    "Missing Referrer-Policy header", "No H1 found",
    "Duplicate page titles", "WWW and non-WWW hosts are both reachable",
    "Missing favicon link", "Missing Twitter card metadata",
    "No JSON-LD structured data found", "Open Graph metadata incomplete",
]

def _run_homepage_audit():
    with tempfile.TemporaryDirectory(prefix="seo-homepage-") as out:
        cmd = [str(PYTHON), "-m", "seo_audit", LIVE_URL,
               "--match", "/", "--max-pages", "1", "--no-render",
               "--no-knowledge-compiler", "--audit-environment", "production",
               "--out", out]
        result = subprocess.run(cmd, capture_output=True, text=True,
                                timeout=60, cwd=str(SEO_AUDIT_DIR))
        if result.returncode != 0:
            raise RuntimeError(f"seo_audit failed: {result.stderr[-500:]}")
        reports = list(Path(out).rglob("report.json"))
        with open(reports[0]) as f:
            return json.load(f)

class HomepageSEOScores(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.report = _run_homepage_audit()
        cls.scores = cls.report.get("category_scores", {})
        cls.site_score = cls.report.get("site_score")

    def test_site_score_is_a(self):
        self.assertIsNotNone(self.site_score)
        self.assertGreaterEqual(self.site_score, 90)

    def test_category_score_floors(self):
        for category, floor in SCORE_FLOORS.items():
            actual = self.scores.get(category)
            if actual is None:
                continue
            with self.subTest(category=category):
                self.assertGreaterEqual(actual, floor)

class HomepageSEOIssues(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.report = _run_homepage_audit()
        cls.issues = cls.report.get("issues", [])

    def _issues_by_title(self, title):
        return [i for i in self.issues if i.get("title") == title]

    def test_banned_issues_absent(self):
        for title in BANNED_ISSUE_TITLES:
            found = self._issues_by_title(title)
            with self.subTest(issue=title):
                self.assertEqual(len(found), 0)

    def test_no_critical_or_high_issues(self):
        bad = [i for i in self.issues if i.get("severity") in ("critical", "high")]
        self.assertEqual(len(bad), 0)

    def test_security_headers_present(self):
        security_issues = {i["title"] for i in self.issues if i.get("category") == "security"}
        self.assertEqual({"Missing HSTS header", "Missing X-Content-Type-Options header", "Missing Referrer-Policy header"} & security_issues, set())

    def test_structured_data_present(self):
        self.assertEqual({i["title"] for i in self.issues if "JSON-LD" in i.get("title", "")}, set())

    def test_social_metadata_complete(self):
        self.assertEqual({i["title"] for i in self.issues if i.get("category") == "social"}, set())

class HomepageSEOStructure(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.report = _run_homepage_audit()
        cls.pages = cls.report.get("pages", [])

    def test_homepage_returns_200(self):
        self.assertEqual(self.pages[0].get("status_code"), 200)

    def test_homepage_uses_https_no_www(self):
        url = self.pages[0].get("url", "")
        self.assertTrue(url.startswith("https://"))
        self.assertNotIn("://www.", url)
```

### 7. Deploy and verify

Deploy fixes via SSH (use Windows native SSH, not Git Bash):

```bash
/c/Windows/System32/OpenSSH/scp.exe -i ~/.ssh/key user@server:/path/ file
/c/Windows/System32/OpenSSH/ssh.exe -i ~/.ssh/key user@server 'command'
```

After deploying, verify headers:
```bash
curl -sI https://example.com/ | grep -i "strict-transport\|content-security\|x-frame"
```

Re-run the tests to confirm all pass.

## Pitfalls

- **Git Bash SSH gets connection-reset from some servers.** Use `/c/Windows/System32/OpenSSH/ssh.exe` on Windows — Git Bash SSH negotiates differently and some servers reject it at the TCP level.
- **`ServerTokens Prod` cannot go in `.htaccess`.** It's a server-level Apache directive — placing it in `.htaccess` causes a500 Internal Server Error. Use `ServerSignature Off` in `.htaccess` instead, or set `ServerTokens` in the main Apache config.
- **`report.json` is in a timestamped subdirectory.** Use `glob` to find the latest one.
- **CSP `unsafe-inline` is needed for sites with inline CSS/JS.** Don't remove it without testing — most portfolio sites use inline styles and scripts.
- **Legacy pages drag scores down hard.** Add noindex + canonical + meta desc + H1 to them, but expect page_quality to drop (noindex pages score lower by design).
- **Scope to the base page by default.** Use `--match "/" --max-pages 1` for homepage-focused audits. Subpages (CV, Resume, legacy) have different issues that don't reflect the primary landing page quality.
- **Score floors should be set to actual achievable values,** not aspirational ones. Run the audit first, fix what you can, then set floors at or just below the achieved scores.
- **The `--match` flag uses URL path patterns.** `--match "/"` matches only the homepage. `--match "/documents/*"` would match document pages.

## Verification

After all fixes are deployed:
1. Run `test_seo_live.py` — all tests should pass
2. Check `curl -sI` for HSTS, CSP, X-Frame-Options, Permissions-Policy headers
3. Homepage score should be90+ (A grade)

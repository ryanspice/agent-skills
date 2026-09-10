"""Live-deployment SEO regression tests for ryanspice.com homepage.

Audits only the base page (ryanspice.com/) to verify the primary landing
page scores as high as possible. Subpages (CV, Resume, /home/) are excluded.

Run locally against the live site:
    cd B:\\Dev\\seo_audit_python
    .\\.venv\\Scripts\\python.exe -m pytest B:\\Dev\\new.ryanspice.com\\tests\\test_seo_live.py -v
"""
from __future__ import annotations

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

LIVE_URL = "https://ryanspice.com"
SEO_AUDIT_DIR = Path(r"B:\Dev\seo_audit_python")
PYTHON = SEO_AUDIT_DIR / ".venv" / "Scripts" / "python.exe"

# Minimum acceptable scores for the homepage (0-100).
SCORE_FLOORS = {
    "seo": 85,
    "security": 95,
    "page_quality": 90,
    "accessibility": 95,
    "content": 85,
    "crawl": 95,
    "analytics": 65,
    "ux": 95,
    "quality": 95,
    "social": 95,
}

# Issues that must NOT appear on the homepage.
BANNED_ISSUE_TITLES = [
    "Missing canonical tag",
    "Missing meta description",
    "Missing HSTS header",
    "Missing X-Content-Type-Options header",
    "Missing Referrer-Policy header",
    "No H1 found",
    "Duplicate page titles",
    "WWW and non-WWW hosts are both reachable",
    "Missing favicon link",
    "Missing Twitter card metadata",
    "No JSON-LD structured data found",
    "Open Graph metadata incomplete",
]


def _run_homepage_audit():
    """Run seo_audit on just the homepage and return parsed report.json."""
    if not PYTHON.exists():
        raise unittest.SkipTest(f"SEO audit venv not found at {PYTHON}")

    with tempfile.TemporaryDirectory(prefix="seo-homepage-") as out:
        cmd = [
            str(PYTHON), "-m", "seo_audit", LIVE_URL,
            "--match", "/",
            "--max-pages", "1",
            "--no-render",
            "--no-knowledge-compiler",
            "--audit-environment", "production",
            "--out", out,
        ]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=60,
            cwd=str(SEO_AUDIT_DIR),
        )
        if result.returncode != 0:
            raise RuntimeError(
                f"seo_audit failed (exit {result.returncode}):\n"
                f"stdout: {result.stdout[-500:]}\n"
                f"stderr: {result.stderr[-500:]}"
            )

        out_path = Path(out)
        reports = list(out_path.rglob("report.json"))
        if not reports:
            raise RuntimeError(f"No report.json found in {out}")
        with open(reports[0]) as f:
            return json.load(f)


class HomepageSEOScores(unittest.TestCase):
    """Assert minimum SEO audit scores on the live homepage."""

    @classmethod
    def setUpClass(cls):
        cls.report = _run_homepage_audit()
        cls.scores = cls.report.get("category_scores", {})
        cls.site_score = cls.report.get("site_score")

    def test_site_score_is_a(self):
        self.assertIsNotNone(self.site_score, "site_score is None")
        self.assertGreaterEqual(self.site_score, 90,
            f"Site score {self.site_score} is below A threshold (90)")

    def test_category_score_floors(self):
        for category, floor in SCORE_FLOORS.items():
            actual = self.scores.get(category)
            if actual is None:
                continue  # unmeasured, skip
            with self.subTest(category=category):
                self.assertGreaterEqual(actual, floor,
                    f"{category} score {actual} is below floor {floor}")


class HomepageSEOIssues(unittest.TestCase):
    """Assert specific issues are absent on the live homepage."""

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
                self.assertEqual(len(found), 0,
                    f"Banned issue '{title}' found")

    def test_no_critical_or_high_issues(self):
        bad = [i for i in self.issues
               if i.get("severity") in ("critical", "high")]
        self.assertEqual(len(bad), 0,
            f"Critical/high issues: {[i['title'] for i in bad]}")

    def test_security_headers_present(self):
        security_issues = {i["title"] for i in self.issues
                          if i.get("category") == "security"}
        must_absent = {
            "Missing HSTS header",
            "Missing X-Content-Type-Options header",
            "Missing Referrer-Policy header",
        }
        found = must_absent & security_issues
        self.assertEqual(found, set(),
            f"Required security headers missing: {found}")

    def test_structured_data_present(self):
        schema_issues = {i["title"] for i in self.issues
                        if "JSON-LD" in i.get("title", "")}
        self.assertEqual(schema_issues, set(),
            f"Structured data issues: {schema_issues}")

    def test_social_metadata_complete(self):
        social_issues = {i["title"] for i in self.issues
                        if i.get("category") == "social"}
        self.assertEqual(social_issues, set(),
            f"Social metadata issues: {social_issues}")


class HomepageSEOStructure(unittest.TestCase):
    """Assert structural properties of the live homepage."""

    @classmethod
    def setUpClass(cls):
        cls.report = _run_homepage_audit()
        cls.pages = cls.report.get("pages", [])

    def test_homepage_returns_200(self):
        self.assertEqual(len(self.pages), 1)
        page = self.pages[0]
        self.assertEqual(page.get("status_code"), 200,
            f"Homepage returned {page.get('status_code')}")

    def test_homepage_uses_https(self):
        url = self.pages[0].get("url", "")
        self.assertTrue(url.startswith("https://"),
            f"Homepage URL not HTTPS: {url}")

    def test_homepage_no_www(self):
        url = self.pages[0].get("url", "")
        self.assertNotIn("://www.", url,
            f"Homepage URL uses www: {url}")


if __name__ == "__main__":
    unittest.main()

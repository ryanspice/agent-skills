"""Live-deployment SEO regression tests for ryanspice.com.

Runs the seo_audit tool against the live site and asserts minimum scores
and specific issue boundaries. These tests hit the real production server.

Designed to run locally (not in CI) against the deployed site:
    cd B:\\Dev\\seo_audit_python
    .\\.venv\\Scripts\\python.exe -m pytest B:\\Dev\\new.ryanspice.com\\tests\\test_seo_live.py -v

Or with the seo_audit venv:
    cd B:\\Dev\\seo_audit_python
    .\\.venv\\Scripts\\python.exe -m pytest ..\\new.ryanspice.com\\tests\\test_seo_live.py -v
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

LIVE_URL = "https://ryanspice.com"
SEO_AUDIT_DIR = Path(r"B:\Dev\seo_audit_python")
PYTHON = SEO_AUDIT_DIR / ".venv" / "Scripts" / "python.exe"

# Minimum acceptable scores (0-100). Raise these as issues are fixed.
SCORE_FLOORS = {
    "seo": 50,
    "security": 50,
    "page_quality": 35,
    "accessibility": 95,
    "content": 80,
    "crawl": 90,
    "analytics": 70,
    "rendering": 90,
    "ux": 95,
    "quality": 95,
    "social": 80,
}

# Issues that must NOT appear in the live deployment.
BANNED_ISSUE_TITLES = [
    "Missing canonical tag",
    "Missing meta description",
    "Duplicate page titles",
    "No H1 found",
    "WWW and non-WWW hosts are both reachable",
]

# Issues that must not exceed a page count threshold.
ISSUE_PAGE_CAPS = {
    "Missing Content-Security-Policy header": 0,
    "Missing HSTS header": 0,
    "Missing X-Content-Type-Options header": 0,
    "Missing Referrer-Policy header": 0,
    "Title length looks weak": 1,
    "Meta description length looks weak": 2,
    "Sparse semantic landmark tags": 1,
    "Missing favicon link": 0,
}


def _run_audit():
    """Run seo_audit against the live site and return parsed report.json."""
    if not PYTHON.exists():
        raise unittest.SkipTest(f"SEO audit venv not found at {PYTHON}")

    with tempfile.TemporaryDirectory(prefix="seo-live-test-") as out:
        cmd = [
            str(PYTHON), "-m", "seo_audit", LIVE_URL,
            "--max-pages", "25",
            "--no-render",
            "--no-knowledge-compiler",
            "--audit-environment", "production",
            "--out", out,
        ]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=120,
            cwd=str(SEO_AUDIT_DIR),
        )
        if result.returncode != 0:
            raise RuntimeError(
                f"seo_audit failed (exit {result.returncode}):\n"
                f"stdout: {result.stdout[-500:]}\n"
                f"stderr: {result.stderr[-500:]}"
            )

        # Find the report.json in the output
        out_path = Path(out)
        reports = list(out_path.rglob("report.json"))
        if not reports:
            raise RuntimeError(f"No report.json found in {out}")
        with open(reports[0]) as f:
            return json.load(f)


class LiveSEOScores(unittest.TestCase):
    """Assert minimum SEO audit scores on the live deployment."""

    @classmethod
    def setUpClass(cls):
        cls.report = _run_audit()
        cls.scores = cls.report.get("category_scores", {})
        cls.issues = cls.report.get("issues", [])
        cls.site_score = cls.report.get("site_score")

    def test_site_score_above_minimum(self):
        self.assertIsNotNone(self.site_score, "site_score is None — no measured data")
        self.assertGreaterEqual(self.site_score, 65,
            f"Site score {self.site_score} is below minimum 65")

    def test_category_score_floors(self):
        for category, floor in SCORE_FLOORS.items():
            actual = self.scores.get(category)
            if actual is None:
                continue  # unmeasured category, skip
            with self.subTest(category=category):
                self.assertGreaterEqual(actual, floor,
                    f"{category} score {actual} is below floor {floor}")


class LiveSEOIssues(unittest.TestCase):
    """Assert specific issues are absent or bounded on the live deployment."""

    @classmethod
    def setUpClass(cls):
        cls.report = _run_audit()
        cls.issues = cls.report.get("issues", [])

    def _issues_by_title(self, title):
        return [i for i in self.issues if i.get("title") == title]

    def test_banned_issues_absent(self):
        for title in BANNED_ISSUE_TITLES:
            found = self._issues_by_title(title)
            with self.subTest(issue=title):
                self.assertEqual(len(found), 0,
                    f"Banned issue '{title}' found affecting "
                    f"{found[0].get('affected_urls', []) if found else ''}")

    def test_issue_page_caps(self):
        for title, cap in ISSUE_PAGE_CAPS.items():
            found = self._issues_by_title(title)
            with self.subTest(issue=title):
                if found:
                    affected = len(found[0].get("affected_urls", []))
                    self.assertLessEqual(affected, cap,
                        f"Issue '{title}' affects {affected} pages (cap: {cap})")

    def test_no_critical_issues(self):
        critical = [i for i in self.issues if i.get("severity") == "critical"]
        self.assertEqual(len(critical), 0,
            f"Critical issues found: {[i['title'] for i in critical]}")

    def test_security_headers_present(self):
        """The live site must serve HSTS, X-Content-Type-Options, and Referrer-Policy."""
        security_issues = {i["title"] for i in self.issues if i.get("category") == "security"}
        must_absent = {
            "Missing HSTS header",
            "Missing X-Content-Type-Options header",
            "Missing Referrer-Policy header",
        }
        found = must_absent & security_issues
        self.assertEqual(found, set(),
            f"Required security headers missing: {found}")


class LiveSEOStructure(unittest.TestCase):
    """Assert structural SEO elements on the live homepage."""

    @classmethod
    def setUpClass(cls):
        cls.report = _run_audit()
        cls.pages = cls.report.get("pages", [])

    def test_all_pages_return_200(self):
        for page in self.pages:
            if page.get("error"):
                self.fail(f"Page error: {page['url']} — {page['error']}")
            with self.subTest(url=page.get("url", "?")):
                self.assertEqual(page.get("status_code"), 200,
                    f"{page.get('url')} returned {page.get('status_code')}")

    def test_canonical_urls_use_https_and_no_www(self):
        for page in self.pages:
            url = page.get("url", "")
            with self.subTest(url=url):
                self.assertTrue(url.startswith("https://"),
                    f"Page URL not HTTPS: {url}")
                self.assertNotIn("://www.", url,
                    f"Page URL uses www: {url}")


if __name__ == "__main__":
    unittest.main()

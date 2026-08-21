# Social preview platform notes

Read this reference when implementing metadata, diagnosing Meta, Facebook, or Messenger, or deciding whether a remaining failure is source, transport, cache, or app UI.

## Baseline metadata

Open Graph defines `og:title`, `og:type`, `og:image`, and `og:url` as the basic properties. For a share image, also provide `og:image:secure_url`, `og:image:type`, `og:image:width`, `og:image:height`, and `og:image:alt` immediately after the root `og:image` declaration.

```html
<link rel="canonical" href="https://example.com/page/" />
<meta property="og:type" content="website" />
<meta property="og:url" content="https://example.com/page/" />
<meta property="og:title" content="Page title" />
<meta property="og:description" content="Short, accurate description." />
<meta property="og:image" content="https://example.com/social/page-v2.png" />
<meta property="og:image:secure_url" content="https://example.com/social/page-v2.png" />
<meta property="og:image:type" content="image/png" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:image:alt" content="A concise description of the image" />
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="Page title" />
<meta name="twitter:description" content="Short, accurate description." />
<meta name="twitter:image" content="https://example.com/social/page-v2.png" />
<meta name="twitter:image:alt" content="A concise description of the image" />
```

Keep the first `og:image` internally consistent with its structured properties. Some consumers prefer the first image when multiple images are declared.

## Share image guidance

- Prefer a dedicated 1200 by 630 PNG or JPEG. Do not assume an SVG, portrait hero, or CSS-composited image will become a large card consistently.
- Preserve the focal subject within a centre-safe area and inspect the asset at thumbnail size.
- Keep text large and sparse when text is necessary. The page title and description already provide text outside the image.
- Match declared MIME type and dimensions to the bytes returned by the public server.
- Use a new stable filename such as `article-v3.png` when changing the image. Query strings are less reliable as durable cache keys across platforms.

## Meta, Facebook, and Messenger

Meta documents `facebookexternalhit` as the crawler that reads content shared on Meta apps, including Facebook, Instagram, and Messenger. The iOS Messenger app therefore does not need a separate iOS-only Open Graph implementation; Meta's backend crawler normally creates the unfurl.

Test the page and image with this user agent:

```text
facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)
```

Check the final response after redirects, not only a browser HEAD request. Some hosts, CDNs, and WAFs treat crawler user agents, compressed responses, or range requests differently.

When the live response is correct but Facebook or Messenger remains stale:

1. Open Meta's Sharing Debugger.
2. Submit the exact canonical URL.
3. Request a new scrape.
4. Send the exact URL as a fresh standalone message and allow the preview to load before sending.
5. Prefer a new conversation for the cleanest cache test.

Do not describe this as an iOS bug until the crawler response, debugger scrape, and a fresh iOS share have been separated as evidence.

## Robots and indexing

An HTML `noindex` directive controls search indexing and does not, by itself, prove that a social unfurl must fail. Still inspect `robots.txt`, HTML robots meta, `X-Robots-Tag`, CDN rules, and image responses because platform crawlers and hosting stacks may apply them differently.

Treat crawler-visible `noimageindex`, broad blocking headers, denied user agents, or inaccessible image assets as compatibility risks. Change privacy or indexing policy only with explicit product intent; do not remove protections merely to satisfy a card preview.

## Authoritative references

- Open Graph protocol: https://ogp.me/
- Meta web crawlers: https://developers.facebook.com/docs/sharing/webmasters/web-crawlers/
- Meta Sharing Debugger: https://developers.facebook.com/tools/debug/
- X card markup: https://developer.x.com/en/docs/x-for-websites/cards/overview/markup

Platform behavior changes. Recheck these primary sources when exact crawler names, size limits, or debugger behavior matters.

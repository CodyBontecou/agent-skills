---
name: ugc-screenshots
description: Take Instagram-ready mobile screenshots of any live website. Auto-discovers page sections and captures each one at 9:16 (Stories/Reels) or 4:5 (Feed) ratio. Accepts full URLs or ugc.community subdomains. Use when the user wants mobile screenshots, social media assets, or IG content from any site.
---

# UGC Screenshots

Takes mobile screenshots of any live website for Instagram content. Auto-discovers sections by scanning `<h2>` headings, detects sticky/fixed headers, positions each heading below the header with breathing room, and captures at Instagram-native ratios.

Works with **any URL** — not limited to ugc.community.

## Repo Path

```
/Users/codybontecou/dev/ugc-screenshots
```

## Setup (one-time)

```bash
cd /Users/codybontecou/dev/ugc-screenshots && npm install
```

## Basic Usage

### Any URL

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://example.com
```

### ugc.community shorthand (subdomain only)

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs amanyadhav
```

A bare word (no `://`) is treated as a ugc.community subdomain → `https://<name>.ugc.community/`.

Screenshots are saved to `<repo>/screenshots/<hostname>/` by default (always inside the ugc-screenshots repo, regardless of cwd).

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--outdir, -o <dir>` | Output directory | `./screenshots/<hostname>` |
| `--ratio <name>` | `story` (1080×1920, 9:16) or `feed` (1080×1350, 4:5) | `story` |
| `--wait <ms>` | Initial page-load wait | `5000` |
| `--scroll-wait <ms>` | Wait per section after scroll | `3000` |
| `--force-counters` | Force scroll-triggered counter animations to final values | off |
| `--fix-brands-grid` | Fix overflowing brand partner grid for mobile | off |
| `--header-offset <px>` | Extra pixels below the detected sticky header | `20` (auto) |
| `--hide-badge` | Hide the ugc.community badge (default) | on |
| `--no-hide-badge` | Keep the ugc.community badge visible | — |
| `--sections <json>` | Provide explicit section definitions instead of auto-discovery | — |

## Common Examples

### Screenshot any live site

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://mysite.com
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://creator.example.io/portfolio
```

### ugc.community portfolio (shorthand)

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs amanyadhav
```

### With counter animation fix and brands grid fix

Use these flags for sites that have animated stat counters (`data-target` attributes) or brand partner grid sections that overflow on mobile:

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://example.com --force-counters --fix-brands-grid
```

### Output to a specific directory

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://example.com -o /path/to/output
```

### Feed ratio (4:5) instead of Stories

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://example.com --ratio feed
```

### Extra header padding (if headings get clipped)

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://example.com --header-offset 40
```

### Explicit section definitions

When auto-discovery doesn't capture what you need, pass sections manually:

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://example.com --sections '[
  {"name": "01-hero", "scrollTo": "top"},
  {"name": "02-work", "heading": "My Work"},
  {"name": "03-stats", "selector": "#stats"},
  {"name": "04-contact", "heading": "Contact"}
]'
```

### Section definition format

Each section object supports:

- `name` — filename stem (required)
- `scrollTo` — `"top"` to scroll to page top
- `heading` — text to match inside an `<h2>` element
- `selector` — CSS selector or `#id` to scroll to

## How It Works

1. Opens the site in a headless Chromium with iPhone viewport (390px wide, 9:16 or 4:5 ratio)
2. Waits for full page load (`networkidle` + configurable wait)
3. Hides the ugc.community badge via CSS injection (if present)
4. Optionally forces counter animations and fixes brand grid overflow
5. Auto-discovers sections by scanning visible `<h2>` elements
6. Detects sticky/fixed headers by scanning all `position: fixed` and `position: sticky` elements near the top of the viewport (falls back to `<nav>`/`<header>` tags), then scrolls each heading below the header with 20px breathing room
7. Captures a PNG screenshot per section
8. Writes a `manifest.json` with metadata for downstream use

## Output

Each run produces:
- One PNG per section: `<name>-<ratio>.png` (e.g., `01-hero-story.png`)
- `manifest.json` with URL, dimensions, and section list

## Notes

- The script uses Playwright with real Chromium — CSS, fonts, images, and JS all render faithfully
- Works with any URL: portfolios, landing pages, marketing sites, personal sites, etc.
- Auto-discovery uses `<h2>` elements; sites using other heading levels may need explicit `--sections`
- For slow-loading sites (SPAs, heavy JS), increase `--wait` and `--scroll-wait`
- The `--force-counters` flag sets `[data-target]` elements to their final values — use it when stats show "0"
- The `--fix-brands-grid` flag forces a 2-column grid layout with proper mobile sizing
- The badge-hiding CSS only applies if the ugc.community badge exists; harmless on other sites
- Header detection scans all `position: fixed/sticky` elements anchored to the top; use `--header-offset` to add extra padding if headings still get clipped (e.g., `--header-offset 40`)

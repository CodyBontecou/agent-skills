# UGC Screenshots

Take Instagram-ready mobile screenshots of any live website. Auto-discovers page sections by scanning `<h2>` headings, detects sticky/fixed headers, and captures each section at 9:16 (Stories/Reels) or 4:5 (Feed) ratio. Works with any URL — not limited to ugc.community.

## Setup

```bash
cd /Users/codybontecou/dev/ugc-screenshots && npm install
```

## Usage

```bash
# Any URL
node screenshot.mjs https://example.com

# ugc.community shorthand
node screenshot.mjs amanyadhav

# Feed ratio instead of story
node screenshot.mjs https://example.com --ratio feed

# Custom output directory
node screenshot.mjs https://example.com -o /path/to/output

# Explicit sections
node screenshot.mjs https://example.com --sections '[
  {"name": "01-hero", "scrollTo": "top"},
  {"name": "02-work", "heading": "My Work"}
]'
```

## Options

| Flag | Default | Description |
|------|---------|-------------|
| `-o <dir>` | `./screenshots/<hostname>` | Output directory |
| `--ratio` | `story` | `story` (1080×1920) or `feed` (1080×1350) |
| `--wait <ms>` | `5000` | Initial page-load wait |
| `--scroll-wait <ms>` | `3000` | Wait per section after scroll |
| `--force-counters` | off | Force animated counters to final values |
| `--fix-brands-grid` | off | Fix overflowing brand grids for mobile |
| `--header-offset <px>` | `20` | Extra pixels below sticky header |
| `--sections <json>` | auto | Explicit section definitions |

## Output

- One PNG per section (e.g., `01-hero-story.png`)
- `manifest.json` with URL, dimensions, and section metadata

See [SKILL.md](./SKILL.md) for full details on auto-discovery, header detection, and section definition format.

# IG Content Generator

Generate Instagram-ready promotional content (stories, feed posts, carousels) from any website, iOS app, or macOS app. Captures screenshots, wraps them in device mockups (iPhone, MacBook), adds marketing headlines, and exports at Instagram-native dimensions.

## Supported Sources

- Live websites (any URL, local dev servers)
- iOS apps (via Simulator)
- macOS apps (via window capture)

## Output Formats

| Ratio | Dimensions | Use Case |
|-------|-----------|----------|
| `story` | 1080×1920 | Instagram Stories, Reels covers |
| `feed` | 1080×1350 | Instagram Feed (portrait 4:5) |
| `square` | 1080×1080 | Instagram Feed (square), Twitter |

## Slide Types

- **`phone`** — iPhone device frame mockup
- **`mac`** — MacBook device frame mockup
- **`raw`** — Full-bleed screenshot
- **`text`** — Text-only slide (intro, CTA, stats)

## Setup

```bash
cd /Users/codybontecou/dev/ig-content && npm install
```

## Quick Start

```bash
# Generate HTML slides from config
node generate.mjs /path/to/config.json -o /path/to/slides.html

# Capture to PNGs
node capture.mjs /path/to/slides.html -o /path/to/output --prefix ig-slide
```

## Config Example

```json
{
  "theme": {
    "accentColor": "#FF6B35",
    "font": "Inter",
    "phoneFrame": "dark"
  },
  "ratio": "story",
  "slides": [
    {
      "type": "text",
      "badge": "NEW APP",
      "headline": "Introducing\n{FocusFlow}",
      "subtitle": "Deep work sessions\nwithout the noise"
    },
    {
      "type": "phone",
      "screenshot": "./screenshots/01-home.png",
      "headline": "Track your\n{focus}",
      "subtitle": "See your productivity patterns"
    }
  ]
}
```

## Scripts

| Script | Purpose |
|--------|---------|
| `generate.mjs` | Config JSON → IG slide HTML |
| `capture.mjs` | Slide HTML → PNGs via Puppeteer |
| `capture-macos.sh` | Capture macOS app window screenshots |

See [SKILL.md](./SKILL.md) for full config schema, theme options, and complete examples for iOS, macOS, and web projects.

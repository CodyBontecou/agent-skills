---
name: ig-carousel
description: Generate designed Instagram carousel slides (4:5 feed ratio) from UGC portfolio sites. Two modes — (1) portfolio showcase carousel from a single site, and (2) before/after comparison carousel showing an old site vs a new redesign. Scrapes data, produces themed HTML, captures each slide as a 1080×1350 PNG. Generates all design variants in one run.
---

# Instagram Carousel Generator

Generates **purpose-built Instagram carousel slides** from UGC portfolio sites. Instead of screenshotting a website (which looks like a screenshot), this produces designed 1080×1350 (4:5) graphics using the portfolio's own fonts, colors, and imagery — composed for Instagram, not the web.

**Two carousel types:**
- **Showcase** — Highlights a single portfolio: cover, stats, work, brands, CTA
- **Comparison** — Before/after redesign: hook, phone mockups side-by-side, deep dives, features, CTA

**Each type generates all design variants** in a single run — no need to pick one up front.

## Repo Path

```
/Users/codybontecou/dev/ig-carousel
```

## Setup (one-time)

```bash
cd /Users/codybontecou/dev/ig-carousel && npm install
```

---

## Design Variants

### Showcase Variants

| Variant | Style | Description |
|---------|-------|-------------|
| `default` | Dark Editorial | Dark backgrounds, accent left-borders on stats, outlined display type. Full-bleed hero cover. |
| `magazine` | Light Print | Cream/white backgrounds, split compositions (text left + image right), serif-heavy, bordered frames, generous whitespace. Feels like a fashion magazine spread. |
| `bold` | Brutalist | Oversized type that bleeds off edges, full-width color-blocked stat bars, thick accent borders, B&W images with accent overlays. Accent-colored CTA slide. |

### Comparison Variants

| Variant | Style | Description |
|---------|-------|-------------|
| `default` | Dark Cinematic | "THE glow UP" hook, side-by-side phone mockups, before/after deep dives, feature card grid. |
| `split` | Geometric | Diagonal split hook (before/after clipped on each side), vertical phone stack, combined split-screen slide, numbered editorial feature list, accent-background CTA. |

---

## Type 1: Portfolio Showcase Carousel

### Workflow: Scrape → Review → Generate All → Review

#### Step 1 — Scrape

```bash
cd /Users/codybontecou/dev/ig-carousel && node scrape.mjs <url-or-subdomain> -o <output-dir>/carousel.json
```

**Input formats:**

| Format | Example |
|--------|---------|
| Full URL | `https://amanyadhav.ugc.community` |
| ugc.community shorthand | `amanyadhav` |
| Local file path | `/path/to/portfolio/index.html` |
| Local directory | `/path/to/portfolio` |

The scraper extracts: creator name/tagline/email/socials, theme colors + fonts from CSS custom properties, hero image, work images, stats, brand partners, content categories, and a full image list (`_allImages`).

#### Step 2 — Review and Edit the JSON

**Critical step.** The scraper gets ~80% right. The agent must fix:

- **Stats**: Deduplicate (hero counters + ring charts + big numbers overlap). Keep 3–5 best. Add missing `suffix` (K+, M+, %) and `label`.
- **Work title**: Format with `\n` for line breaks: `"SPONSORED\nFASHION"`
- **Categories**: Verify images, add stats, keep 2–4 for vertical strips
- **Hero image**: Check `_allImages` for better options
- **Tagline**: Polish for badge display (e.g., "UGC Creator • Toronto")
- **Subtitle**: Trim to max ~2 lines

#### Step 3 — Generate All Variants

```bash
cd /Users/codybontecou/dev/ig-carousel && node generate-all.mjs <path>/carousel.json -o <path>/variants
```

This generates **and captures** every showcase variant in one run. Output:

```
<path>/variants/
├── default/
│   ├── carousel.html
│   └── output/
│       ├── 01-slide-1.png
│       ├── ...
│       └── manifest.json
├── magazine/
│   ├── carousel.html
│   └── output/
└── bold/
    ├── carousel.html
    └── output/
```

#### Step 4 — Review

Visually review the PNGs across all variants. If data needs tweaking, edit the JSON and re-run `generate-all.mjs` — all variants regenerate from the same source.

### Full Showcase Example

```bash
cd /Users/codybontecou/dev/ig-carousel

# 1. Scrape
node scrape.mjs amanyadhav -o /Users/codybontecou/dev/ugc-portfolios/amanyadhav/ig-carousel/carousel.json

# 2. Agent reviews + edits carousel.json

# 3. Generate all variants + capture
node generate-all.mjs /Users/codybontecou/dev/ugc-portfolios/amanyadhav/ig-carousel/carousel.json \
  -o /Users/codybontecou/dev/ugc-portfolios/amanyadhav/ig-carousel/variants
```

---

## Type 2: Before/After Comparison Carousel

Shows the transformation from an old site (e.g., Canva template) to the new custom portfolio. Designed to be shareable by the creator or as a case study.

### Workflow: Screenshot Sites → Write Config → Generate All → Review

#### Step 1 — Screenshot Both Sites

```bash
cd /Users/codybontecou/dev/ig-carousel && node screenshot-sites.mjs \
  --before <old-site-url> \
  --after <new-site-url> \
  -o <output-dir>
```

Captures both sites at iPhone viewport (390×844 @2x) and saves as `before.png` and `after.png`.

**Input formats** — same as scraper: full URLs, ugc.community subdomains, or local file paths.

Example:
```bash
cd /Users/codybontecou/dev/ig-carousel && node screenshot-sites.mjs \
  --before https://amanyadhavugc.my.canva.site/ \
  --after amanyadhav \
  -o /Users/codybontecou/dev/ugc-portfolios/amanyadhav/ig-comparison
```

#### Step 2 — Write the Comparison Config

Create `comparison.json` in the output directory. The agent writes this based on knowledge of both sites.

**Required fields:**

```json
{
  "creator": {
    "name": "Aman Yadhav",
    "logo": "AY",
    "email": "amanyadhav05@gmail.com"
  },
  "theme": {
    "accent": "#c4a77d",
    "accentLight": "#d4bc96",
    "accentDark": "#a08a64",
    "surface": "#f5f3ef",
    "fontDisplay": "'Bebas Neue', sans-serif",
    "fontHeading": "'Syne', sans-serif",
    "fontBody": "'Cormorant Garamond', serif",
    "fontImportUrl": "https://fonts.googleapis.com/css2?family=..."
  },
  "hookSubtitle": "From Canva template to custom-built portfolio",
  "before": {
    "screenshot": "before.png",
    "label": "Canva template",
    "critiques": [
      "Generic template — looks like everyone else",
      "No work samples or brand partners",
      "No visual identity or brand colors",
      "No mobile-optimized scroll experience"
    ]
  },
  "after": {
    "screenshot": "after.png",
    "label": "amanyadhav.ugc.community",
    "highlights": [
      "Editorial fashion magazine aesthetic",
      "Full campaign portfolio with brand tags",
      "Animated stats: 39K followers, 9.2% engagement",
      "Custom domain with professional presence"
    ]
  },
  "features": [
    { "icon": "🎨", "title": "Custom Design", "description": "Built around the creator's unique brand identity" },
    { "icon": "📊", "title": "Live Stats", "description": "Animated counters and engagement breakdowns" },
    { "icon": "🎬", "title": "Full Portfolio", "description": "All content categories showcased with samples" },
    { "icon": "🤝", "title": "Brand Partners", "description": "Social proof grid with partner logos" },
    { "icon": "📱", "title": "Mobile-First", "description": "Responsive design that works on any device" },
    { "icon": "✉️", "title": "Contact Form", "description": "Direct brand inquiries — zero friction" }
  ],
  "socials": [
    { "platform": "Instagram", "handle": "@blessedbyaman" },
    { "platform": "TikTok", "handle": "@meorthenext" }
  ],
  "ctaTagline": "Custom portfolios that make brands reach out."
}
```

**Key notes:**
- `before.screenshot` / `after.screenshot` are relative to the HTML file (same directory)
- `before.critiques` — 3–5 short ✕ bullet points about what's wrong with the old site
- `after.highlights` — 3–5 short ✓ bullet points about what's great about the new site
- `features` — 4–6 cards for the feature section. Each needs `icon` (emoji), `title`, `description`
- Theme should match the **new** site's design language — pull from the portfolio's CSS vars or reuse from a previous showcase carousel.json

#### Step 3 — Generate All Variants

```bash
cd /Users/codybontecou/dev/ig-carousel && node generate-all.mjs <path>/comparison.json \
  -o <path>/variants
```

Auto-detects comparison type. Generates and captures every comparison variant. Screenshot files (`before.png`, `after.png`) are copied into each variant directory automatically.

Output:

```
<path>/variants/
├── default/
│   ├── before.png
│   ├── after.png
│   ├── comparison.html
│   └── output/
└── split/
    ├── before.png
    ├── after.png
    ├── comparison.html
    └── output/
```

#### Step 4 — Review

Visually review the PNGs across both variants.

### Full Comparison Example

```bash
cd /Users/codybontecou/dev/ig-carousel

# 1. Screenshot both sites
node screenshot-sites.mjs \
  --before https://amanyadhavugc.my.canva.site/ \
  --after amanyadhav \
  -o /Users/codybontecou/dev/ugc-portfolios/amanyadhav/ig-comparison

# 2. Agent writes comparison.json (using the write tool)

# 3. Generate all variants + capture
node generate-all.mjs /Users/codybontecou/dev/ugc-portfolios/amanyadhav/ig-comparison/comparison.json \
  -o /Users/codybontecou/dev/ugc-portfolios/amanyadhav/ig-comparison/variants
```

---

## Single-Variant Generation

If you only need one variant (e.g., iterating on a specific design), use the individual generators:

```bash
# Showcase — single variant
node generate.mjs <path>/carousel.json -o <path>/carousel.html --variant magazine
node capture.mjs <path>/carousel.html -o <path>/output

# Comparison — single variant
node generate-comparison.mjs <path>/comparison.json -o <path>/comparison.html --variant split
node capture.mjs <path>/comparison.html -o <path>/output
```

Available flags: `--variant` / `-v` with variant name. Omit for `default`.

---

## Output Directory Conventions

```
<portfolio-dir>/
├── index.html
├── styles.css
├── ig-carousel/              # Showcase carousel
│   ├── carousel.json         # Source data (edit this)
│   └── variants/             # All variants
│       ├── default/
│       │   ├── carousel.html
│       │   └── output/
│       ├── magazine/
│       │   ├── carousel.html
│       │   └── output/
│       └── bold/
│           ├── carousel.html
│           └── output/
└── ig-comparison/            # Before/after comparison
    ├── before.png
    ├── after.png
    ├── comparison.json       # Source data (edit this)
    └── variants/
        ├── default/
        │   ├── comparison.html
        │   └── output/
        └── split/
            ├── comparison.html
            └── output/
```

## Scripts

| Script | Purpose |
|--------|---------|
| `generate-all.mjs` | **Primary** — JSON → all variants (generate + capture in one step) |
| `scrape.mjs` | URL → `carousel.json` (showcase only) |
| `generate.mjs` | `carousel.json` → single `carousel.html` (supports `--variant`) |
| `generate-comparison.mjs` | `comparison.json` → single `comparison.html` (supports `--variant`) |
| `screenshot-sites.mjs` | Capture mobile screenshots of before/after sites |
| `capture.mjs` | Any `*.html` with `.slide` divs → PNGs |

## Variant Architecture

Variants live in `variants/showcase/` and `variants/comparison/`. Each file exports:
- `generate(config)` → `{ html: string, slideCount: number }`
- `name` — Human-readable name
- `description` — One-line description

To add a new variant, create a file in the appropriate directory and add the import in `generate-all.mjs` (and the individual generator if needed).

## Notes

- `generate-all.mjs` auto-detects type from JSON content: has `hero` → showcase, has `before` → comparison. Override with `--type showcase` or `--type comparison`.
- All variants share the portfolio's **accent color** and **font stacks** — variants change layout and composition, not branding.
- The `magazine` variant works best with strong hero images (portrait, clean backgrounds) since the cover is a split layout.
- The `bold` variant converts all images to partial B&W — it works well with any content but is especially striking with high-contrast photos.
- The `split` comparison variant adds an extra combined-view slide (7 slides vs 6) — the diagonal hook is very eye-catching for scroll-stopping.
- For comparison variants, `generate-all.mjs` automatically copies `before.png` and `after.png` into each variant directory so relative paths work.
- After generating, always **visually review** the PNGs. Iterate by editing the JSON and re-running `generate-all.mjs`.

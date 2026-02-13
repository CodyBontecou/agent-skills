# Instagram Carousel Generator

Generate designed Instagram carousel slides (4:5 feed ratio, 1080×1350) from UGC portfolio sites. Two modes:

1. **Showcase** — Highlights a single portfolio: cover, stats, work samples, brands, CTA
2. **Comparison** — Before/after redesign: hook slide, phone mockups side-by-side, deep dives, features, CTA

All design variants are generated in a single run.

## Design Variants

### Showcase
| Variant | Style |
|---------|-------|
| `default` | Dark editorial — accent borders, outlined display type |
| `magazine` | Light print — cream backgrounds, serif-heavy, bordered frames |
| `bold` | Brutalist — oversized type, color-blocked bars, B&W images with accent overlays |

### Comparison
| Variant | Style |
|---------|-------|
| `default` | Dark cinematic — side-by-side phone mockups, feature cards |
| `split` | Geometric — diagonal split hook, vertical phone stack, numbered features |

## Setup

```bash
cd /Users/codybontecou/dev/ig-carousel && npm install
```

## Quick Start

### Showcase Carousel

```bash
# Scrape portfolio data
node scrape.mjs amanyadhav -o ./output/carousel.json

# Edit carousel.json (fix stats, images, copy)

# Generate all variants
node generate-all.mjs ./output/carousel.json -o ./output/variants
```

### Comparison Carousel

```bash
# Screenshot before/after sites
node screenshot-sites.mjs --before https://old-site.com --after https://new-site.com -o ./output

# Write comparison.json config

# Generate all variants
node generate-all.mjs ./output/comparison.json -o ./output/variants
```

## Scripts

| Script | Purpose |
|--------|---------|
| `generate-all.mjs` | JSON → all variants (generate + capture) |
| `scrape.mjs` | URL → carousel.json |
| `screenshot-sites.mjs` | Capture before/after mobile screenshots |
| `generate.mjs` | Single showcase variant |
| `generate-comparison.mjs` | Single comparison variant |
| `capture.mjs` | HTML slides → PNGs |

See [SKILL.md](./SKILL.md) for full config schemas, variant architecture, and output conventions.

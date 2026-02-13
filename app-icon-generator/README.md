# App Icon Generator

Generate AI-powered app icons for iOS apps and websites using Replicate SDXL. Produces all standard iOS icon sizes (1024 down to 20px) and web favicons (ico, png, webmanifest). Supports multiple visual style variants per run.

## Prerequisites

- Node.js 18+
- `REPLICATE_API_TOKEN` environment variable ([get one here](https://replicate.com/account/api-tokens))

## Setup

```bash
cd scripts && npm install
```

## Usage

```bash
REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN npx tsx scripts/generate.ts "<subject>" \
  --style "<style description>" \
  --output <output-directory> \
  --name "<App Name>" \
  --format <ios|web|all> \
  --variants <number>
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--style` | `"clean modern app icon design"` | Visual style description |
| `--output, -o` | `./app-icons-{timestamp}` | Output directory |
| `--name` | `"App"` | App name (used in webmanifest) |
| `--format` | `all` | `ios`, `web`, or `all` |
| `--variants` | `1` | Number of style variants (1–8) |

### Examples

```bash
# iOS icons only
npx tsx scripts/generate.ts "skincare app glowing face" \
  --style "flat illustration, periwinkle blue and lavender" \
  --format ios -o ./AppIcon

# 4 variants to choose from
npx tsx scripts/generate.ts "fitness tracker with running figure" \
  --style "3D claymation, vibrant orange and teal" \
  --variants 4 -o ./icon-options

# Web favicons only
npx tsx scripts/generate.ts "note taking app, pen and paper" \
  --style "minimal, dark navy background, white linework" \
  --format web -o ./public
```

## Output

Generates all standard iOS icon sizes (1024, 180, 167, 152, 120, 76, 60, 40, 29, 20) and web favicons (favicon.ico, apple-touch-icon, android-chrome icons, site.webmanifest).

See [SKILL.md](./SKILL.md) for full workflow details, style guide, and integration instructions.

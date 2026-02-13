---
name: app-icon-generator
description: Generate AI-powered app icons for iOS apps and websites using Replicate SDXL. Produces all standard iOS icon sizes (1024 down to 20px) and web favicons (ico, png, webmanifest). Supports multiple visual style variants per run. Use when the user needs an app icon, favicon, or launcher icon for their project.
---

# App Icon Generator

Generates production-ready app icons using Replicate's SDXL image model. From a text description and style direction, produces all standard iOS and web icon sizes in one command.

## Prerequisites

- **Node.js** 18+
- **REPLICATE_API_TOKEN** environment variable set (get one at https://replicate.com/account/api-tokens)

## Setup

Run once before first use:

```bash
cd SKILL_DIR/scripts && npm install
```

## Workflow

### Step 1 — Understand the project

Before generating, gather context about the app:

1. **What does the app do?** — Read the README, project files, or ask the user
2. **What's the visual identity?** — Look for existing colors, branding, mood boards, or design files in the project
3. **What platform?** — iOS app (needs `AppIcon-*.png`), website (needs `favicon.*`), or both
4. **Where should icons go?** — Find the asset catalog (`Assets.xcassets/AppIcon.appiconset/`) for iOS, or `public/` / project root for web

### Step 2 — Craft the prompt

Build two parts:

**Subject** — What the icon depicts. Be specific and visual:
- ✅ `"woman with glowing skin applying serum, leaves and bottles floating around her"`
- ✅ `"open book with colorful pages fanning out, knowledge and learning"`
- ❌ `"education app"` (too vague)
- ❌ `"good icon for my app"` (meaningless to the model)

**Style** — The artistic treatment. Combine multiple descriptors:
- `"flat 2D editorial illustration, periwinkle blue and lavender palette, navy accents"`
- `"3D claymation style, soft clay texture, rounded puffy forms, pastel palette"`
- `"minimal geometric, single bold color, clean negative space, dark background"`
- `"glossy 3D render, vibrant gradients, modern app icon aesthetic"`

If the user provided a mood board or reference images, describe the visual style you observe: color palette, illustration style, texture, mood.

### Step 3 — Generate icons

```bash
REPLICATE_API_TOKEN=$REPLICATE_API_TOKEN npx tsx SKILL_DIR/scripts/generate.ts "<subject>" \
  --style "<style description>" \
  --output <output-directory> \
  --name "<App Name>" \
  --format <ios|web|all> \
  --variants <number>
```

**Parameters:**

| Flag | Default | Description |
|------|---------|-------------|
| `--style` | `"clean modern app icon design"` | Visual style description |
| `--output, -o` | `./app-icons-{timestamp}` | Output directory |
| `--name` | `"App"` | App name (used in webmanifest) |
| `--format` | `all` | `ios` = AppIcon sizes only, `web` = favicons only, `all` = both |
| `--variants` | `1` | Number of variants to generate (1–8) |

**Examples:**

```bash
# Single icon, iOS only
npx tsx SKILL_DIR/scripts/generate.ts "skincare app glowing face" \
  --style "flat illustration, periwinkle blue and lavender" \
  --format ios -o ./AppIcon

# 4 variants to choose from
npx tsx SKILL_DIR/scripts/generate.ts "fitness tracker with running figure" \
  --style "3D claymation, vibrant orange and teal" \
  --variants 4 -o ./icon-options

# Web favicons only
npx tsx SKILL_DIR/scripts/generate.ts "note taking app, pen and paper" \
  --style "minimal, dark navy background, white linework" \
  --format web -o ./public
```

### Step 4 — Review with the user

After generating, **always show the user the 1024px icon** using the `read` tool so they can see it inline. If multiple variants were generated, show all of them.

```
Read: <output-dir>/AppIcon-1024.png
Read: <output-dir>/variant-2/AppIcon-1024.png
```

### Step 5 — Install into the project

Once the user picks a variant:

**For iOS (Xcode asset catalog):**
```bash
# Find the asset catalog
find . -name "AppIcon.appiconset" -type d

# Copy the chosen icons
cp <chosen-variant>/AppIcon-*.png <path-to>/Assets.xcassets/AppIcon.appiconset/

# Update Contents.json if needed
```

The standard `Contents.json` for a modern iOS app (single-size icon):
```json
{
  "images": [
    {
      "filename": "AppIcon-1024.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

**For web projects:**
```bash
# Copy favicons to public directory
cp <chosen-variant>/favicon.ico ./public/
cp <chosen-variant>/favicon-*.png ./public/
cp <chosen-variant>/apple-touch-icon.png ./public/
cp <chosen-variant>/android-chrome-*.png ./public/
cp <chosen-variant>/site.webmanifest ./public/
```

Add to `<head>`:
```html
<link rel="icon" type="image/x-icon" href="/favicon.ico">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">
<link rel="manifest" href="/site.webmanifest">
```

### Step 6 — Iterate if needed

If the user wants changes:
- **Different style** — adjust the `--style` flag
- **Different subject** — rewrite the subject description
- **More options** — increase `--variants`
- **Refinement** — be more specific in both subject and style based on feedback

## iOS Icon Size Reference

| Size | Usage |
|------|-------|
| 1024 | App Store |
| 180 | iPhone (@3x) |
| 167 | iPad Pro (@2x) |
| 152 | iPad (@2x) |
| 120 | iPhone (@2x) |
| 76 | iPad (@1x) |
| 60 | iPhone (@1x) — Notification |
| 40 | Spotlight |
| 29 | Settings |
| 20 | Notification |

## Output Structure

Single variant:
```
output/
├── AppIcon-1024.png
├── AppIcon-180.png
├── AppIcon-167.png
├── ...
├── favicon.ico
├── favicon-16x16.png
├── favicon-32x32.png
├── apple-touch-icon.png
├── android-chrome-192x192.png
├── android-chrome-512x512.png
├── site.webmanifest
└── metadata.json
```

Multiple variants:
```
output/
├── variant-1/
│   ├── AppIcon-1024.png
│   └── ...
├── variant-2/
│   ├── AppIcon-1024.png
│   └── ...
```

## Style Guide Cheat Sheet

| Style | Description |
|-------|-------------|
| Flat editorial | `"flat 2D editorial illustration, solid colors, no outlines, modern minimalist"` |
| 3D claymation | `"3D claymation, soft clay texture, rounded puffy forms, matte finish, soft lighting"` |
| Minimal geometric | `"ultra minimalist, single geometric shape, bold color, negative space"` |
| Glossy modern | `"glossy 3D render, vibrant gradients, modern iOS icon aesthetic, rounded corners"` |
| Kawaii | `"kawaii cute style, big eyes, soft pastels, clean flat illustration"` |
| Line art | `"clean line art, single stroke weight, monochrome on bold background"` |

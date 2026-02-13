# App Store Screenshots

Generate App Store marketing screenshots from raw app screenshots. Creates iOS (1242×2688 iPhone) and macOS (2880×1800 MacBook) promotional images with device frame mockups, marketing headlines, and accent-colored typography. Alternates layouts for visual rhythm.

## Prerequisites

- Node.js
- Puppeteer: `npm install puppeteer`

## How It Works

1. Write a JSON config defining slides (screenshot paths, headlines, layout)
2. Generate an HTML file from the config
3. Capture each slide as a high-resolution PNG via Puppeteer

## Quick Start

```bash
# Generate HTML from config
node scripts/generate.mjs config.json -o slides.html

# Capture PNGs
node scripts/capture.mjs slides.html -o ./output --prefix appstore-slide
```

## Platforms

| Platform | Output Size | Device Frame |
|----------|------------|--------------|
| iOS | 1242×2688 | iPhone (portrait) |
| macOS | 2880×1800 | MacBook (landscape) |

## Key Features

- **Device bleeds off the edge** for visual impact
- **Alternating layouts** create rhythm (text-top/bottom for iOS, text-left/right for macOS)
- **Monospace typography** with accent-colored keywords
- **Customizable themes** — accent color, font, background, frame color
- **Headline syntax** — `{word}` for accent color, `\n` for line breaks
- **Automatic sRGB color profile** embedding (required by App Store Connect)

## Config Example

```json
{
  "platform": "ios",
  "theme": {
    "accentColor": "#9B72CF",
    "font": "JetBrains Mono",
    "backgroundColor": "#000000"
  },
  "slides": [
    {
      "headline": "Health{.md}",
      "subtitle": "Your health data\nbeautifully organized",
      "screenshot": "./raw/01-home.png"
    }
  ]
}
```

See [SKILL.md](./SKILL.md) for full config schema, copywriting guidelines, and example configs.

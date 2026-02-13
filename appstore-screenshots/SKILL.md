---
name: appstore-screenshots
description: Generate App Store marketing screenshots from raw app screenshots. Creates iOS (1242×2688 iPhone) and macOS (2880×1800 MacBook) promotional images with device frame mockups, marketing headlines, and accent-colored typography. Alternates layouts for visual rhythm. Use when the user needs App Store screenshots, promotional images, or store listing assets for an iOS or macOS app.
---

# App Store Screenshot Generator

Generates professional App Store marketing images from raw app screenshots. Each output image features a CSS device mockup (iPhone or MacBook) framing a real screenshot, paired with a marketing headline and subtitle — matching the style Apple and top developers use in their store listings.

Supports both **iOS** (iPhone frame, portrait) and **macOS** (MacBook frame, landscape).

## Key design principles

- **Device bleeds off the edge** — the device frame is always cropped by the slide boundary, never floating in empty space.
- **Alternating layouts** — creates visual rhythm as users swipe through the carousel.
  - **iOS**: odd slides text-top, even slides text-bottom (phone bleeds bottom/top).
  - **macOS**: odd slides text-left, even slides text-right (MacBook bleeds right/left).
- **Monospace typography** — headlines in bold monospace with accent-colored keywords, subtitles in lighter gray.
- **Platform-native output** — iOS: 1242×2688 (iPhone 6.5"); macOS: 2880×1800 (Retina).

## Output organization

All screenshots **must** be organized under a versioned directory inside `design/screenshots/`. Detect the app version from the Xcode project (`CFBundleShortVersionString`) or ask the user.

```
design/screenshots/v{VERSION}/
├── appstore/
│   ├── iphone-65/          ← 1242×2688 marketing slides
│   ├── ipad-129/           ← 2048×2732 marketing slides
│   └── mac/                ← 2880×1800 marketing slides
├── raw/
│   ├── iphone/             ← raw simulator/device captures
│   └── ipad/               ← raw simulator/device captures
└── configs/
    ├── config-ios.json     ← iPhone config
    ├── config-ipad.json    ← iPad config
    └── config-mac.json     ← macOS config
```

**Rules:**
- Create only the platform subdirectories you actually need (e.g., skip `mac/` for an iOS-only app).
- Configs reference raw screenshots via relative paths (e.g., `"screenshot": "raw/ipad/01-sync.png"`).
- Generated HTML slides go into `configs/` (e.g., `configs/slides-ios.html`).
- The `appstore/` subdirectories are the final output — these are what get copied into `fastlane/screenshots/en-US/`.
- When a new version is created, the previous version's folder remains untouched as a historical record.

## Setup

Requires Node.js and Puppeteer. Run once in the working directory:

```bash
npm install puppeteer
```

## Workflow: Screenshots → Config → Generate → Capture → Review

### Step 0 — Set up the version directory

Detect or ask for the app version, then create the directory structure:

```bash
VERSION="1.2"  # from Xcode project or user input
mkdir -p design/screenshots/v${VERSION}/{appstore,raw,configs}
```

Create platform subdirectories as needed:

```bash
# For an iOS + iPad app:
mkdir -p design/screenshots/v${VERSION}/appstore/{iphone-65,ipad-129}
mkdir -p design/screenshots/v${VERSION}/raw/{iphone,ipad}

# For a macOS app:
mkdir -p design/screenshots/v${VERSION}/appstore/mac
```

All subsequent steps operate from `design/screenshots/v${VERSION}/`.

### Step 1 — Examine the app screenshots

Look at every screenshot the user provides. For each one, identify:
- Which screen/view of the app it shows
- What feature it highlights
- Its marketing value (is it a good hero shot? does it show a unique feature?)

Select the **best 4–8 screenshots** for the store listing. Prioritize:
1. **Hero/home screen** — always first
2. **Core features** — the 2–3 things that differentiate the app
3. **Settings/customization** — shows depth
4. **Social proof or results** — stats, history, output previews

### Step 2 — Write the config JSON

Create the config in `design/screenshots/v{VERSION}/configs/`. Use one config per platform (e.g., `config-ios.json`, `config-ipad.json`, `config-mac.json`). Screenshot paths are relative to the config file's location.

**Full config schema:**

```json
{
  "platform": "ios",
  "theme": {
    "accentColor": "#9B72CF",
    "font": "JetBrains Mono",
    "fontUrl": "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap",
    "backgroundColor": "#000000",
    "textColor": "#f5f5f7",
    "subtitleColor": "#86868b",
    "frameColor": "dark"
  },
  "output": {
    "width": 1242,
    "height": 2688,
    "prefix": "appstore-slide"
  },
  "slides": []
}
```

**Platform field:**

| Value | Description |
|-------|-------------|
| `ios` | **(default)** iPhone device frame, portrait orientation, text-top / text-bottom layouts. |
| `macos` | MacBook device frame, landscape orientation, text-left / text-right layouts. |

When `platform` is `macos`, output defaults change to `2880×1800` and prefix to `appstore-mac-slide`. These can be overridden in `output`.

**Theme fields:**

| Field | Default | Description |
|-------|---------|-------------|
| `accentColor` | `#9B72CF` | Color for `{accent}` words in headlines. Match the app's brand. |
| `font` | `JetBrains Mono` | Google Font name for headlines and subtitles. |
| `fontUrl` | JetBrains Mono URL | Google Fonts CSS import URL. |
| `backgroundColor` | `#000000` | Slide background. |
| `textColor` | `#f5f5f7` | Headline text color. |
| `subtitleColor` | `#86868b` | Subtitle text color. |
| `frameColor` | `dark` | Device frame finish: `dark`, `silver`, or `gold`. |

**Output fields:**

| Field | iOS Default | macOS Default | Description |
|-------|-------------|---------------|-------------|
| `width` | `1242` | `2880` | Image width in pixels. |
| `height` | `2688` | `1800` | Image height in pixels. |
| `prefix` | `appstore-slide` | `appstore-mac-slide` | Output filename prefix. |

### iOS slide fields

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `layout` | No | Alternates `text-top` / `text-bottom` | `text-top` or `text-bottom`. |
| `headline` | Yes | — | Marketing headline. Use `{word}` for accent color, `\n` for line breaks. |
| `subtitle` | Yes | — | Supporting text. Use `\n` for line breaks. |
| `screenshot` | Yes | — | Path to screenshot file (relative to config.json). |
| `headlineSize` | No | `100` | Headline font size in px. Use 112 for the hero slide. |
| `subtitleSize` | No | `36` | Subtitle font size in px. |
| `phoneWidth` | No | Layout default | Phone mockup width. text-top: `1080`, text-bottom: `1000`. |
| `phoneTop` | No | Layout default | Phone Y position. text-top: `480`, text-bottom: `-120`. |
| `textTop` | No | `70` | Top position of text block (text-top layout only). |
| `textBottom` | No | `80` | Bottom position of text block (text-bottom layout only). |
| `bigNumber` | No | — | Large gradient number displayed above the headline (e.g., `"168"`). |
| `bigNumberSize` | No | `150` | Font size for the big number. |
| `css` | No | — | Raw CSS to inject for this slide (escape carefully). |

### macOS slide fields

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `layout` | No | Alternates `text-left` / `text-right` | `text-left` or `text-right`. |
| `headline` | Yes | — | Marketing headline. Use `{word}` for accent color, `\n` for line breaks. |
| `subtitle` | Yes | — | Supporting text. Use `\n` for line breaks. |
| `screenshot` | Yes | — | Path to macOS screenshot file (relative to config.json). |
| `headlineSize` | No | `80` | Headline font size in px. |
| `subtitleSize` | No | `32` | Subtitle font size in px. |
| `macWidth` | No | `1900` | MacBook mockup width in px. |
| `macRight` | No | `-150` | MacBook right position in text-left layout (negative = bleed off right edge). |
| `macLeft` | No | `-150` | MacBook left position in text-right layout (negative = bleed off left edge). |
| `textLeft` | No | `100` | Text block left position (text-left layout only). |
| `textRight` | No | `100` | Text block right position (text-right layout only). |
| `bigNumber` | No | — | Large gradient number displayed above the headline. |
| `bigNumberSize` | No | `120` | Font size for the big number. |
| `css` | No | — | Raw CSS to inject for this slide. |

**Headline syntax:**
- `Health{.md}` → "Health" in white, ".md" in accent color
- `{Schedule}\nExports` → "Schedule" in accent on line 1, "Exports" in white on line 2
- `Fully\n{Customizable}` → "Fully" in white on line 1, "Customizable" in accent on line 2

### Step 3 — Generate the HTML

Run from the version directory (`design/screenshots/v{VERSION}/`):

```bash
node /Users/codybontecou/.pi/agent/skills/appstore-screenshots/scripts/generate.mjs configs/config-ios.json -o configs/slides-ios.html
```

### Step 4 — Capture the PNGs

Output directly into the platform-specific `appstore/` subdirectory:

```bash
# iPhone 6.5"
node /Users/codybontecou/.pi/agent/skills/appstore-screenshots/scripts/capture.mjs configs/slides-ios.html -o ./appstore/iphone-65 --prefix appstore-ios-slide

# iPad 12.9"
node /Users/codybontecou/.pi/agent/skills/appstore-screenshots/scripts/capture.mjs configs/slides-ipad.html -o ./appstore/ipad-129 --prefix appstore-ipad-slide

# macOS
node /Users/codybontecou/.pi/agent/skills/appstore-screenshots/scripts/capture.mjs configs/slides-mac.html -o ./appstore/mac --prefix appstore-mac-slide
```

Output example: `appstore/iphone-65/appstore-ios-slide-1.png`, `appstore/ipad-129/appstore-ipad-slide-1.png`, etc.

### Step 5 — Review and iterate

Visually review each PNG. Common adjustments:

**iOS:**
- **Too much/little phone visible**: tweak `phoneWidth` and `phoneTop` per slide
- **Headline too long**: shorten copy or reduce `headlineSize`
- **Wrong screenshot**: swap the `screenshot` path
- **Phone frame color**: change `frameColor` in theme

**macOS:**
- **Too much/little MacBook visible**: tweak `macWidth` and `macRight` / `macLeft` per slide
- **Text too cramped**: increase text block width via `css` override or reduce `macWidth`
- **MacBook not prominent enough**: increase `macWidth` or make `macRight` / `macLeft` less negative
- **Frame color**: change `frameColor` in theme (dark matches dark-mode apps)

After editing `config.json`, re-run steps 3 and 4 — generation is instant.

## macOS device frame

The MacBook mockup includes:
- **Aluminum lid** with thin bezels and a subtle notch (modern MacBook Pro style)
- **Screen area** with rounded corners showing the screenshot
- **Hinge** and **base lip** for realistic depth
- **Drop shadow** for floating effect

The frame uses the same `frameColor` presets as iOS (`dark`, `silver`, `gold`), applied as aluminum-style gradients.

## macOS layout details

- **`text-left`** — headline and subtitle on the left ~36% of the slide, MacBook on the right bleeding off the right edge. Best for hero slides.
- **`text-right`** — MacBook on the left bleeding off the left edge, text on the right ~36% aligned right. Creates alternating rhythm.

Both layouts vertically center the text block and MacBook frame. The MacBook bleeds off-screen by default (`macRight: -150` / `macLeft: -150`), keeping the focus on the screen content while implying the full device.

## Copywriting guidelines

Write headlines that are:
- **Short** — 1–3 words per line, max 2 lines
- **Feature-focused** — name the capability, not the implementation
- **Accent on the key word** — the differentiator gets the color

Write subtitles that are:
- **2–3 lines** of supporting detail
- **Concrete** — mention specific formats, numbers, features
- **Monospace-friendly** — shorter words wrap better in monospace

**Good headlines:**
- `Health{.md}` — brand name with accent on extension
- `{Schedule}\nExports` — feature verb + noun
- `{168}\nMetrics` — impressive number + category
- `Fully\n{Customizable}` — modifier + accent capability
- `{Sync}\nfrom iPhone` — macOS: emphasize cross-device feature

**Avoid:**
- Long sentences as headlines
- Generic phrases ("The Best App", "Easy to Use")
- More than 2 accent words per headline

## Example configs

- [examples/health-md.json](examples/health-md.json) — iOS, 6-slide config
- [examples/health-md-macos.json](examples/health-md-macos.json) — macOS, 4-slide config

## Example versioned layout

For Health.md v1.2 (iOS + iPad + macOS):

```
design/screenshots/v1.2/
├── appstore/
│   ├── iphone-65/
│   │   ├── appstore-ios-slide-1.png    (1242×2688)
│   │   ├── appstore-ios-slide-2.png
│   │   └── ...
│   ├── ipad-129/
│   │   ├── appstore-ipad-slide-1.png   (2048×2732)
│   │   ├── appstore-ipad-slide-2.png
│   │   └── ...
│   └── mac/
│       ├── appstore-mac-slide-1.png    (2880×1800)
│       └── ...
├── raw/
│   ├── iphone/
│   │   ├── 01-export.png
│   │   ├── 02-schedule.png
│   │   └── ...
│   └── ipad/
│       ├── 01-sync.png
│       ├── 02-export.png
│       └── ...
└── configs/
    ├── config-ios.json
    ├── config-ipad.json
    ├── config-mac.json
    ├── slides-ios.html
    ├── slides-ipad.html
    └── slides-mac.html
```

## Adapting for different apps

1. **Set the platform** — use `"ios"` for iPhone apps, `"macos"` for Mac apps. If the app ships on both, create two separate configs.
2. **Match the accent color** to the app's primary brand color (pull from the app icon or UI tints)
3. **Choose a font** that matches the app's personality — monospace for dev/technical apps, sans-serif for consumer apps (update `font` and `fontUrl`)
4. **Set frameColor** to match the app's theme — `dark` for dark-mode apps, `silver` for light-mode apps
5. **Screenshot selection** — pick screenshots that show unique features, not generic loading screens or empty states
6. **Alternate layouts** — always alternate for visual rhythm in the App Store carousel

## Output sizes

### iOS

The default 1242×2688 covers the required 6.5" iPhone display. For other sizes:

| Device | Width | Height | Notes |
|--------|-------|--------|-------|
| iPhone 6.5" | 1242 | 2688 | **Required** — iPhone 14/15 Plus, 11/XS Max |
| iPhone 6.7" | 1290 | 2796 | iPhone 14/15 Pro Max |
| iPhone 5.5" | 1242 | 2208 | iPhone 8 Plus (optional) |
| iPad 12.9" | 2048 | 2732 | iPad Pro (if applicable) |

### macOS

The default 2880×1800 covers the most common Retina display. For other sizes:

| Display | Width | Height | Notes |
|---------|-------|--------|-------|
| Retina 16" | 2880 | 1800 | **Recommended** — MacBook Pro 16" |
| Retina 15" | 2560 | 1600 | MacBook Pro 15" / Air 15" |
| Standard | 1440 | 900 | Non-Retina (optional) |
| Minimum | 1280 | 800 | Smallest accepted (optional) |

Override via `output.width` and `output.height` in the config.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/generate.mjs` | Config JSON → slide HTML file (iOS or macOS) |
| `scripts/capture.mjs` | Slide HTML → PNG screenshots via Puppeteer |

## Color profile

App Store Connect **requires** uploaded screenshots to have an embedded **sRGB** ICC color profile. Puppeteer does not embed any profile in its PNG output, which causes uploads to fail or get stuck in "processing" indefinitely.

The `capture.mjs` script automatically embeds the sRGB profile via macOS `sips` after each screenshot is captured. No manual post-processing is needed. If `sips` is unavailable (non-macOS), a warning is printed and you must embed the profile manually:

```bash
# Embed sRGB into all PNGs in a directory
for f in appstore/**/*.png; do
  sips -m "/System/Library/ColorSync/Profiles/sRGB Profile.icc" "$f" --out "$f"
done
```

---
name: ig-content
description: Generate Instagram-ready promotional content (stories, feed posts, carousels) from any website, iOS app, or macOS app. Captures screenshots, wraps them in device mockups (iPhone, MacBook), adds marketing headlines, and exports at IG-native dimensions. Use when the user wants Instagram content, social media assets, or promotional graphics for anything they build.
---

# IG Content Generator

Creates **Instagram-ready promotional content** from any project — websites, iOS apps, or macOS apps. Takes screenshots from any source, wraps them in device mockups (iPhone/MacBook), adds marketing copy, and exports at Instagram-native dimensions.

**Works with anything you build:**
- Live websites (any URL, local dev servers)
- iOS apps (via Simulator)
- macOS apps (via window capture)

**Output formats:**
- Story (1080×1920, 9:16)
- Feed (1080×1350, 4:5)
- Square (1080×1080, 1:1)

**Slide types:**
- `phone` — iPhone device frame mockup
- `mac` — MacBook device frame mockup
- `raw` — Full-bleed screenshot
- `text` — Text-only slide (intro, CTA, stats)

## Repo Path

```
/Users/codybontecou/dev/ig-content
```

## Setup (one-time)

```bash
cd /Users/codybontecou/dev/ig-content && npm install
```

---

## Workflow Overview

Every IG content project follows the same pattern:

1. **Capture** screenshots from the source (web / iOS / macOS)
2. **Write** a config JSON with slide definitions
3. **Generate** HTML slides from the config
4. **Capture** HTML slides to PNGs
5. **Review** and iterate

---

## Phase 1: Capture Screenshots

### Source A: Websites (any URL)

Use the `ugc-screenshots` tool for section-by-section website captures at IG dimensions:

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://mysite.com \
  --ratio story \
  -o /path/to/project/screenshots
```

Or for feed ratio:

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://mysite.com \
  --ratio feed \
  -o /path/to/project/screenshots
```

For local dev servers:

```bash
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs http://localhost:3000 \
  -o /path/to/project/screenshots
```

**Options:** `--sections <json>` for explicit section definitions, `--wait <ms>` for slow-loading sites. See the `ugc-screenshots` skill for full docs.

### Source B: iOS Apps (Simulator)

Use the `ios-simulator-screenshots` skill to capture every screen of an iOS app. The workflow:

1. Boot a simulator: `bash SKILL_DIR/scripts/boot-simulator.sh --device "iPhone 16 Pro"`
2. Build and install: `bash SKILL_DIR/scripts/build-and-install.sh --project ./App.xcodeproj --scheme App --udid <UDID>`
3. Navigate and capture each screen using `sim-screenshot.sh` and `sim-interact.sh`

See the `ios-simulator-screenshots` skill for the complete navigation workflow.

**Recommended:** Capture at iPhone 16 Pro resolution (1179×2556) — these work perfectly inside the ig-content phone mockup.

### Source C: macOS Apps (Window Capture)

Use the `capture-macos.sh` script to capture macOS app windows:

#### List all visible windows

```bash
bash /Users/codybontecou/dev/ig-content/capture-macos.sh --list
```

#### Capture a specific app

```bash
bash /Users/codybontecou/dev/ig-content/capture-macos.sh "App Name" \
  -o /path/to/project/screenshots/mac-main.png
```

#### Resize before capture (for consistent dimensions)

```bash
bash /Users/codybontecou/dev/ig-content/capture-macos.sh "App Name" \
  -o /path/to/project/screenshots/mac-main.png \
  --resize 1440x900
```

#### Capture without window shadow

```bash
bash /Users/codybontecou/dev/ig-content/capture-macos.sh "App Name" \
  -o /path/to/project/screenshots/mac-main.png \
  --no-shadow
```

#### Capture all windows of an app

```bash
bash /Users/codybontecou/dev/ig-content/capture-macos.sh "App Name" \
  -o /path/to/project/screenshots/ \
  --all
```

**For macOS apps you're building:** Build and launch the app first using the `ios-device-build` skill (it handles macOS targets too), then capture the windows.

### Source D: Manual Screenshots

Any PNG/JPG file works as input. Drop screenshots into the project directory and reference them in the config.

---

## Phase 2: Write the Config JSON

Create a `config.json` in your project directory. This defines the theme, output ratio, and slide sequence.

### Minimal config

```json
{
  "theme": {
    "accentColor": "#9B72CF"
  },
  "ratio": "story",
  "slides": [
    {
      "type": "phone",
      "screenshot": "./screenshots/01-home.png",
      "headline": "Health{.md}",
      "subtitle": "Your health data\nbeautifully simple"
    }
  ]
}
```

### Full config schema

```json
{
  "theme": {
    "accentColor": "#9B72CF",
    "font": "Inter",
    "fontUrl": "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap",
    "backgroundColor": "#000000",
    "textColor": "#f5f5f7",
    "subtitleColor": "#86868b",
    "phoneFrame": "dark",
    "macFrame": "dark"
  },
  "ratio": "story",
  "prefix": "ig-slide",
  "slides": []
}
```

### Theme fields

| Field | Default | Description |
|-------|---------|-------------|
| `accentColor` | `#9B72CF` | Color for `{accent}` words in headlines |
| `font` | `Inter` | Google Font for all text |
| `fontUrl` | Inter URL | Google Fonts CSS import URL |
| `backgroundColor` | `#000000` | Default slide background |
| `textColor` | `#f5f5f7` | Headline text color |
| `subtitleColor` | `#86868b` | Subtitle text color |
| `phoneFrame` | `dark` | iPhone frame: `dark`, `silver`, or `gold` |
| `macFrame` | `dark` | MacBook frame: `dark` or `silver` |

### Output ratios

| Ratio | Dimensions | Use case |
|-------|-----------|----------|
| `story` | 1080×1920 | Instagram Stories, Reels covers |
| `feed` | 1080×1350 | Instagram Feed (portrait 4:5) |
| `square` | 1080×1080 | Instagram Feed (square), Twitter |

### Slide types

#### `phone` — iPhone mockup

Shows the screenshot inside an iPhone device frame. The phone bleeds off the edge for visual impact.

```json
{
  "type": "phone",
  "layout": "text-top",
  "screenshot": "./screenshots/01-home.png",
  "headline": "Track {everything}",
  "subtitle": "Health metrics at a glance"
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `layout` | Alternates | `text-top` or `text-bottom` |
| `screenshot` | — | Path to screenshot (relative to config.json) |
| `headline` | — | Marketing headline. `{word}` for accent, `\n` for breaks |
| `subtitle` | — | Supporting text |
| `phoneWidth` | Auto | Override phone width in px |
| `phoneTop` | Auto | Override phone Y position in px |
| `textTop` | `70` | Text block top position (text-top layout) |
| `textBottom` | `70` | Text block bottom position (text-bottom layout) |
| `headlineSize` | `88` | Headline font size in px |
| `subtitleSize` | `34` | Subtitle font size in px |

#### `mac` — MacBook mockup

Shows the screenshot inside a MacBook device frame. Ideal for web projects and macOS apps.

```json
{
  "type": "mac",
  "layout": "text-top",
  "screenshot": "./screenshots/mac-dashboard.png",
  "headline": "Beautiful\n{dashboards}",
  "subtitle": "See your data on the big screen"
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `layout` | Alternates | `text-top` or `text-bottom` |
| `screenshot` | — | Path to screenshot |
| `macWidth` | Auto | Override Mac frame width in px |
| `macTop` | Auto | Override Mac Y position in px |

All text fields from `phone` also apply.

#### `raw` — Full-bleed screenshot

The screenshot fills the entire slide. Optional text overlay at the bottom.

```json
{
  "type": "raw",
  "screenshot": "./screenshots/hero-story.png",
  "headline": "New {release}",
  "subtitle": "v2.0 is here"
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `objectPosition` | `center top` | CSS object-position for the image |
| `textBottom` | `80` | Text overlay position from bottom |

#### `text` — Text-only slide

No device or screenshot. Just centered text on the background. Great for intros, CTAs, and stats.

```json
{
  "type": "text",
  "headline": "Available\n{now}",
  "subtitle": "Download on the App Store",
  "badge": "NEW RELEASE"
}
```

| Field | Default | Description |
|-------|---------|-------------|
| `badge` | — | Small pill badge above the headline |
| `backgroundColor` | Theme default | Override background for this slide |
| `backgroundImage` | — | Path to a background image |
| `bigNumber` | — | Large gradient number above headline (e.g., `"168"`) |
| `bigNumberSize` | `160` | Font size for the big number |

### Headline syntax

- `Health{.md}` → "Health" in white, ".md" in accent
- `{Schedule}\nExports` → "Schedule" in accent on line 1, "Exports" in white on line 2
- `Fully\n{Customizable}` → "Fully" in white, "Customizable" in accent on line 2

### Copywriting guidelines

**Headlines:** 1–3 words per line, max 2 lines. Feature-focused. Accent the key differentiator.

**Subtitles:** 1–3 lines of supporting detail. Concrete features, not fluff.

**Badge:** Short label — "NEW", "OPEN SOURCE", "V2.0", project name.

---

## Phase 3: Generate + Capture

### Generate the HTML slides

```bash
cd /Users/codybontecou/dev/ig-content && node generate.mjs /path/to/config.json -o /path/to/slides.html
```

### Capture to PNGs

```bash
cd /Users/codybontecou/dev/ig-content && node capture.mjs /path/to/slides.html -o /path/to/output --prefix ig-slide
```

Output: `output/ig-slide-1.png`, `output/ig-slide-2.png`, etc. plus a `manifest.json`.

---

## Phase 4: Review + Iterate

Visually review each PNG. Common adjustments:

- **Phone/Mac too big or small:** Tweak `phoneWidth`/`macWidth` and `phoneTop`/`macTop`
- **Headline too long:** Shorten copy or reduce `headlineSize`
- **Wrong screenshot:** Swap the `screenshot` path
- **Bad crop:** Adjust `objectPosition` for raw slides
- **Colors don't match:** Update `accentColor` to match the app's brand

After editing `config.json`, re-run generate + capture.

---

## Complete Examples

### Example 1: iOS App → IG Stories

Promoting a new iOS app with phone mockup slides.

```bash
# 1. Capture iOS screenshots (using ios-simulator-screenshots skill)
#    → produces: ./screenshots/01-home.png, 02-detail.png, etc.

# 2. Write config.json
```

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
      "layout": "text-top",
      "screenshot": "./screenshots/01-home.png",
      "headline": "Track your\n{focus}",
      "subtitle": "See your productivity patterns"
    },
    {
      "type": "phone",
      "layout": "text-bottom",
      "screenshot": "./screenshots/02-timer.png",
      "headline": "{Pomodoro}\ntimer",
      "subtitle": "Built-in focus sessions\nwith smart breaks"
    },
    {
      "type": "phone",
      "layout": "text-top",
      "screenshot": "./screenshots/03-stats.png",
      "headline": "Weekly\n{insights}",
      "subtitle": "Your focus data, visualized"
    },
    {
      "type": "text",
      "headline": "Download\n{free}",
      "subtitle": "Available on the App Store"
    }
  ]
}
```

```bash
# 3. Generate + capture
cd /Users/codybontecou/dev/ig-content
node generate.mjs /path/to/config.json -o /path/to/slides.html
node capture.mjs /path/to/slides.html -o /path/to/output
```

### Example 2: Website → IG Feed Carousel

Promoting a new website with a mix of raw screenshots and Mac mockups.

```bash
# 1. Capture website screenshots
cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs https://mysite.com \
  --ratio feed \
  -o /path/to/screenshots

# 2. Write config.json
```

```json
{
  "theme": {
    "accentColor": "#4A90D9",
    "font": "Space Grotesk",
    "fontUrl": "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&display=swap",
    "macFrame": "silver"
  },
  "ratio": "feed",
  "slides": [
    {
      "type": "text",
      "headline": "My new\n{portfolio}",
      "subtitle": "Designed and built from scratch"
    },
    {
      "type": "mac",
      "layout": "text-top",
      "screenshot": "./screenshots/01-hero-feed.png",
      "headline": "Clean\n{design}",
      "subtitle": "Minimal and focused"
    },
    {
      "type": "raw",
      "screenshot": "./screenshots/02-work-feed.png",
      "headline": "{Projects}",
      "subtitle": "Case studies and details"
    },
    {
      "type": "text",
      "headline": "Check it {out}",
      "subtitle": "Link in bio →"
    }
  ]
}
```

```bash
# 3. Generate + capture
cd /Users/codybontecou/dev/ig-content
node generate.mjs /path/to/config.json -o /path/to/slides.html
node capture.mjs /path/to/slides.html -o /path/to/output --prefix portfolio
```

### Example 3: macOS App → IG Stories

Promoting a macOS app with Mac mockups.

```bash
# 1. Build + launch the app (manually or via ios-device-build skill)

# 2. Capture macOS windows
bash /Users/codybontecou/dev/ig-content/capture-macos.sh "MyMacApp" \
  -o ./screenshots/mac-main.png --resize 1440x900 --no-shadow

# 3. Write config.json
```

```json
{
  "theme": {
    "accentColor": "#34C759",
    "backgroundColor": "#0a0a0a"
  },
  "ratio": "story",
  "slides": [
    {
      "type": "text",
      "badge": "macOS",
      "headline": "{Native}\nperformance",
      "subtitle": "Built with SwiftUI"
    },
    {
      "type": "mac",
      "layout": "text-top",
      "screenshot": "./screenshots/mac-main.png",
      "headline": "Your\n{dashboard}",
      "subtitle": "Everything in one view"
    },
    {
      "type": "mac",
      "layout": "text-bottom",
      "screenshot": "./screenshots/mac-settings.png",
      "headline": "Fully\n{customizable}",
      "subtitle": "Make it yours"
    },
    {
      "type": "text",
      "headline": "Get it {now}",
      "subtitle": "Free on the Mac App Store"
    }
  ]
}
```

### Example 4: Cross-Platform App (iOS + macOS)

Mix phone and Mac mockups in one carousel.

```json
{
  "theme": { "accentColor": "#9B72CF" },
  "ratio": "story",
  "slides": [
    {
      "type": "text",
      "badge": "CROSS-PLATFORM",
      "headline": "Health{.md}",
      "subtitle": "iPhone • iPad • Mac"
    },
    {
      "type": "phone",
      "layout": "text-top",
      "screenshot": "./screenshots/ios-home.png",
      "headline": "On the {go}",
      "subtitle": "Track anywhere"
    },
    {
      "type": "mac",
      "layout": "text-bottom",
      "screenshot": "./screenshots/mac-dashboard.png",
      "headline": "At your {desk}",
      "subtitle": "Full dashboard view"
    },
    {
      "type": "phone",
      "layout": "text-top",
      "screenshot": "./screenshots/ios-charts.png",
      "headline": "{168}\nmetrics",
      "subtitle": "Every data point tracked"
    },
    {
      "type": "text",
      "headline": "One app\n{everywhere}",
      "subtitle": "Syncs via iCloud"
    }
  ]
}
```

---

## Output Directory Conventions

For any project, create an `ig/` directory:

```
<project>/
├── ig/
│   ├── screenshots/         # Raw captures (from any source)
│   │   ├── ios-home.png
│   │   ├── ios-detail.png
│   │   ├── mac-main.png
│   │   └── web-hero.png
│   ├── config.json          # Slide definitions
│   ├── slides.html          # Generated HTML
│   └── output/              # Final PNGs
│       ├── ig-slide-1.png
│       ├── ig-slide-2.png
│       └── manifest.json
```

---

## Capture Source Quick Reference

| Source | Tool | Command |
|--------|------|---------|
| Website (any URL) | ugc-screenshots | `cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs <url>` |
| Website (local dev) | ugc-screenshots | `cd /Users/codybontecou/dev/ugc-screenshots && node screenshot.mjs http://localhost:3000` |
| iOS app (Simulator) | ios-simulator-screenshots | See skill for full workflow |
| macOS app (window) | ig-content | `bash /Users/codybontecou/dev/ig-content/capture-macos.sh "App Name" -o out.png` |
| Manual | — | Any PNG/JPG file |

## Scripts

| Script | Purpose |
|--------|---------|
| `generate.mjs` | Config JSON → IG slide HTML |
| `capture.mjs` | Slide HTML → PNGs via Puppeteer |
| `capture-macos.sh` | Capture macOS app window screenshots |

## Adapting for Different Projects

1. **Match the accent color** to the app's brand (pull from app icon, UI tint, or CSS vars)
2. **Choose a font** that matches the project — monospace for dev tools, sans-serif for consumer apps, serif for editorial
3. **Set frame colors** to match the app's theme — `dark` for dark-mode apps, `silver` for light
4. **Start with a text slide** — introduce the project with a badge and headline
5. **End with a CTA** — "Download", "Check it out", "Link in bio"
6. **Alternate layouts** — alternate `text-top` and `text-bottom` for visual rhythm (this happens by default)
7. **Mix slide types** — combine phone, mac, raw, and text for variety
8. **4–6 slides** is the sweet spot for IG carousels

## Relationship to Other Skills

| Skill | Role |
|-------|------|
| `ugc-screenshots` | Captures website screenshots at IG ratios (input source) |
| `ios-simulator-screenshots` | Captures iOS app screenshots from Simulator (input source) |
| `ios-device-build` | Builds and launches iOS/macOS apps (prep step) |
| `appstore-screenshots` | Generates App Store marketing images (different output — 1242×2688) |
| `ig-carousel` | Generates designed carousel slides from UGC portfolio data (specialized) |

This skill (`ig-content`) is the **general-purpose IG content generator** — it works with any screenshots from any source, producing IG-native output with device mockups and marketing copy.

## Notes

- The phone mockup CSS matches the style from `appstore-screenshots` — familiar and proven
- The Mac mockup is a clean MacBook Pro style with camera dot, thin bezel, and chin
- All dimensions auto-scale based on the chosen ratio — you don't need separate configs for story vs feed
- Screenshots referenced in `config.json` are resolved relative to the config file's directory
- Font loading uses Google Fonts — any Google Font name/URL works
- The capture script waits for fonts and images to load before screenshotting
- For best results with phone mockups, use screenshots at ~1179×2556 (iPhone 16 Pro native)
- For best results with Mac mockups, use screenshots at ~2880×1800 or ~1440×900 (any 16:10 ratio)
- The `--no-shadow` flag on `capture-macos.sh` is recommended when the screenshot will go inside a Mac mockup (avoids double shadow)

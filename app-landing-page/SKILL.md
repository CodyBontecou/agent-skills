---
name: app-landing-page
description: Generate a minimal, aesthetic landing page for an app inspired by Teenage Engineering's design language. Produces a marketing homepage with app screenshots displayed in device mockups, plus separate Terms of Service and Privacy Policy pages. Uses the app icon as the site favicon. Use when the user needs a promotional website, landing page, or legal pages for their app.
---

# App Landing Page Generator

Generates a complete, self-contained app marketing website: a visually striking landing page with device-framed screenshots, plus Terms of Service and Privacy Policy pages. All output is static HTML/CSS/JS — no build tools, no frameworks, no dependencies.

## Design Philosophy

The design is inspired by **Teenage Engineering** — the Swedish electronics company known for radical minimalism, monochrome palettes with singular accent colors, bold typography, industrial grid systems, and obsessive attention to detail. Study their approach:

- **Monochrome + one accent**: Nearly all black/white/gray with a single vivid color used sparingly — a button, a highlight, a border
- **Grid-obsessed layouts**: Precise alignment, mathematical spacing, visible structure
- **Industrial typography**: Monospace or geometric sans-serif fonts. Tight tracking. Uppercase labels. Weight contrast (ultra-light body, bold headlines)
- **Negative space as a feature**: Generous whitespace is not emptiness — it's intentional breathing room
- **Functional aesthetics**: Every element earns its place. No decoration for decoration's sake
- **Subtle technical details**: Thin borders, small uppercase labels, version numbers, model codes — details that signal precision
- **Photography as hero**: Products (or in our case, screenshots) displayed large, clean, with reverence

Read the [design reference](references/design-reference.md) for specific CSS patterns and component examples.

## Inputs

Before generating, gather the following from the user or project context:

| Input | Required | Source |
|-------|----------|--------|
| App name | Yes | User or project files (Info.plist, package.json, etc.) |
| App tagline / description | Yes | User, App Store description, or README |
| App icon | Yes | Asset catalog, project assets, or user-provided file |
| Screenshots | Yes | PNG/JPG files from simulator, device, or user-provided |
| App Store / Play Store URL | No | User-provided |
| Brand accent color | No | Extract from app icon or UI; defaults to a bold single hue |
| Developer / company name | No | For legal pages footer and copyright |
| Contact email | No | For privacy policy contact section |
| Key features | No | 3–6 one-liner features for a feature grid |

## Workflow

### Step 1 — Gather context

Examine the project to extract:

1. **App name and bundle ID** — from `Info.plist`, `project.pbxproj`, `package.json`, or user input
2. **App icon** — find the highest-resolution app icon (1024×1024 preferred). Look in:
   - `Assets.xcassets/AppIcon.appiconset/`
   - Project root for `icon.png`, `app-icon.png`, etc.
   - User-provided path
3. **Screenshots** — collect all available screenshots. If using with the `ios-simulator-screenshots` skill, look in the `screenshots/` directory
4. **App description** — from README, App Store metadata, or user input
5. **Accent color** — extract the dominant vivid color from the app icon. Use a single hue. If the icon is monochrome, pick one bold color (e.g., `#FF5722`, `#00E5FF`, `#FFEA00`)

### Step 2 — Generate the favicon

Convert the app icon to a web favicon:

```bash
# If ImageMagick is available:
magick <app-icon-path> -resize 32x32 output/favicon.ico
magick <app-icon-path> -resize 180x180 output/apple-touch-icon.png
magick <app-icon-path> -resize 192x192 output/icon-192.png
magick <app-icon-path> -resize 512x512 output/icon-512.png

# If sips is available (macOS):
sips -z 32 32 <app-icon-path> --out output/favicon.png
sips -z 180 180 <app-icon-path> --out output/apple-touch-icon.png
```

If neither tool is available, copy the app icon directly and reference it as the favicon at its original size. Browsers will downscale.

### Step 3 — Process screenshots

Copy screenshots into the output directory. If needed, resize for web performance:

```bash
# Optional: create web-optimized versions (max 800px wide)
for f in screenshots/*.png; do
  sips -Z 800 "$f" --out "output/screenshots/$(basename $f)"
done
```

If no resizing tools are available, use originals — the HTML will constrain display size via CSS.

### Step 4 — Generate the landing page (`index.html`)

Create a single-file `index.html` with all CSS inlined (no external stylesheets). The page must include:

#### Header
- App icon (small, ~40px) + app name in uppercase monospace
- Navigation: minimal text links — `Features`, `Screenshots`, `Privacy`, `Terms`
- Clean thin bottom border

#### Hero Section
- Large headline: app name or tagline in bold geometric/monospace type
- Subtitle: one or two sentences describing the app
- CTA button(s): "Download on the App Store" / "Get on Google Play" (if URLs provided), styled as a minimal outlined or solid button with the accent color
- Hero screenshot: the single best screenshot displayed in a CSS device mockup, angled or straight, large and prominent

#### Features Section (if features provided)
- Grid of 3–6 features
- Each feature: small uppercase label + one-line description
- Monochrome icons or simple geometric shapes (CSS-only, no external icons)
- Precise grid alignment with visible structure

#### Screenshots Gallery
- All screenshots displayed in CSS phone mockups
- Layout options (pick the one that best suits the number of screenshots):
  - **Horizontal scroll**: screenshots in a single horizontal row, overflow-x scroll, snap-to-item
  - **Staggered grid**: screenshots at alternating heights, creating visual rhythm
  - **Carousel**: single large screenshot with dots/arrows navigation
- Phone mockup is CSS-only: rounded rect with border, notch, minimal bezel
- Screenshots should feel like physical objects in space — subtle shadows, precise borders

#### Footer
- Developer/company name
- Links: Privacy Policy, Terms of Service
- Year + copyright
- Thin top border, generous padding

#### Design Requirements

Follow these **strictly**:

- **Font**: Use ONE monospace or geometric sans-serif Google Font. Strong choices: `Space Mono`, `IBM Plex Mono`, `DM Mono`, `Geist Mono`, `Azeret Mono`, `Inconsolata`. For sans-serif: `DM Sans`, `Satoshi`, `General Sans`, `Switzer`. Load via Google Fonts `<link>`.
- **Color**: Maximum 3 colors total — background, text, and ONE accent. The accent color should appear in no more than 3 places on the entire page (CTA button, one highlight, maybe a border).
- **Spacing**: Use a strict 8px grid. All margins and padding should be multiples of 8. Generous whitespace — sections should breathe.
- **Typography scale**: Use a modular scale. Headlines at 48–72px, body at 16–18px, labels at 11–13px uppercase with wide letter-spacing.
- **Borders**: Thin (1px) borders in `rgba(0,0,0,0.1)` or `rgba(255,255,255,0.1)`. Use them to create structure, not decoration.
- **No gradients, no blur, no glassmorphism, no rounded-everything**. Keep it flat, precise, and structural.
- **Dark or light theme**: Choose based on the app's personality. Dark = `#0a0a0a` background, `#fafafa` text. Light = `#fafafa` background, `#0a0a0a` text.
- **Responsive**: Must work on mobile. Use CSS Grid or Flexbox. Screenshots gallery should horizontal-scroll on mobile.
- **Smooth scroll**: `html { scroll-behavior: smooth; }` for anchor navigation
- **Subtle animations**: Fade-in on scroll (Intersection Observer), slight upward translate. Keep it minimal — one animation style, consistent timing.

### Step 5 — Generate Terms of Service (`terms.html`)

Create a separate `terms.html` page with:

- Same header/footer as landing page (consistent navigation)
- Same favicon and font
- Title: "Terms of Service"
- Last updated date: today's date
- Content sections covering:
  1. **Acceptance of Terms** — by using the app, you agree
  2. **Description of Service** — what the app does (use gathered app description)
  3. **User Accounts** (if applicable) — account creation, responsibility
  4. **Acceptable Use** — prohibited behaviors
  5. **Intellectual Property** — app content belongs to developer
  6. **Disclaimers** — provided "as is", no warranties
  7. **Limitation of Liability** — standard limitation clause
  8. **Changes to Terms** — developer may update terms
  9. **Governing Law** — specify jurisdiction (use developer's location or leave as placeholder)
  10. **Contact** — email or contact method

- Style: clean typographic page. Narrow max-width (~680px), generous line-height (1.7), clear section numbering, same monospace/geometric font

**Important**: Generate reasonable boilerplate that the developer should review with legal counsel. Add a comment at the top of the HTML: `<!-- REVIEW WITH LEGAL COUNSEL BEFORE PUBLISHING -->`

### Step 6 — Generate Privacy Policy (`privacy.html`)

Create a separate `privacy.html` page with:

- Same header/footer as landing page
- Same favicon and font
- Title: "Privacy Policy"
- Last updated date: today's date
- Content sections covering:
  1. **Information We Collect** — what data the app gathers (infer from app type, or keep generic)
  2. **How We Use Information** — purposes for data use
  3. **Data Storage and Security** — how data is stored
  4. **Third-Party Services** — analytics, crash reporting, etc. (if known)
  5. **Children's Privacy** — COPPA compliance note
  6. **Your Rights** — data access, deletion requests
  7. **Data Retention** — how long data is kept
  8. **Changes to Privacy Policy** — notification of changes
  9. **Contact** — email or contact method

- Same clean typographic styling as terms page

**Important**: Same legal review comment at top of HTML.

### Step 7 — Review and refine

After generating all files, review each page:

1. **Open `index.html`** in the browser tool and screenshot it
2. **Check visual consistency** — does it feel like one cohesive site?
3. **Verify all links work** — navigation between index, terms, privacy
4. **Test screenshot gallery** — do the device mockups display correctly?
5. **Check favicon** — does the icon appear in the browser tab?
6. **Mobile check** — resize to mobile width and verify responsive layout

Common refinements:
- Adjust accent color if it clashes with screenshots
- Tighten or loosen spacing between sections
- Swap screenshot order to lead with the most impressive one
- Adjust hero screenshot size if it dominates or underwhelms

## Output Structure

```
output/
├── index.html              # Landing page (all CSS inlined)
├── terms.html              # Terms of Service
├── privacy.html            # Privacy Policy
├── favicon.ico             # App icon as favicon (or .png)
├── apple-touch-icon.png    # iOS home screen icon
├── icon-192.png            # PWA icon
├── icon-512.png            # PWA icon large
└── screenshots/            # Web-optimized screenshots
    ├── 01-home.png
    ├── 02-detail.png
    └── ...
```

## CSS Device Mockup Reference

The phone mockup for screenshots should be pure CSS — no images. Minimal example:

```css
.phone-mockup {
  position: relative;
  width: 280px;
  border: 2px solid currentColor;
  border-radius: 40px;
  padding: 12px;
  background: #000;
}

.phone-mockup::before {
  /* Notch / dynamic island */
  content: '';
  position: absolute;
  top: 8px;
  left: 50%;
  transform: translateX(-50%);
  width: 80px;
  height: 24px;
  background: #000;
  border-radius: 12px;
  z-index: 2;
}

.phone-mockup img {
  width: 100%;
  display: block;
  border-radius: 28px;
}
```

Scale the mockup size proportionally. For hero screenshots, use `width: 320px` or larger. For gallery items, use `width: 240–280px`.

## Integration with Other Skills

- **ios-simulator-screenshots** → Captures raw PNGs from the simulator → feed into this skill as screenshot inputs
- **appstore-screenshots** → Generates App Store marketing images → can also be displayed on the landing page
- **frontend-design** → This skill follows similar design principles but is specifically scoped to app landing pages

## Checklist

Before delivering, verify:

- [ ] App icon appears as favicon in browser tab
- [ ] All screenshots render inside device mockups
- [ ] Navigation links between all three pages work
- [ ] Accent color appears in ≤ 3 places on the landing page
- [ ] Only ONE font family is loaded
- [ ] Legal pages have the review comment at top
- [ ] Responsive layout works at 375px width
- [ ] No external dependencies — fully self-contained HTML files
- [ ] Smooth scroll works for anchor links
- [ ] Footer shows correct copyright year and developer name

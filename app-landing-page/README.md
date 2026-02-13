# App Landing Page

Generate a minimal, aesthetic landing page for an app inspired by Teenage Engineering's design language. Produces a marketing homepage with app screenshots displayed in device mockups, plus separate Terms of Service and Privacy Policy pages. Uses the app icon as the site favicon.

## What It Generates

- **`index.html`** — Landing page with hero section, feature grid, screenshot gallery in CSS device mockups, and footer
- **`terms.html`** — Terms of Service page with standard legal boilerplate
- **`privacy.html`** — Privacy Policy page with standard sections
- **Favicons** — App icon converted to web favicon formats

All output is static HTML/CSS/JS — no build tools, no frameworks, no dependencies.

## Design Philosophy

- Monochrome palette with a single accent color
- Grid-obsessed layouts with mathematical spacing
- Industrial typography (monospace or geometric sans-serif)
- Generous negative space
- CSS-only device mockups for screenshots
- Fully responsive, self-contained HTML files

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| App name | Yes | From project files or user input |
| App description / tagline | Yes | Marketing copy for the hero section |
| App icon | Yes | Highest resolution available (1024×1024 preferred) |
| Screenshots | Yes | PNG/JPG files from simulator or device |
| App Store / Play Store URL | No | For download CTA buttons |
| Brand accent color | No | Extracted from app icon or UI |

See [SKILL.md](./SKILL.md) for the full generation workflow, design requirements, and CSS device mockup reference.

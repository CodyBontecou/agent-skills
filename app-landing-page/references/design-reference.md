# Teenage Engineering Design Reference

Concrete CSS patterns and component examples for the app landing page skill. These are building blocks — adapt and combine them to match each app's personality.

## Core CSS Variables

Every page should start with a strict variable set. Three colors maximum.

```css
:root {
  /* Monochrome base — dark theme */
  --bg: #0a0a0a;
  --fg: #fafafa;
  --muted: #666666;
  --border: rgba(255, 255, 255, 0.1);

  /* OR light theme */
  /* --bg: #fafafa; --fg: #0a0a0a; --muted: #888; --border: rgba(0,0,0,0.08); */

  /* Single accent — derived from app icon */
  --accent: #FF5722;

  /* Spacing grid: strict 8px multiples */
  --space-xs: 8px;
  --space-sm: 16px;
  --space-md: 24px;
  --space-lg: 40px;
  --space-xl: 64px;
  --space-2xl: 96px;
  --space-3xl: 128px;

  /* Typography */
  --font-mono: 'Space Mono', monospace;
  --text-xs: 11px;
  --text-sm: 13px;
  --text-base: 16px;
  --text-lg: 20px;
  --text-xl: 32px;
  --text-2xl: 48px;
  --text-3xl: 72px;
}
```

## Typography Patterns

### Uppercase Micro Labels

The signature Teenage Engineering detail — tiny uppercase labels with wide tracking.

```css
.label {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: var(--muted);
}
```

### Headlines

Bold, large, tight line-height. Monospace gives them a technical, designed feel.

```css
h1 {
  font-family: var(--font-mono);
  font-size: var(--text-3xl);
  font-weight: 700;
  line-height: 1.05;
  letter-spacing: -0.02em;
  color: var(--fg);
  margin: 0;
}

h2 {
  font-family: var(--font-mono);
  font-size: var(--text-2xl);
  font-weight: 700;
  line-height: 1.1;
  letter-spacing: -0.01em;
  color: var(--fg);
  margin: 0;
}
```

### Body Text

Clean, readable, generous line-height.

```css
p {
  font-family: var(--font-mono);
  font-size: var(--text-base);
  line-height: 1.7;
  color: var(--muted);
  max-width: 560px;
}
```

## Header Pattern

Minimal top bar with thin bottom border. App icon + name left, nav links right.

```css
header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-sm) var(--space-lg);
  border-bottom: 1px solid var(--border);
  position: sticky;
  top: 0;
  background: var(--bg);
  z-index: 100;
}

header .brand {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

header .brand img {
  width: 32px;
  height: 32px;
  border-radius: 8px;
}

header .brand span {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-weight: 600;
  color: var(--fg);
}

header nav {
  display: flex;
  gap: var(--space-md);
}

header nav a {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--muted);
  text-decoration: none;
  transition: color 0.2s;
}

header nav a:hover {
  color: var(--fg);
}
```

## Hero Section Pattern

Centered layout. Big text, then a device mockup. Tons of whitespace.

```css
.hero {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: var(--space-3xl) var(--space-lg) var(--space-xl);
  min-height: 80vh;
}

.hero h1 {
  max-width: 800px;
}

.hero .subtitle {
  margin-top: var(--space-md);
  max-width: 480px;
}

.hero .cta {
  margin-top: var(--space-lg);
}

.hero .hero-device {
  margin-top: var(--space-xl);
}
```

## CTA Button

Minimal, precise. Either outlined or solid with the accent color.

```css
/* Outlined variant */
.btn {
  display: inline-flex;
  align-items: center;
  gap: var(--space-xs);
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  padding: 12px 32px;
  border: 1.5px solid var(--accent);
  color: var(--accent);
  background: transparent;
  text-decoration: none;
  transition: all 0.2s;
  cursor: pointer;
}

.btn:hover {
  background: var(--accent);
  color: var(--bg);
}

/* Solid variant */
.btn-solid {
  background: var(--accent);
  color: var(--bg);
  border-color: var(--accent);
}

.btn-solid:hover {
  opacity: 0.85;
}
```

## Feature Grid

Precise grid with thin borders creating visible structure — like a spec sheet.

```css
.features {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  border-top: 1px solid var(--border);
  border-left: 1px solid var(--border);
}

.feature {
  padding: var(--space-lg);
  border-right: 1px solid var(--border);
  border-bottom: 1px solid var(--border);
}

.feature .feature-label {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: var(--accent);
  margin-bottom: var(--space-sm);
}

.feature .feature-text {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  line-height: 1.6;
  color: var(--muted);
}

/* Responsive: 2-col on tablet, 1-col on mobile */
@media (max-width: 768px) {
  .features {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 480px) {
  .features {
    grid-template-columns: 1fr;
  }
}
```

## Screenshot Gallery — Horizontal Scroll

Screenshots in device mockups, horizontally scrollable with snap.

```css
.gallery {
  padding: var(--space-2xl) 0;
}

.gallery-label {
  padding: 0 var(--space-lg);
  margin-bottom: var(--space-lg);
}

.gallery-scroll {
  display: flex;
  gap: var(--space-md);
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  padding: 0 var(--space-lg);
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}

.gallery-scroll::-webkit-scrollbar {
  display: none;
}

.gallery-item {
  flex-shrink: 0;
  scroll-snap-align: start;
}
```

## Screenshot Gallery — Staggered Grid

Alternating heights for visual rhythm.

```css
.gallery-staggered {
  display: flex;
  gap: var(--space-md);
  padding: var(--space-2xl) var(--space-lg);
  justify-content: center;
  flex-wrap: wrap;
}

.gallery-staggered .gallery-item:nth-child(even) {
  margin-top: var(--space-xl);
}
```

## Phone Mockup

Pure CSS — no images needed. Adjust border-radius and proportions.

```css
.phone {
  position: relative;
  width: 280px;
  background: #000;
  border: 2px solid rgba(255, 255, 255, 0.2);
  border-radius: 44px;
  padding: 14px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

/* Dynamic Island */
.phone::before {
  content: '';
  position: absolute;
  top: 10px;
  left: 50%;
  transform: translateX(-50%);
  width: 76px;
  height: 24px;
  background: #000;
  border-radius: 20px;
  z-index: 2;
}

.phone img {
  width: 100%;
  display: block;
  border-radius: 32px;
}

/* Size variants */
.phone-hero {
  width: 340px;
}

.phone-gallery {
  width: 260px;
}

.phone-small {
  width: 200px;
}
```

## Footer

Minimal, precise. Matches the header in tone.

```css
footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--space-lg);
  border-top: 1px solid var(--border);
  flex-wrap: wrap;
  gap: var(--space-sm);
}

footer .copyright {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  color: var(--muted);
  letter-spacing: 0.05em;
}

footer nav {
  display: flex;
  gap: var(--space-md);
}

footer nav a {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--muted);
  text-decoration: none;
  transition: color 0.2s;
}

footer nav a:hover {
  color: var(--fg);
}
```

## Scroll Animations

Minimal fade-in on scroll. One style, consistent.

```css
.fade-in {
  opacity: 0;
  transform: translateY(16px);
  transition: opacity 0.6s ease, transform 0.6s ease;
}

.fade-in.visible {
  opacity: 1;
  transform: translateY(0);
}
```

```javascript
// Intersection Observer for scroll animations
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    }
  });
}, { threshold: 0.1 });

document.querySelectorAll('.fade-in').forEach(el => observer.observe(el));
```

## Legal Pages Typography

Clean reading experience for terms and privacy pages.

```css
.legal {
  max-width: 680px;
  margin: 0 auto;
  padding: var(--space-2xl) var(--space-lg);
}

.legal h1 {
  font-size: var(--text-2xl);
  margin-bottom: var(--space-xs);
}

.legal .last-updated {
  font-family: var(--font-mono);
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: var(--muted);
  margin-bottom: var(--space-2xl);
}

.legal h2 {
  font-size: var(--text-lg);
  margin-top: var(--space-xl);
  margin-bottom: var(--space-sm);
}

.legal p {
  margin-bottom: var(--space-sm);
}
```

## Anti-Patterns (Never Do These)

- ❌ Rounded gradient buttons
- ❌ Drop shadows on everything
- ❌ More than 3 colors
- ❌ More than 1 font family
- ❌ Emojis as design elements
- ❌ `backdrop-filter: blur()` glassmorphism
- ❌ Bouncy/elastic animations
- ❌ Card-based layouts with heavy border-radius
- ❌ Stock photography or illustrations
- ❌ Loading spinners or skeleton screens (it's a static site)
- ❌ Cookie banners or popups in the generated HTML

## Color Extraction from App Icon

When extracting the accent color from an app icon:

1. Look at the dominant vivid color in the icon
2. If the icon uses multiple colors, pick the most distinctive one
3. Ensure sufficient contrast against both `#0a0a0a` and `#fafafa` backgrounds
4. If the icon is monochrome (black/white/gray), choose a color that matches the app's personality:
   - Productivity → `#2962FF` (blue)
   - Health/Fitness → `#00C853` (green)
   - Creative/Music → `#FF6D00` (orange)
   - Social → `#E91E63` (pink)
   - Finance → `#00BFA5` (teal)
   - Developer tools → `#FFEA00` (yellow)

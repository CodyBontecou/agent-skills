#!/usr/bin/env node
/**
 * generate.mjs — Config JSON → App Store slide HTML
 *
 * Usage:
 *   node generate.mjs <config.json> -o <output.html>
 *
 * Supports iOS (iPhone device frame) and macOS (MacBook device frame).
 * The config JSON defines platform, theme, dimensions, and slides.
 * Headline text uses {curly braces} for accent-colored words.
 * See SKILL.md for the full config schema.
 */

import { readFileSync, writeFileSync, existsSync } from "fs";
import path from "path";

// ── CLI ──────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
const configIdx = args.findIndex((a) => !a.startsWith("-"));
const outIdx = args.indexOf("-o");

if (configIdx === -1) {
  console.error("Usage: node generate.mjs <config.json> -o <output.html>");
  process.exit(1);
}

const configPath = path.resolve(args[configIdx]);
const config = JSON.parse(readFileSync(configPath, "utf-8"));
const outputPath =
  outIdx !== -1
    ? path.resolve(args[outIdx + 1])
    : path.join(path.dirname(configPath), "slides.html");

// ── Platform ─────────────────────────────────────────────────────────
const platform = config.platform || "ios";

// ── Defaults ─────────────────────────────────────────────────────────
const theme = {
  accentColor: "#9B72CF",
  font: "JetBrains Mono",
  fontUrl:
    "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap",
  backgroundColor: "#000000",
  textColor: "#f5f5f7",
  subtitleColor: "#86868b",
  frameColor: "dark", // 'dark' | 'silver' | 'gold'
  ...config.theme,
};

const defaultOutput =
  platform === "macos"
    ? { width: 2880, height: 1800, prefix: "appstore-mac-slide" }
    : { width: 1242, height: 2688, prefix: "appstore-slide" };

const output = {
  ...defaultOutput,
  ...config.output,
};

const slides = config.slides || [];

if (slides.length === 0) {
  console.error("Error: config.slides is empty");
  process.exit(1);
}

// ── Frame color presets ──────────────────────────────────────────────
const frameColors = {
  dark: {
    gradient: `linear-gradient(160deg, #5a5a5c 0%, #48484a 4%, #3a3a3c 12%, #2c2c2e 40%, #1c1c1e 60%, #2c2c2e 85%, #48484a 96%, #5a5a5c 100%)`,
    border: "rgba(255,255,255,0.1)",
    buttons: "#555",
    buttonBg: "#3a3a3c",
    hingeGradient: `linear-gradient(180deg, #1c1c1e, #2c2c2e, #1c1c1e)`,
    baseGradient: `linear-gradient(180deg, #3a3a3c, #2c2c2e)`,
  },
  silver: {
    gradient: `linear-gradient(160deg, #d4d4d8 0%, #c0c0c4 4%, #a8a8ac 12%, #909094 40%, #808084 60%, #909094 85%, #c0c0c4 96%, #d4d4d8 100%)`,
    border: "rgba(255,255,255,0.3)",
    buttons: "#b0b0b4",
    buttonBg: "#a0a0a4",
    hingeGradient: `linear-gradient(180deg, #808084, #909094, #808084)`,
    baseGradient: `linear-gradient(180deg, #a8a8ac, #909094)`,
  },
  gold: {
    gradient: `linear-gradient(160deg, #d4c5a0 0%, #c4b590 4%, #b0a078 12%, #9a8a62 40%, #8a7a52 60%, #9a8a62 85%, #c4b590 96%, #d4c5a0 100%)`,
    border: "rgba(255,255,255,0.2)",
    buttons: "#b0a078",
    buttonBg: "#9a8a62",
    hingeGradient: `linear-gradient(180deg, #8a7a52, #9a8a62, #8a7a52)`,
    baseGradient: `linear-gradient(180deg, #b0a078, #9a8a62)`,
  },
};

const frame = frameColors[theme.frameColor] || frameColors.dark;

// ── Headline parser: {text} → <span class="accent">text</span> ─────
function parseHeadline(text) {
  return text
    .replace(/\{([^}]+)\}/g, '<span class="accent">$1</span>')
    .replace(/\n/g, "<br>");
}

function parseSubtitle(text) {
  return text.replace(/\n/g, "<br>");
}

// ── Resolve screenshot paths relative to config file ────────────────
const configDir = path.dirname(configPath);
function resolveScreenshot(src) {
  if (path.isAbsolute(src)) return src;
  return path.relative(path.dirname(outputPath), path.join(configDir, src));
}

// ── Color helper ────────────────────────────────────────────────────
function lighten(hex, percent) {
  const num = parseInt(hex.replace("#", ""), 16);
  const r = Math.min(255, (num >> 16) + Math.round(2.55 * percent));
  const g = Math.min(255, ((num >> 8) & 0x00ff) + Math.round(2.55 * percent));
  const b = Math.min(255, (num & 0x0000ff) + Math.round(2.55 * percent));
  return `#${((r << 16) | (g << 8) | b).toString(16).padStart(6, "0")}`;
}

// ── Layout defaults ─────────────────────────────────────────────────
const iosLayoutDefaults = {
  "text-top": { textTop: 70, phoneWidth: 1080, phoneTop: 480 },
  "text-bottom": { textBottom: 80, phoneWidth: 1000, phoneTop: -120 },
};

const macLayoutDefaults = {
  "text-left": { textLeft: 100, macWidth: 1900, macRight: -150 },
  "text-right": { textRight: 100, macWidth: 1900, macLeft: -150 },
};

// ── Build per-slide CSS + HTML ──────────────────────────────────────
let slidesCSS = "";
let slidesHTML = "";

slides.forEach((slide, i) => {
  const id = `slide-${i + 1}`;
  const screenshotSrc = resolveScreenshot(slide.screenshot);

  if (platform === "macos") {
    buildMacSlide(id, slide, i, screenshotSrc);
  } else {
    buildIOSSlide(id, slide, i, screenshotSrc);
  }
});

// ── iOS slide builder ───────────────────────────────────────────────
function buildIOSSlide(id, slide, i, screenshotSrc) {
  const layout = slide.layout || (i % 2 === 0 ? "text-top" : "text-bottom");
  const defaults = iosLayoutDefaults[layout];

  const phoneWidth = slide.phoneWidth || defaults.phoneWidth;
  const headlineSize = slide.headlineSize || 100;
  const subtitleSize = slide.subtitleSize || 36;

  // ── Per-slide CSS ──
  if (layout === "text-top") {
    const textTop = slide.textTop ?? defaults.textTop;
    const phoneTop = slide.phoneTop ?? defaults.phoneTop;
    slidesCSS += `
  #${id} .text-block { top: ${textTop}px; }
  #${id} .headline { font-size: ${headlineSize}px; }
  #${id} .subtitle { font-size: ${subtitleSize}px; }
  #${id} .phone { width: ${phoneWidth}px; top: ${phoneTop}px; }`;
  } else {
    const textBottom = slide.textBottom ?? defaults.textBottom;
    const phoneTop = slide.phoneTop ?? defaults.phoneTop;
    slidesCSS += `
  #${id} .phone { width: ${phoneWidth}px; top: ${phoneTop}px; }
  #${id} .text-block { bottom: ${textBottom}px; }
  #${id} .headline { font-size: ${headlineSize}px; }
  #${id} .subtitle { font-size: ${subtitleSize}px; }`;
  }

  // Big number support
  if (slide.bigNumber) {
    slidesCSS += `
  #${id} .big-number {
    font-size: ${slide.bigNumberSize || 150}px;
    font-weight: 700;
    display: block;
    line-height: 1;
    background: linear-gradient(135deg, ${theme.accentColor}, ${lighten(theme.accentColor, 30)});
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }`;
  }

  // Custom CSS passthrough
  if (slide.css) {
    slidesCSS += `\n  ${slide.css}`;
  }

  slidesCSS += "\n";

  // ── Per-slide HTML ──
  const headlineHTML = slide.bigNumber
    ? `<span class="big-number">${slide.bigNumber}</span>${parseHeadline(slide.headline)}`
    : parseHeadline(slide.headline);

  const textBlock = `
  <div class="text-block">
    <div class="headline">${headlineHTML}</div>
    <div class="subtitle">${parseSubtitle(slide.subtitle)}</div>
  </div>`;

  const phoneBlock = `
  <div class="phone">
    <div class="phone-body">
      <div class="btn-power"></div><div class="btn-silence"></div>
      <div class="btn-vol-up"></div><div class="btn-vol-down"></div>
      <div class="phone-screen"><img src="${screenshotSrc}" alt=""></div>
    </div>
  </div>`;

  if (layout === "text-top") {
    slidesHTML += `\n<div class="slide" id="${id}">${textBlock}${phoneBlock}\n</div>\n`;
  } else {
    slidesHTML += `\n<div class="slide" id="${id}">${phoneBlock}${textBlock}\n</div>\n`;
  }
}

// ── macOS slide builder ─────────────────────────────────────────────
function buildMacSlide(id, slide, i, screenshotSrc) {
  const layout = slide.layout || (i % 2 === 0 ? "text-left" : "text-right");
  const defaults = macLayoutDefaults[layout];

  const macWidth = slide.macWidth || defaults.macWidth;
  const headlineSize = slide.headlineSize || 80;
  const subtitleSize = slide.subtitleSize || 32;

  // ── Per-slide CSS ──
  if (layout === "text-left") {
    const textLeft = slide.textLeft ?? defaults.textLeft;
    const macRight = slide.macRight ?? defaults.macRight;
    slidesCSS += `
  #${id} .text-block { left: ${textLeft}px; right: auto; width: 36%; top: 50%; transform: translateY(-50%); }
  #${id} .headline { font-size: ${headlineSize}px; }
  #${id} .subtitle { font-size: ${subtitleSize}px; }
  #${id} .mac { width: ${macWidth}px; right: ${macRight}px; left: auto; top: 50%; transform: translateY(-50%); }`;
  } else {
    const textRight = slide.textRight ?? defaults.textRight;
    const macLeft = slide.macLeft ?? defaults.macLeft;
    slidesCSS += `
  #${id} .text-block { right: ${textRight}px; left: auto; width: 36%; top: 50%; transform: translateY(-50%); text-align: right; }
  #${id} .headline { font-size: ${headlineSize}px; }
  #${id} .subtitle { font-size: ${subtitleSize}px; }
  #${id} .mac { width: ${macWidth}px; left: ${macLeft}px; right: auto; top: 50%; transform: translateY(-50%); }`;
  }

  // Big number support
  if (slide.bigNumber) {
    slidesCSS += `
  #${id} .big-number {
    font-size: ${slide.bigNumberSize || 120}px;
    font-weight: 700;
    display: block;
    line-height: 1;
    background: linear-gradient(135deg, ${theme.accentColor}, ${lighten(theme.accentColor, 30)});
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }`;
  }

  // Custom CSS passthrough
  if (slide.css) {
    slidesCSS += `\n  ${slide.css}`;
  }

  slidesCSS += "\n";

  // ── Per-slide HTML ──
  const headlineHTML = slide.bigNumber
    ? `<span class="big-number">${slide.bigNumber}</span>${parseHeadline(slide.headline)}`
    : parseHeadline(slide.headline);

  const textBlock = `
  <div class="text-block">
    <div class="headline">${headlineHTML}</div>
    <div class="subtitle">${parseSubtitle(slide.subtitle)}</div>
  </div>`;

  const macBlock = `
  <div class="mac">
    <div class="mac-lid">
      <div class="mac-notch"></div>
      <div class="mac-screen"><img src="${screenshotSrc}" alt=""></div>
    </div>
    <div class="mac-hinge"></div>
    <div class="mac-base"></div>
  </div>`;

  if (layout === "text-left") {
    slidesHTML += `\n<div class="slide" id="${id}">${textBlock}${macBlock}\n</div>\n`;
  } else {
    slidesHTML += `\n<div class="slide" id="${id}">${macBlock}${textBlock}\n</div>\n`;
  }
}

// ── Device CSS: iPhone ──────────────────────────────────────────────
function getIOSDeviceCSS() {
  return `
  .phone {
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    filter: drop-shadow(0 30px 60px rgba(0,0,0,0.5));
  }
  .phone-body {
    background: ${frame.gradient};
    border-radius: 58px;
    padding: 10px;
    position: relative;
  }
  .phone-body::before {
    content: '';
    position: absolute;
    inset: 0;
    border-radius: 58px;
    border: 1px solid ${frame.border};
    pointer-events: none;
  }
  .phone-screen {
    background: #000;
    border-radius: 48px;
    overflow: hidden;
  }
  .phone-screen img {
    width: 100%;
    height: auto;
    display: block;
  }

  .btn-power {
    position: absolute; right: -4px; top: 240px;
    width: 4px; height: 100px;
    background: linear-gradient(90deg, ${frame.buttonBg}, ${frame.buttons}, ${frame.buttonBg});
    border-radius: 0 3px 3px 0;
  }
  .btn-silence {
    position: absolute; left: -4px; top: 175px;
    width: 4px; height: 35px;
    background: linear-gradient(270deg, ${frame.buttonBg}, ${frame.buttons}, ${frame.buttonBg});
    border-radius: 3px 0 0 3px;
  }
  .btn-vol-up {
    position: absolute; left: -4px; top: 250px;
    width: 4px; height: 68px;
    background: linear-gradient(270deg, ${frame.buttonBg}, ${frame.buttons}, ${frame.buttonBg});
    border-radius: 3px 0 0 3px;
  }
  .btn-vol-down {
    position: absolute; left: -4px; top: 338px;
    width: 4px; height: 68px;
    background: linear-gradient(270deg, ${frame.buttonBg}, ${frame.buttons}, ${frame.buttonBg});
    border-radius: 3px 0 0 3px;
  }`;
}

// ── Device CSS: MacBook ─────────────────────────────────────────────
function getMacDeviceCSS() {
  return `
  .mac {
    position: absolute;
    filter: drop-shadow(0 20px 60px rgba(0,0,0,0.5));
  }
  .mac-lid {
    background: ${frame.gradient};
    border-radius: 14px 14px 2px 2px;
    padding: 10px 10px 14px 10px;
    position: relative;
  }
  .mac-lid::before {
    content: '';
    position: absolute;
    inset: 0;
    border-radius: 14px 14px 2px 2px;
    border: 1px solid ${frame.border};
    pointer-events: none;
  }
  .mac-notch {
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 100px;
    height: 10px;
    background: ${frame.gradient};
    border-radius: 0 0 10px 10px;
    z-index: 3;
  }
  .mac-screen {
    background: #000;
    border-radius: 6px;
    overflow: hidden;
    position: relative;
  }
  .mac-screen img {
    width: 100%;
    height: auto;
    display: block;
  }
  .mac-hinge {
    height: 8px;
    background: ${frame.hingeGradient};
    border-radius: 0 0 2px 2px;
  }
  .mac-base {
    width: 104%;
    margin-left: -2%;
    height: 5px;
    background: ${frame.baseGradient};
    border-radius: 0 0 6px 6px;
    position: relative;
  }
  .mac-base::before {
    content: '';
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 15%;
    height: 2px;
    background: rgba(255,255,255,0.08);
    border-radius: 0 0 2px 2px;
  }`;
}

// ── Select device CSS based on platform ─────────────────────────────
function getDeviceCSS() {
  return platform === "macos" ? getMacDeviceCSS() : getIOSDeviceCSS();
}

// ── Full HTML ───────────────────────────────────────────────────────
const html = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=${output.width}, initial-scale=1">
<title>App Store Slides</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="${theme.fontUrl}" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: ${theme.backgroundColor}; overflow: hidden; }

  .slide {
    width: ${output.width}px;
    height: ${output.height}px;
    background: ${theme.backgroundColor};
    position: relative;
    overflow: hidden;
    display: none;
  }
  .slide.active { display: block; }

  .text-block {
    position: absolute;
    left: 80px;
    right: 80px;
    z-index: 2;
  }
  .headline {
    font-family: '${theme.font}', 'SF Mono', monospace;
    font-size: 100px;
    font-weight: 700;
    color: ${theme.textColor};
    line-height: 1.1;
    letter-spacing: -1px;
  }
  .headline .accent { color: ${theme.accentColor}; }
  .subtitle {
    font-family: '${theme.font}', 'SF Mono', monospace;
    font-size: 36px;
    font-weight: 400;
    color: ${theme.subtitleColor};
    line-height: 1.5;
    margin-top: 20px;
  }
${getDeviceCSS()}
${slidesCSS}
</style>
</head>
<body>
${slidesHTML}
<script>
  function showSlide() {
    const num = parseInt(location.hash.replace('#', '')) || 1;
    document.querySelectorAll('.slide').forEach((s, i) => {
      s.classList.toggle('active', i === num - 1);
    });
  }
  window.addEventListener('hashchange', showSlide);
  showSlide();
</script>
</body>
</html>`;

writeFileSync(outputPath, html);
console.log(`✅ Generated ${slides.length} ${platform} slides → ${outputPath}`);

#!/usr/bin/env node
/**
 * capture.mjs — Slide HTML → PNG screenshots via Puppeteer
 *
 * Usage:
 *   node capture.mjs <slides.html> [-o <output-dir>] [--prefix <name>]
 *
 * Reads the HTML, counts .slide elements, captures each at full resolution.
 * Output: <output-dir>/<prefix>-<N>.png
 */

import { readFileSync, mkdirSync } from "fs";
import { createRequire } from "module";
import { execFileSync } from "child_process";
import path from "path";

// Resolve puppeteer from CWD (where user ran npm install)
let puppeteerDefault;
try {
  const require = createRequire(path.join(process.cwd(), "noop.js"));
  puppeteerDefault = require("puppeteer");
} catch {
  console.error(
    "Puppeteer not found. Run: npm install puppeteer"
  );
  process.exit(1);
}

// ── CLI ──────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
const htmlIdx = args.findIndex((a) => !a.startsWith("-"));
const outIdx = args.indexOf("-o");
const prefixIdx = args.indexOf("--prefix");

if (htmlIdx === -1) {
  console.error(
    "Usage: node capture.mjs <slides.html> [-o <output-dir>] [--prefix <name>]"
  );
  process.exit(1);
}

const htmlPath = path.resolve(args[htmlIdx]);
const outputDir =
  outIdx !== -1 ? path.resolve(args[outIdx + 1]) : path.dirname(htmlPath);
const prefix = prefixIdx !== -1 ? args[prefixIdx + 1] : "appstore-slide";

mkdirSync(outputDir, { recursive: true });

// ── Parse dimensions + slide count from HTML ────────────────────────
const htmlContent = readFileSync(htmlPath, "utf-8");

const widthMatch = htmlContent.match(/\.slide\s*\{[^}]*width:\s*(\d+)px/);
const heightMatch = htmlContent.match(/\.slide\s*\{[^}]*height:\s*(\d+)px/);
const WIDTH = widthMatch ? parseInt(widthMatch[1]) : 1242;
const HEIGHT = heightMatch ? parseInt(heightMatch[1]) : 2688;

// Count slides by occurrences of class="slide"
const slideCount = (htmlContent.match(/class="slide"/g) || []).length;

if (slideCount === 0) {
  console.error('Error: no elements with class="slide" found in HTML');
  process.exit(1);
}

console.log(
  `📐 ${WIDTH}×${HEIGHT}, ${slideCount} slides, prefix: "${prefix}"\n`
);

// ── Capture ─────────────────────────────────────────────────────────
async function main() {
  const browser = await puppeteerDefault.launch({
    headless: true,
    args: [`--window-size=${WIDTH},${HEIGHT}`],
  });

  const page = await browser.newPage();
  await page.setViewport({
    width: WIDTH,
    height: HEIGHT,
    deviceScaleFactor: 1,
  });

  for (let i = 1; i <= slideCount; i++) {
    const url = `file://${htmlPath}#${i}`;
    await page.goto(url, { waitUntil: "networkidle0" });

    // Wait for all images
    await page.evaluate(() =>
      Promise.all(
        Array.from(document.images).map((img) =>
          img.complete
            ? Promise.resolve()
            : new Promise((res, rej) => {
                img.onload = res;
                img.onerror = rej;
              })
        )
      )
    );

    await new Promise((r) => setTimeout(r, 500));

    const outPath = path.join(outputDir, `${prefix}-${i}.png`);
    await page.screenshot({
      path: outPath,
      clip: { x: 0, y: 0, width: WIDTH, height: HEIGHT },
    });

    // Embed sRGB ICC profile — required by App Store Connect
    try {
      execFileSync("sips", [
        "-m",
        "/System/Library/ColorSync/Profiles/sRGB Profile.icc",
        outPath,
        "--out",
        outPath,
      ], { stdio: "pipe" });
    } catch {
      console.warn(`  ⚠️  Could not embed sRGB profile for slide ${i} (sips unavailable)`);
    }

    console.log(`  ✅ Slide ${i} → ${outPath}`);
  }

  await browser.close();
  console.log(`\n🎉 ${slideCount} slides captured to ${outputDir}`);
}

main().catch((err) => {
  console.error("Error:", err);
  process.exit(1);
});

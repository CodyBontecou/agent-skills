#!/usr/bin/env npx tsx
/**
 * AI-powered app icon generator using Replicate's SDXL model.
 *
 * Usage:
 *   npx tsx generate.ts "subject description" --style "custom style" --output ./icons --name MyApp
 *   npx tsx generate.ts "skincare app with glowing face" --style "3D claymation, pastel palette" -o ./icons
 *
 * Environment:
 *   REPLICATE_API_TOKEN=your_token_here
 */

import Replicate from "replicate";
import sharp from "sharp";
import { writeFileSync, mkdirSync, existsSync } from "fs";
import { join } from "path";
import { parseArgs } from "util";

// All standard iOS app icon sizes
const IOS_SIZES = [1024, 180, 167, 152, 120, 76, 60, 40, 29, 20];

// Favicon sizes for web use
const WEB_SIZES: Record<string, number> = {
  "favicon-16x16.png": 16,
  "favicon-32x32.png": 32,
  "apple-touch-icon.png": 180,
  "android-chrome-192x192.png": 192,
  "android-chrome-512x512.png": 512,
};

function getApiToken(): string {
  const token = process.env.REPLICATE_API_TOKEN;
  if (!token) {
    console.error("Error: REPLICATE_API_TOKEN environment variable not set");
    console.error("Get your token at: https://replicate.com/account/api-tokens");
    process.exit(1);
  }
  return token;
}

async function generateImage(
  replicate: Replicate,
  subject: string,
  style: string
): Promise<string> {
  const prompt = `iOS app icon for ${subject}, ${style}, centered composition, single icon, no text, no words, no letters, no watermark, square format, high quality, 1024x1024`;

  const negativePrompt = `blurry, low quality, text, words, letters, numbers, watermark, signature, multiple icons, busy background, photograph, realistic photo, ugly, deformed, noisy, grainy, cropped, out of frame`;

  console.log(`  Prompt: ${prompt.slice(0, 120)}...`);

  const output = await replicate.run(
    "stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
    {
      input: {
        prompt,
        negative_prompt: negativePrompt,
        width: 1024,
        height: 1024,
        num_inference_steps: 35,
        guidance_scale: 8,
        scheduler: "K_EULER",
      },
    }
  );

  const imageUrl = Array.isArray(output) ? output[0] : output;
  return imageUrl as string;
}

async function downloadImage(url: string): Promise<Buffer> {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Download failed: ${response.statusText}`);
  return Buffer.from(await response.arrayBuffer());
}

async function createIco(imageBuffer: Buffer): Promise<Buffer> {
  const sizes = [16, 32, 48];
  const pngBuffers: { size: number; data: Buffer }[] = [];

  for (const size of sizes) {
    const resized = await sharp(imageBuffer)
      .resize(size, size, { fit: "contain", background: { r: 0, g: 0, b: 0, alpha: 0 } })
      .png()
      .toBuffer();
    pngBuffers.push({ size, data: resized });
  }

  const numImages = pngBuffers.length;
  const header = Buffer.alloc(6);
  header.writeUInt16LE(0, 0);
  header.writeUInt16LE(1, 2);
  header.writeUInt16LE(numImages, 4);

  const dirEntrySize = 16;
  let dataOffset = 6 + numImages * dirEntrySize;
  const directory = Buffer.alloc(numImages * dirEntrySize);
  const imageDataBuffers: Buffer[] = [];

  pngBuffers.forEach((img, i) => {
    const offset = i * dirEntrySize;
    directory.writeUInt8(img.size < 256 ? img.size : 0, offset);
    directory.writeUInt8(img.size < 256 ? img.size : 0, offset + 1);
    directory.writeUInt8(0, offset + 2);
    directory.writeUInt8(0, offset + 3);
    directory.writeUInt16LE(1, offset + 4);
    directory.writeUInt16LE(32, offset + 6);
    directory.writeUInt32LE(img.data.length, offset + 8);
    directory.writeUInt32LE(dataOffset, offset + 12);
    dataOffset += img.data.length;
    imageDataBuffers.push(img.data);
  });

  return Buffer.concat([header, directory, ...imageDataBuffers]);
}

async function main() {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: {
      style: { type: "string", default: "" },
      output: { type: "string", short: "o" },
      name: { type: "string", default: "App" },
      format: { type: "string", default: "all" }, // ios, web, all
      variants: { type: "string", default: "1" },
      help: { type: "boolean", short: "h" },
    },
  });

  if (values.help || positionals.length === 0) {
    console.log(`
App Icon Generator — AI-powered icon generation via Replicate SDXL

Usage:
  npx tsx generate.ts <subject> [options]

Arguments:
  subject              Description of the icon (e.g., "skincare app with glowing face")

Options:
  --style <style>      Visual style description (e.g., "3D claymation, pastel blue and lavender")
  --output, -o <dir>   Output directory (default: ./app-icons-{timestamp})
  --name <name>        App name for webmanifest (default: App)
  --format <format>    Output format: ios, web, or all (default: all)
  --variants <n>       Number of variants to generate (default: 1)
  --help, -h           Show this help

Examples:
  npx tsx generate.ts "skincare app" --style "flat illustration, periwinkle blue" -o ./icons
  npx tsx generate.ts "fitness tracker" --style "3D claymation" --variants 4
  npx tsx generate.ts "note taking app" --style "minimal, dark background" --format ios
`);
    process.exit(0);
  }

  const subject = positionals[0];
  const style = values.style || "clean modern app icon design";
  const name = values.name || "App";
  const format = values.format || "all";
  const numVariants = Math.max(1, Math.min(8, parseInt(values.variants || "1", 10)));

  const timestamp = new Date().toISOString().slice(0, 19).replace(/[:-]/g, "").replace("T", "_");
  const outputDir = values.output || `app-icons-${timestamp}`;

  mkdirSync(outputDir, { recursive: true });

  const token = getApiToken();
  const replicate = new Replicate({ auth: token });

  console.log(`\n🎨 App Icon Generator`);
  console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
  console.log(`  Subject:  ${subject}`);
  console.log(`  Style:    ${style}`);
  console.log(`  Variants: ${numVariants}`);
  console.log(`  Format:   ${format}`);
  console.log(`  Output:   ${outputDir}/\n`);

  for (let v = 1; v <= numVariants; v++) {
    const variantDir = numVariants > 1 ? join(outputDir, `variant-${v}`) : outputDir;
    mkdirSync(variantDir, { recursive: true });

    const label = numVariants > 1 ? `Variant ${v}/${numVariants}` : "Generating";
    console.log(`  🖼  ${label}...`);

    try {
      const imageUrl = await generateImage(replicate, subject, style);
      console.log(`  ⬇  Downloading...`);
      const imageBuffer = await downloadImage(imageUrl);

      // Save 1024px base
      const baseBuffer = await sharp(imageBuffer)
        .resize(1024, 1024, { fit: "cover" })
        .png({ compressionLevel: 9 })
        .toBuffer();

      writeFileSync(join(variantDir, "AppIcon-1024.png"), baseBuffer);
      console.log(`     AppIcon-1024.png`);

      // iOS sizes
      if (format === "ios" || format === "all") {
        for (const size of IOS_SIZES) {
          if (size === 1024) continue; // already saved
          const resized = await sharp(baseBuffer)
            .resize(size, size, { fit: "cover" })
            .png({ compressionLevel: 9 })
            .toBuffer();
          writeFileSync(join(variantDir, `AppIcon-${size}.png`), resized);
          console.log(`     AppIcon-${size}.png`);
        }
      }

      // Web sizes
      if (format === "web" || format === "all") {
        for (const [filename, size] of Object.entries(WEB_SIZES)) {
          const resized = await sharp(baseBuffer)
            .resize(size, size, { fit: "contain", background: { r: 0, g: 0, b: 0, alpha: 0 } })
            .png({ compressionLevel: 9 })
            .toBuffer();
          writeFileSync(join(variantDir, filename), resized);
          console.log(`     ${filename}`);
        }

        // ICO
        const icoBuffer = await createIco(baseBuffer);
        writeFileSync(join(variantDir, "favicon.ico"), icoBuffer);
        console.log(`     favicon.ico`);

        // Webmanifest
        const manifest = {
          name,
          short_name: name,
          icons: [
            { src: "/android-chrome-192x192.png", sizes: "192x192", type: "image/png" },
            { src: "/android-chrome-512x512.png", sizes: "512x512", type: "image/png" },
          ],
          theme_color: "#ffffff",
          background_color: "#ffffff",
          display: "standalone",
        };
        writeFileSync(join(variantDir, "site.webmanifest"), JSON.stringify(manifest, null, 2));
        console.log(`     site.webmanifest`);
      }

      // Metadata
      writeFileSync(
        join(variantDir, "metadata.json"),
        JSON.stringify(
          {
            subject,
            style,
            name,
            format,
            source_url: imageUrl,
            generated_at: new Date().toISOString(),
          },
          null,
          2
        )
      );

      console.log(`  ✅ Done!\n`);
    } catch (err: any) {
      console.error(`  ❌ Failed: ${err.message}\n`);
    }
  }

  console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
  console.log(`✅ Output: ${outputDir}/\n`);
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});

#!/usr/bin/env node
/**
 * generate-fastfile.mjs — Generate a Fastfile for App Store delivery
 *
 * Usage:
 *   node generate-fastfile.mjs \
 *     --bundle-id <com.example.app> \
 *     --key-id <KEY_ID> \
 *     --issuer-id <ISSUER_ID> \
 *     --key-path <path.p8> \
 *     --platform <ios|macos> \
 *     --version <1.0> \
 *     -o <fastlane/Fastfile>
 *
 * Generates a Fastfile with lanes for uploading metadata, screenshots, and submitting.
 */

import { writeFileSync, mkdirSync } from "fs";
import path from "path";

// ── CLI ──────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
function getArg(name) {
  const idx = args.indexOf(name);
  return idx !== -1 ? args[idx + 1] : null;
}

const bundleId = getArg("--bundle-id");
const keyId = getArg("--key-id");
const issuerId = getArg("--issuer-id");
const keyPath = getArg("--key-path");
const platform = getArg("--platform") || "ios";
const version = getArg("--version") || "1.0";
const outputPath = getArg("-o") || "fastlane/Fastfile";

if (!bundleId || !keyId || !issuerId || !keyPath) {
  console.error(
    "Usage: node generate-fastfile.mjs --bundle-id <id> --key-id <KEY> --issuer-id <ISS> --key-path <p8> --platform <ios|macos> --version <ver> -o <path>"
  );
  process.exit(1);
}

// ── Platform mapping ────────────────────────────────────────────────
const platformMap = {
  ios: { fastlanePlatform: "ios", deliverPlatform: "ios", spaceship: "IOS" },
  macos: { fastlanePlatform: "mac", deliverPlatform: "osx", spaceship: "MAC_OS" },
};
const p = platformMap[platform] || platformMap.ios;

// ── Generate Fastfile ───────────────────────────────────────────────
const fastfile = `default_platform(:${p.fastlanePlatform})

APP_ID = "${bundleId}"
API_KEY_ID = "${keyId}"
API_ISSUER_ID = "${issuerId}"
API_KEY_PATH = "${path.resolve(keyPath)}"

def connect_api_key
  app_store_connect_api_key(
    key_id: API_KEY_ID,
    issuer_id: API_ISSUER_ID,
    key_filepath: API_KEY_PATH,
    in_house: false
  )
end

platform :${p.fastlanePlatform} do
  desc "Show current app info on App Store Connect"
  lane :info do
    connect_api_key
    app = Spaceship::ConnectAPI::App.find(APP_ID)
    UI.message("App: \#{app.name} (\#{app.bundle_id})")

    edit = app.get_edit_app_store_version(platform: Spaceship::ConnectAPI::Platform::${p.spaceship})
    if edit
      UI.message("Edit version: \#{edit.version_string} — state: \#{edit.app_store_state}")
      localizations = edit.get_app_store_version_localizations
      localizations.each do |loc|
        UI.message("  Locale: \#{loc.locale}")
        sets = loc.get_app_screenshot_sets
        sets.each do |set|
          UI.message("    \#{set.screenshot_display_type}: \#{set.app_screenshots.count} screenshots")
        end
      end
    else
      UI.message("No edit version found")
    end

    live = app.get_live_app_store_version(platform: Spaceship::ConnectAPI::Platform::${p.spaceship})
    if live
      UI.message("Live version: \#{live.version_string} — state: \#{live.app_store_state}")
    else
      UI.message("No live version found")
    end
  end

  desc "Upload metadata only"
  lane :upload_metadata do
    connect_api_key
    deliver(
      app_identifier: APP_ID,
      app_version: "${version}",
      skip_binary_upload: true,
      skip_screenshots: true,
      run_precheck_before_submit: false,
      force: true,
      platform: "${p.deliverPlatform}"
    )
  end

  desc "Upload screenshots only"
  lane :upload_screenshots do
    connect_api_key
    deliver(
      app_identifier: APP_ID,
      app_version: "${version}",
      skip_binary_upload: true,
      skip_metadata: true,
      overwrite_screenshots: true,
      run_precheck_before_submit: false,
      force: true,
      platform: "${p.deliverPlatform}"
    )
  end

  desc "Upload metadata + screenshots"
  lane :upload_all do
    connect_api_key
    deliver(
      app_identifier: APP_ID,
      app_version: "${version}",
      skip_binary_upload: true,
      overwrite_screenshots: true,
      run_precheck_before_submit: false,
      force: true,
      platform: "${p.deliverPlatform}"
    )
  end

  desc "Submit for review (uploads metadata + screenshots first)"
  lane :submit do
    connect_api_key
    deliver(
      app_identifier: APP_ID,
      app_version: "${version}",
      skip_binary_upload: true,
      overwrite_screenshots: true,
      run_precheck_before_submit: true,
      submit_for_review: true,
      automatic_release: true,
      force: true,
      platform: "${p.deliverPlatform}",
      submission_information: {
        add_id_info_uses_idfa: false
      }
    )
  end
end
`;

mkdirSync(path.dirname(outputPath), { recursive: true });
writeFileSync(outputPath, fastfile);
console.log(`✅ Generated Fastfile → ${outputPath}`);
console.log(`   Platform: ${platform}`);
console.log(`   Bundle ID: ${bundleId}`);
console.log(`   Version: ${version}`);
console.log("");
console.log("Available lanes:");
console.log(`   fastlane ${p.fastlanePlatform} info              — Check app status`);
console.log(`   fastlane ${p.fastlanePlatform} upload_metadata   — Upload description, keywords, etc.`);
console.log(`   fastlane ${p.fastlanePlatform} upload_screenshots — Upload screenshots`);
console.log(`   fastlane ${p.fastlanePlatform} upload_all        — Upload metadata + screenshots`);
console.log(`   fastlane ${p.fastlanePlatform} submit            — Upload everything + submit for review`);

---
name: appstore-submit
description: Submit an iOS, iPadOS, or macOS app to the App Store programmatically. Handles the full pipeline — project detection, building and uploading the binary, generating App Store marketing screenshots (device mockups with headlines), writing metadata (description, keywords, release notes), uploading everything to App Store Connect via Fastlane, and preparing for review. Use when the user wants to submit, update, or publish an app to the App Store.
---

# App Store Submit

End-to-end App Store submission — from Xcode project to "Submit for Review". Handles iOS, iPadOS, and macOS apps.

## What this skill does

1. **Detects** the Xcode project, schemes, bundle IDs, and versions
2. **Generates marketing screenshots** using device mockups with headlines (delegates to the `appstore-screenshots` skill)
3. **Writes App Store metadata** — description, keywords, subtitle, release notes, URLs
4. **Archives and uploads** the binary to App Store Connect
5. **Uploads metadata + screenshots** via Fastlane
6. **Prepares everything** so the user just presses "Submit for Review"

## Prerequisites

- **Xcode** with command line tools
- **Fastlane**: `brew install fastlane` or `gem install fastlane`
- **Node.js** (for screenshot generation and auth testing)
- **Puppeteer**: `npm install puppeteer` (in the project directory)
- **jsonwebtoken**: `npm install jsonwebtoken` (in the skill scripts directory)
- **App Store Connect API Key** — a `.p8` file with Admin or App Manager role

### First-time setup

```bash
cd SKILL_DIR/scripts && npm install jsonwebtoken
```

## Workflow

### Step 1 — Detect the project

Run from the app's project root:

```bash
bash SKILL_DIR/scripts/detect-project.sh
```

This outputs:
- Project type (`.xcodeproj` or `.xcworkspace`)
- Available schemes and their bundle IDs
- Current version and build numbers
- Team ID
- Supported platforms per scheme

**Identify from the output:**
- Which **scheme** to use (e.g., `MyApp` for iOS, `MyApp-macOS` for macOS)
- The **bundle ID** (e.g., `com.example.myapp`)
- The **version** (e.g., `1.2`)
- The **team ID** (e.g., `67KC823C9A`)

### Step 2 — Locate or set up API credentials

The user must provide an **App Store Connect API Key**. Required values:

| Value | Where to find it |
|-------|-------------------|
| **Key ID** | Shown in the key list, or in the `.p8` filename (`AuthKey_<KEY_ID>.p8`) |
| **Issuer ID** | UUID at the top of [Users & Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api) |
| **Key file** | The `.p8` file downloaded when the key was created |

Keys are created at [App Store Connect → Users & Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api). The key needs **Admin** or **App Manager** role.

**Test the credentials:**

```bash
node SKILL_DIR/scripts/test-auth.mjs \
  --key-id <KEY_ID> \
  --issuer-id <ISSUER_ID> \
  --key-path <path/to/AuthKey.p8>
```

This lists all apps in the account on success, or prints the error on failure.

### Step 3 — Generate marketing screenshots

This step uses the `appstore-screenshots` skill. If the user already has marketing screenshots, skip to Step 4.

All screenshots are organized under `design/screenshots/v{VERSION}/` — see the `appstore-screenshots` skill for the full versioned layout. Set up the version directory first:

```bash
VERSION="1.2"  # from Xcode project
mkdir -p design/screenshots/v${VERSION}/{appstore/{iphone-65,ipad-129,mac},raw/{iphone,ipad},configs}
```

If the user has **raw app screenshots** (from the simulator or device), place them in `raw/iphone/` or `raw/ipad/`, then generate marketing slides:

```bash
cd design/screenshots/v${VERSION}

# Generate HTML from config
node APPSTORE_SCREENSHOTS_SKILL_DIR/scripts/generate.mjs configs/config-ios.json -o configs/slides-ios.html

# Capture PNGs into the platform-specific appstore/ directory
node APPSTORE_SCREENSHOTS_SKILL_DIR/scripts/capture.mjs configs/slides-ios.html -o ./appstore/iphone-65 --prefix appstore-ios-slide
node APPSTORE_SCREENSHOTS_SKILL_DIR/scripts/capture.mjs configs/slides-ipad.html -o ./appstore/ipad-129 --prefix appstore-ipad-slide
node APPSTORE_SCREENSHOTS_SKILL_DIR/scripts/capture.mjs configs/slides-mac.html -o ./appstore/mac --prefix appstore-mac-slide
```

**Platform-specific screenshot sizes:**

| Platform | Required size | Display type in ASC | Output dir |
|----------|--------------|---------------------|------------|
| iPhone 6.5" | 1242×2688 | `APP_IPHONE_65` | `appstore/iphone-65/` |
| iPhone 6.7" | 1290×2796 | `APP_IPHONE_67` | `appstore/iphone-67/` |
| iPad 12.9" | 2048×2732 | `APP_IPAD_PRO_129` | `appstore/ipad-129/` |
| macOS | 2880×1800 | `APP_DESKTOP` | `appstore/mac/` |

For multi-platform apps, create separate configs and output directories per platform. Only create the subdirectories you need.

### Step 4 — Write metadata

Create the fastlane metadata files. The agent should write compelling App Store copy based on the app's README, features, and purpose.

```bash
bash SKILL_DIR/scripts/generate-metadata.sh \
  --name "My App" \
  --subtitle "Short tagline (30 chars max)" \
  --keywords "keyword1,keyword2,keyword3" \
  --support-url "https://myapp.com" \
  --privacy-url "https://myapp.com/privacy" \
  --marketing-url "https://myapp.com" \
  --copyright "2025 Developer Name" \
  --primary-category "MZGenre.HealthAndFitness" \
  --secondary-category "MZGenre.Productivity" \
  -o fastlane/metadata
```

Then **write the description** directly to `fastlane/metadata/en-US/description.txt`. The description should be:
- **4000 characters max**
- Start with a compelling one-liner
- Use ALL CAPS section headers (HOW IT WORKS, FEATURES, etc.)
- Use bullet points (•) for feature lists
- End with a PRIVACY section if the app handles sensitive data

Also write `fastlane/metadata/en-US/release_notes.txt` with "What's New" text.

**App Store categories reference:**

| Category | Value |
|----------|-------|
| Health & Fitness | `MZGenre.HealthAndFitness` |
| Productivity | `MZGenre.Productivity` |
| Utilities | `MZGenre.Utilities` |
| Developer Tools | `MZGenre.DeveloperTools` |
| Education | `MZGenre.Education` |
| Finance | `MZGenre.Finance` |
| Photo & Video | `MZGenre.PhotoAndVideo` |
| Social Networking | `MZGenre.SocialNetworking` |
| Entertainment | `MZGenre.Entertainment` |
| Music | `MZGenre.Music` |
| Lifestyle | `MZGenre.Lifestyle` |
| Business | `MZGenre.Business` |
| Travel | `MZGenre.Travel` |
| Food & Drink | `MZGenre.FoodAndDrink` |
| Weather | `MZGenre.Weather` |
| Reference | `MZGenre.Reference` |
| Sports | `MZGenre.Sports` |
| News | `MZGenre.News` |
| Games | `MZGenre.Games` |

### Step 5 — Copy screenshots into fastlane structure

Copy marketing screenshots from the versioned `appstore/` directories into fastlane:

```bash
# Copy all platform screenshots from the versioned folder
bash SKILL_DIR/scripts/copy-screenshots.sh \
  --source design/screenshots/v${VERSION}/appstore/iphone-65 \
  -o fastlane/screenshots

bash SKILL_DIR/scripts/copy-screenshots.sh \
  --source design/screenshots/v${VERSION}/appstore/ipad-129 \
  -o fastlane/screenshots

bash SKILL_DIR/scripts/copy-screenshots.sh \
  --source design/screenshots/v${VERSION}/appstore/mac \
  -o fastlane/screenshots
```

This copies all PNGs from each platform's output directory into `fastlane/screenshots/en-US/`. Only copy the platforms that apply to the current submission.

> **Note:** The versioned screenshots live in `design/screenshots/v{VERSION}/` (see the `appstore-screenshots` skill for the full layout). Previous versions remain as historical records.

### Step 6 — Generate the Fastfile

```bash
node SKILL_DIR/scripts/generate-fastfile.mjs \
  --bundle-id <BUNDLE_ID> \
  --key-id <KEY_ID> \
  --issuer-id <ISSUER_ID> \
  --key-path <path/to/AuthKey.p8> \
  --platform <ios|macos> \
  --version <VERSION> \
  -o fastlane/Fastfile
```

### Step 7 — Archive and upload the build

```bash
bash SKILL_DIR/scripts/archive-and-upload.sh \
  --project <path.xcodeproj> \
  --scheme <SCHEME> \
  --platform <ios|macos> \
  --team-id <TEAM_ID>
```

For workspaces, use `--workspace <path.xcworkspace>` instead of `--project`.

The build takes ~5 minutes to process on Apple's servers after upload.

### Step 8 — Upload metadata + screenshots to App Store Connect

```bash
cd <project-root>
fastlane <ios|mac> upload_all
```

This uploads:
- App name, subtitle, description, keywords
- Support URL, privacy URL, marketing URL
- Copyright, categories
- All screenshots

If screenshots fail with 500 errors (Apple's API is flaky), retry:

```bash
fastlane <ios|mac> upload_screenshots
```

### Step 9 — Verify

```bash
fastlane <ios|mac> info
```

Confirm:
- Version matches the build
- Screenshots are all uploaded
- State is `PREPARE_FOR_SUBMISSION`

### Step 10 — Manual steps (tell the user)

These items **cannot** be set via the API and must be completed on [App Store Connect](https://appstoreconnect.apple.com):

1. **Select the build** — once processing finishes, select it in the Build section
2. **Age Rating** — complete the content questionnaire
3. **App Review contact info** — name, phone, email
4. **Pricing** — set in Pricing & Availability (free or paid)

Once those are filled in, the user presses **Submit for Review**.

### Optional: Submit for review programmatically

If the user wants to skip the manual review step (all required fields must already be set):

```bash
fastlane <ios|mac> submit
```

## Multi-platform submissions

For apps that ship on multiple platforms (e.g., iOS + macOS):

1. Run the full workflow for **each platform separately**
2. Use **separate screenshot configs** (iOS config with `"platform": "ios"`, macOS config with `"platform": "macos"`)
3. Use **separate output directories** (e.g., `output-ios/`, `output-macos/`)
4. Generate **separate Fastfiles** or use a single Fastfile with both platform blocks
5. Archive and upload **each scheme separately** (e.g., `MyApp` for iOS, `MyApp-macOS` for macOS)

The metadata (description, keywords, etc.) is shared across platforms on App Store Connect — you only need to upload it once.

## Version management

- The **build version** (`CFBundleShortVersionString` in the Xcode project) must match the **version on App Store Connect**
- If they don't match, either:
  - Update the Xcode project version before archiving
  - Or let the `generate-fastfile.mjs` and `upload_all` lane create/update the ASC version to match
- The **build number** (`CFBundleVersion`) must be unique per version — increment it for each upload

## Troubleshooting

| Issue | Solution |
|-------|----------|
| API key returns 401 | Verify key ID, issuer ID, and that the key was created under App Store Connect API (not APNs/MusicKit) |
| Screenshots fail with 500 | Apple's API is flaky — retry. Usually works on second attempt |
| Build not selectable | Wait ~5 minutes for processing. Check for compliance warnings in ASC |
| "Release notes" skipped | First version of an app doesn't support release notes — this is expected |
| Archive fails signing | Ensure automatic signing is enabled and team ID is correct |
| Version mismatch | The build's `CFBundleShortVersionString` must match the ASC version |

## Scripts reference

| Script | Purpose |
|--------|---------|
| `scripts/detect-project.sh` | Detect Xcode project, schemes, versions, bundle IDs |
| `scripts/test-auth.mjs` | Validate App Store Connect API credentials |
| `scripts/generate-fastfile.mjs` | Generate a Fastfile for the app |
| `scripts/generate-metadata.sh` | Create metadata directory structure |
| `scripts/copy-screenshots.sh` | Copy screenshots into fastlane layout |
| `scripts/archive-and-upload.sh` | Archive, export, and upload build to ASC |

## Related skills

- **`appstore-screenshots`** — Generate marketing screenshots with device mockups and headlines
- **`ios-simulator-screenshots`** — Capture raw screenshots from the iOS Simulator
- **`ios-device-build`** — Build and run on a physical device (for testing before submission)

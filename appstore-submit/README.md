# App Store Submit

Submit an iOS, iPadOS, or macOS app to the App Store programmatically. Handles the full pipeline — project detection, building and uploading the binary, generating marketing screenshots, writing metadata, uploading everything to App Store Connect via Fastlane, and preparing for review.

## Prerequisites

- Xcode with command line tools
- Fastlane: `brew install fastlane`
- Node.js + Puppeteer (for screenshot generation)
- App Store Connect API Key (`.p8` file with Admin or App Manager role)

## Setup

```bash
cd scripts && npm install
```

## Pipeline

1. **Detect** — Identify Xcode project, schemes, bundle IDs, versions
2. **Screenshots** — Generate marketing screenshots with device mockups (delegates to `appstore-screenshots` skill)
3. **Metadata** — Write App Store description, keywords, subtitle, release notes
4. **Archive & Upload** — Build the binary and upload to App Store Connect
5. **Upload Metadata** — Push screenshots + metadata via Fastlane
6. **Prepare** — Everything ready for "Submit for Review"

## Key Scripts

| Script | Purpose |
|--------|---------|
| `scripts/detect-project.sh` | Detect Xcode project, schemes, versions |
| `scripts/test-auth.mjs` | Validate App Store Connect API credentials |
| `scripts/generate-fastfile.mjs` | Generate a Fastfile for the app |
| `scripts/generate-metadata.sh` | Create metadata directory structure |
| `scripts/copy-screenshots.sh` | Copy screenshots into fastlane layout |
| `scripts/archive-and-upload.sh` | Archive, export, and upload binary |

## Quick Start

```bash
# 1. Detect project
bash scripts/detect-project.sh

# 2. Test API credentials
node scripts/test-auth.mjs --key-id <KEY_ID> --issuer-id <ISSUER_ID> --key-path <path/to/AuthKey.p8>

# 3. Generate metadata
bash scripts/generate-metadata.sh --name "My App" --subtitle "Tagline" --keywords "k1,k2,k3" -o fastlane/metadata

# 4. Archive and upload
bash scripts/archive-and-upload.sh --project ./App.xcodeproj --scheme App --platform ios --team-id <TEAM_ID>

# 5. Upload everything to ASC
fastlane ios upload_all
```

See [SKILL.md](./SKILL.md) for the complete step-by-step workflow, multi-platform submissions, and troubleshooting.

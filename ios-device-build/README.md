# iOS & macOS Device Build

Build, install, and launch an iOS app on a connected physical iPhone/iPad, or build and launch a macOS app locally. Works with any Xcode project (`.xcodeproj`) or workspace (`.xcworkspace`).

## Prerequisites

- Xcode with command line tools
- **iOS**: Physical device connected via USB and trusted
- Valid Apple Developer signing configured in the project

## Quick Start

```bash
# 1. Detect project schemes and platforms
bash scripts/detect-project.sh

# 2. List connected iOS devices
bash scripts/list-devices.sh

# 3. Build and run on iOS device
bash scripts/build-and-run.sh \
  --project ./App.xcodeproj \
  --scheme App \
  --platform ios \
  --device-id <UDID> \
  --bundle-id com.example.app

# Or build and run macOS app
bash scripts/build-and-run.sh \
  --project ./App.xcodeproj \
  --scheme App \
  --platform macos \
  --bundle-id com.example.app
```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/detect-project.sh` | Detect project type, schemes, and platform support |
| `scripts/list-devices.sh` | List connected physical iOS devices |
| `scripts/build-and-run.sh` | Build, install, and launch the app |

Use `--workspace` instead of `--project` for `.xcworkspace` projects.

See [SKILL.md](./SKILL.md) for scheme selection guidance and troubleshooting.

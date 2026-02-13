---
name: ios-device-build
description: Build, install, and launch an iOS app on a connected physical iPhone/iPad, or build and launch a macOS app locally. Works with any Xcode project (.xcodeproj) or workspace (.xcworkspace). Use when the user wants to run, deploy, or test an iOS or macOS app.
---

# iOS & macOS Device Build

Build and run an iOS app on a connected physical device, or a macOS app locally, from any Xcode project directory.

## Prerequisites

- Xcode installed with command line tools
- **iOS**: Physical iOS device connected via USB/USB-C and trusted
- Valid Apple Developer signing (free or paid) configured in the project

## Workflow

### Step 1: Detect the project

Run the detection script from the project's root directory to identify the project type, available schemes, and supported platforms:

```bash
bash SKILL_DIR/scripts/detect-project.sh
```

This will output the project type (`xcodeproj` or `workspace`), path, available schemes, and per-scheme platform support (`iphoneos`, `macosx`, or both).

### Step 2 (iOS only): List connected devices

```bash
bash SKILL_DIR/scripts/list-devices.sh
```

This outputs connected physical iOS devices with their names and UDIDs. If multiple devices are listed, ask the user which one to target. Skip this step for macOS builds.

### Step 3: Get the bundle identifier

Extract the bundle ID from the detected project/scheme:

```bash
xcodebuild -project <path> -scheme <scheme> -showBuildSettings 2>/dev/null | grep PRODUCT_BUNDLE_IDENTIFIER | awk '{print $NF}'
```

Or for workspaces:

```bash
xcodebuild -workspace <path> -scheme <scheme> -showBuildSettings 2>/dev/null | grep PRODUCT_BUNDLE_IDENTIFIER | awk '{print $NF}'
```

### Step 4: Build, install, and launch

#### iOS (physical device)

```bash
bash SKILL_DIR/scripts/build-and-run.sh \
  --project <path.xcodeproj> \
  --scheme <scheme> \
  --platform ios \
  --device-id <UDID> \
  --bundle-id <bundle.id> \
  --configuration Debug
```

#### macOS (local)

```bash
bash SKILL_DIR/scripts/build-and-run.sh \
  --project <path.xcodeproj> \
  --scheme <scheme> \
  --platform macos \
  --bundle-id <bundle.id> \
  --configuration Debug
```

For workspaces, use `--workspace <path.xcworkspace>` instead of `--project`.

**Note:** `--device-id` is only required for iOS builds. For macOS builds it is ignored.

## Choosing the right scheme

- If the project has separate schemes for iOS and macOS (e.g. `MyApp` and `MyApp-macOS`), pick the scheme that matches the user's intent.
- If the user says "build for Mac" or "run on Mac", use the macOS scheme with `--platform macos`.
- If the user says "build" or "run on device", use the iOS scheme with `--platform ios`.

## Troubleshooting

- **No devices found**: Make sure the device is connected via USB and trusted. Check with `xcrun xctrace list devices`.
- **Signing errors**: The project must have a valid development team and signing configured. Check with `xcodebuild -showBuildSettings | grep -E 'DEVELOPMENT_TEAM|CODE_SIGN'`.
- **"Unable to install" errors**: Ensure the device is unlocked and the developer profile is trusted on-device (Settings > General > VPN & Device Management).
- **`devicectl` not found**: Requires Xcode 15+ and iOS 17+. For older setups, install `ios-deploy` via `brew install ios-deploy` and use `ios-deploy --bundle <path.app>` instead.
- **macOS app won't launch**: Check that the scheme's `SUPPORTED_PLATFORMS` includes `macosx`. Verify signing with `codesign --verify --deep --strict <path.app>`.

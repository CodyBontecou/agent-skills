# iOS Simulator Screenshots

Capture screenshots of every screen in an iOS app by building it, launching it in the iOS Simulator, and navigating through each view using accessibility-driven interaction. Produces clean, high-resolution PNG screenshots with a professional status bar (9:41, full battery, full signal).

## Prerequisites

- Xcode with iOS Simulator runtimes
- idb (iOS Development Bridge): `pip install fb-idb` or `brew install idb-companion`
- An iOS project that builds for Simulator

## Workflow

```bash
# 1. Detect the project
bash scripts/detect-project.sh

# 2. Boot a simulator
bash scripts/boot-simulator.sh --device "iPhone 16 Pro"

# 3. Clean up the status bar
bash scripts/cleanup-status-bar.sh

# 4. Build and install
bash scripts/build-and-install.sh --project ./App.xcodeproj --scheme App --udid <UDID>

# 5. Navigate and capture (repeat for each screen)
bash scripts/sim-screenshot.sh ./screenshots/01-home.png --clean-status-bar
bash scripts/sim-interact.sh describe    # inspect accessibility tree
bash scripts/sim-interact.sh tap <x> <y> # navigate to next screen
bash scripts/sim-screenshot.sh ./screenshots/02-detail.png --clean-status-bar
```

## Interaction Commands

| Command | Description |
|---------|-------------|
| `describe` | Dump the accessibility tree (labels, frames, types) |
| `tap <x> <y>` | Tap at coordinates (device points) |
| `swipe <x1> <y1> <x2> <y2>` | Swipe gesture |
| `text "<string>"` | Type into focused text field |
| `back` | iOS swipe-from-left-edge gesture |
| `scroll-down` / `scroll-up` | Scroll the current view |
| `home` | Press home button |

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/detect-project.sh` | Find Xcode project and schemes |
| `scripts/boot-simulator.sh` | Boot or reuse a simulator device |
| `scripts/build-and-install.sh` | Build and install on simulator |
| `scripts/sim-screenshot.sh` | Capture a screenshot |
| `scripts/sim-interact.sh` | Tap, swipe, type, describe |
| `scripts/cleanup-status-bar.sh` | Set or clear professional status bar |

Screenshots from this skill are ideal input for the [appstore-screenshots](../appstore-screenshots) skill.

See [SKILL.md](./SKILL.md) for navigation strategy, recommended devices, and troubleshooting.

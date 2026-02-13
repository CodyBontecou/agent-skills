---
name: ios-simulator-screenshots
description: Capture screenshots of every screen in an iOS app by building it, launching it in the iOS Simulator, and navigating through each view using accessibility-driven interaction. Produces clean, high-resolution PNG screenshots with a professional status bar. Use when the user wants raw app screenshots from a simulator, screen captures for documentation, or source images for the appstore-screenshots skill.
---

# iOS Simulator Screenshots

Automatically build, launch, and navigate through an iOS app in the Simulator to capture high-resolution screenshots of every screen. Uses `idb` (Meta's iOS Development Bridge) for reliable touch input, accessibility inspection, and screenshot capture.

## Prerequisites

- **Xcode** with iOS Simulator runtimes installed
- **idb** (iOS Development Bridge): `pip install fb-idb` or `brew install idb-companion`
- An iOS project (`.xcodeproj` or `.xcworkspace`) that builds for Simulator

## Workflow

### Step 1 — Detect the project

From the app's project root directory:

```bash
bash SKILL_DIR/scripts/detect-project.sh
```

This outputs the project type, path, and available schemes. Pick the main app scheme.

### Step 2 — Boot a simulator

```bash
bash SKILL_DIR/scripts/boot-simulator.sh --device "iPhone 16 Pro"
```

This boots the specified device (or reuses an already-booted one). Note the `UDID=` line in the output.

**Recommended devices for screenshots:**

| Device | Points | Pixels (3x) | Use case |
|--------|--------|-------------|----------|
| iPhone 16 Pro | 393×852 | 1179×2556 | Standard 6.1" |
| iPhone 16 Pro Max | 430×932 | 1290×2796 | 6.7" App Store required |
| iPhone 16 | 393×852 | 1179×2556 | Standard |
| iPhone 15 Pro | 393×852 | 1179×2556 | Standard |

### Step 3 — Clean up the status bar

```bash
bash SKILL_DIR/scripts/cleanup-status-bar.sh
```

This overrides the status bar to show `9:41`, full battery, full WiFi signal — matching Apple's official screenshot style.

### Step 4 — Build and install the app

```bash
bash SKILL_DIR/scripts/build-and-install.sh \
  --project ./MyApp.xcodeproj \
  --scheme MyApp \
  --udid <UDID>
```

For workspaces, use `--workspace ./MyApp.xcworkspace` instead of `--project`.

Note the `BUNDLE_ID=` in the output — you'll need it to relaunch later.

### Step 5 — Navigate and capture screenshots

This is the core loop. The agent navigates through the app screen by screen, taking a screenshot at each stop.

#### 5a — Take a screenshot

```bash
bash SKILL_DIR/scripts/sim-screenshot.sh ./screenshots/01-home.png --clean-status-bar
```

Then **view the screenshot** to understand what's on screen:

```bash
# Use the Read tool to view the PNG
```

#### 5b — Inspect the accessibility tree

To understand what's tappable and where things are on screen:

```bash
bash SKILL_DIR/scripts/sim-interact.sh describe
```

This returns a JSON array of all accessibility elements with their:
- `AXLabel` — the element's text/label
- `frame` — `{x, y, width, height}` in device points
- `type` — element type (Button, StaticText, Cell, etc.)
- `role` — accessibility role
- `enabled` — whether the element is interactive

**To find a tap target**, look for the element's `frame` and tap at its center:
- Center X = `frame.x + frame.width / 2`
- Center Y = `frame.y + frame.height / 2`

#### 5c — Interact with the app

**Tap at coordinates** (device points):
```bash
bash SKILL_DIR/scripts/sim-interact.sh tap <x> <y>
```

**Swipe** (for scrolling, page navigation, dismissing):
```bash
bash SKILL_DIR/scripts/sim-interact.sh swipe <x1> <y1> <x2> <y2>
```

**Type text** (into a focused text field):
```bash
bash SKILL_DIR/scripts/sim-interact.sh text "Hello world"
```

**Go back** (iOS swipe-from-left-edge gesture):
```bash
bash SKILL_DIR/scripts/sim-interact.sh back
```

**Scroll down / up**:
```bash
bash SKILL_DIR/scripts/sim-interact.sh scroll-down
bash SKILL_DIR/scripts/sim-interact.sh scroll-up
```

**Press home button**:
```bash
bash SKILL_DIR/scripts/sim-interact.sh home
```

**Press hardware button**:
```bash
bash SKILL_DIR/scripts/sim-interact.sh button HOME
bash SKILL_DIR/scripts/sim-interact.sh button LOCK
bash SKILL_DIR/scripts/sim-interact.sh button SIDE_BUTTON
```

#### 5d — Wait for animations

After any interaction, wait briefly for animations to settle before capturing:

```bash
sleep 0.5
```

For longer transitions (sheet presentations, tab switches with data loading):

```bash
sleep 1
```

#### 5e — Repeat for each screen

Follow this loop for every screen in the app:

1. **Screenshot** the current screen → view it
2. **Describe** the accessibility tree to find navigation targets
3. **Tap** a button/cell/tab to navigate to the next screen
4. **Wait** for the transition to complete
5. **Screenshot** the new screen → view it
6. **Go back** or navigate to the next area

### Step 6 — Relaunch if needed

If the app gets into a bad state or you need to start fresh:

```bash
xcrun simctl terminate booted <bundle-id>
xcrun simctl launch booted <bundle-id>
```

### Step 7 — Reset status bar (optional)

After capturing, restore the real status bar:

```bash
bash SKILL_DIR/scripts/cleanup-status-bar.sh --clear
```

## Navigation strategy

When exploring an unfamiliar app, follow this order:

1. **Home / main screen** — the first thing users see after launch
2. **Tab bar items** — tap each tab left to right
3. **List items / cells** — tap the first item in any list to go to detail views
4. **Settings / profile** — usually in a tab or gear icon
5. **Modals / sheets** — look for "+" buttons, compose buttons, or action triggers
6. **Onboarding / paywall** — if the app shows these on launch, capture them first

**Tips for reliable navigation:**
- Always use the accessibility tree (`describe`) to find exact tap coordinates
- Tap at the **center** of the element's frame
- After tapping, take a screenshot to verify you arrived at the expected screen
- If a tap doesn't work, the element might be behind a scroll view — try scrolling first
- For tab bars, the tabs are usually at y > 800 (bottom of screen)
- For navigation bar buttons, look at y < 60 (top of screen)

## Screenshot naming convention

Use descriptive, numbered filenames:

```
screenshots/
  01-home.png
  02-detail.png
  03-settings.png
  04-profile.png
  05-compose.png
  06-search.png
```

## Using with appstore-screenshots skill

The screenshots produced by this skill are raw app captures — perfect as input for the `appstore-screenshots` skill which wraps them in marketing frames with headlines. Workflow:

1. **This skill** → captures raw PNGs from the simulator
2. **appstore-screenshots** → wraps them in device mockups with marketing copy

## Passing a UDID

All scripts accept `--udid <udid>` to target a specific simulator. If omitted, they default to `booted` (whichever simulator is currently running). When multiple simulators are booted, always pass `--udid`.

## Troubleshooting

- **`idb` not found**: Install with `pip install fb-idb` (Python 3.10+) or `brew install idb-companion` for the companion process
- **`idb ui tap` does nothing**: The app may have an overlay (alert, permission dialog). Use `describe` to check what's on screen and dismiss it first
- **Build fails for simulator**: Make sure the scheme supports the `iOS Simulator` destination. Check with `xcodebuild -scheme <scheme> -showdestinations`
- **Blank screenshot**: The app may still be loading. Increase the sleep duration before capturing
- **Status bar override not working**: Requires iOS 13+ simulators. Check `xcrun simctl status_bar booted list`
- **Coordinates don't match**: The accessibility tree uses device points (not pixels). For iPhone 16 Pro, the screen is 393×852 points. Screenshots are in pixels (3x = 1179×2556)

## Scripts reference

| Script | Purpose |
|--------|---------|
| `scripts/detect-project.sh` | Find the Xcode project type and schemes |
| `scripts/boot-simulator.sh` | Boot (or reuse) a simulator device |
| `scripts/build-and-install.sh` | Build the app and install on a simulator |
| `scripts/sim-screenshot.sh` | Capture a screenshot from the simulator |
| `scripts/sim-interact.sh` | Tap, swipe, type, describe — all interactions |
| `scripts/cleanup-status-bar.sh` | Set or clear professional status bar |

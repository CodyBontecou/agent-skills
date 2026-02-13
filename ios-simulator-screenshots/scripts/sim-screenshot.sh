#!/bin/bash
# Take a screenshot from the booted iOS Simulator
# Usage: sim-screenshot.sh <output-path> [--udid <udid>] [--clean-status-bar]
#
# Options:
#   --udid              Target a specific simulator (default: booted)
#   --clean-status-bar  Override the status bar to show 9:41, full battery, full signal

set -euo pipefail

OUTPUT=""
UDID="booted"
CLEAN_STATUS_BAR=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --udid)             UDID="$2";          shift 2 ;;
        --clean-status-bar) CLEAN_STATUS_BAR=true; shift ;;
        *)
            if [ -z "$OUTPUT" ]; then
                OUTPUT="$1"; shift
            else
                echo "Unknown option: $1"; exit 1
            fi
            ;;
    esac
done

if [ -z "$OUTPUT" ]; then
    echo "Usage: sim-screenshot.sh <output-path> [--udid <udid>] [--clean-status-bar]"
    exit 1
fi

# Create output directory if needed
mkdir -p "$(dirname "$OUTPUT")"

# Clean up status bar for professional screenshots
if [ "$CLEAN_STATUS_BAR" = true ]; then
    xcrun simctl status_bar "$UDID" override \
        --time "9:41" \
        --batteryLevel 100 \
        --batteryState charged \
        --dataNetwork wifi \
        --wifiMode active \
        --wifiBars 3 \
        --cellularMode active \
        --cellularBars 4 \
        --operatorName "" 2>/dev/null || true
fi

# Small delay to let status bar update render
sleep 0.3

# Take the screenshot
xcrun simctl io "$UDID" screenshot --type=png "$OUTPUT" 2>/dev/null

echo "✅ Screenshot saved: $OUTPUT"

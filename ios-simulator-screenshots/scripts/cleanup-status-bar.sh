#!/bin/bash
# Set or clear the simulator status bar for clean screenshots
# Usage: cleanup-status-bar.sh [--clear] [--udid <udid>]
#
# Default: Sets status bar to 9:41, full battery, full WiFi, no carrier
# --clear: Removes all status bar overrides

set -euo pipefail

UDID="booted"
CLEAR=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --udid)  UDID="$2"; shift 2 ;;
        --clear) CLEAR=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ "$CLEAR" = true ]; then
    xcrun simctl status_bar "$UDID" clear
    echo "✅ Status bar overrides cleared"
else
    xcrun simctl status_bar "$UDID" override \
        --time "9:41" \
        --batteryLevel 100 \
        --batteryState charged \
        --dataNetwork wifi \
        --wifiMode active \
        --wifiBars 3 \
        --cellularMode active \
        --cellularBars 4 \
        --operatorName ""
    echo "✅ Status bar cleaned: 9:41, full battery, WiFi"
fi

#!/bin/bash
# Boot an iOS Simulator device and return its UDID
# Usage: boot-simulator.sh [--device "iPhone 16 Pro"] [--runtime "iOS 18.2"]
#
# If a matching device is already booted, returns its UDID without rebooting.
# If no matching device exists, creates one.

set -euo pipefail

DEVICE_NAME="iPhone 16 Pro"
RUNTIME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --device)  DEVICE_NAME="$2"; shift 2 ;;
        --runtime) RUNTIME="$2";     shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "=== Simulator Boot ==="
echo "  Requested device: $DEVICE_NAME"

# Check if there's already a booted device matching the name
BOOTED_UDID=$(xcrun simctl list devices booted -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d['name'] == '$DEVICE_NAME' and d['state'] == 'Booted':
            print(d['udid'])
            sys.exit(0)
" 2>/dev/null || true)

if [ -n "$BOOTED_UDID" ]; then
    echo "  Already booted: $BOOTED_UDID"
    echo "UDID=$BOOTED_UDID"
    exit 0
fi

# Find the latest iOS runtime if not specified
if [ -z "$RUNTIME" ]; then
    RUNTIME=$(xcrun simctl list runtimes iOS -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
runtimes = data.get('runtimes', [])
if runtimes:
    print(runtimes[-1]['identifier'])
" 2>/dev/null)
    echo "  Auto-detected runtime: $RUNTIME"
fi

# Find an existing (shutdown) device matching the name
EXISTING_UDID=$(xcrun simctl list devices -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d['name'] == '$DEVICE_NAME' and d['isAvailable']:
            print(d['udid'])
            sys.exit(0)
" 2>/dev/null || true)

if [ -z "$EXISTING_UDID" ]; then
    echo "  Creating new simulator: $DEVICE_NAME ($RUNTIME)"
    EXISTING_UDID=$(xcrun simctl create "$DEVICE_NAME" "$DEVICE_NAME" "$RUNTIME" 2>&1)
    echo "  Created: $EXISTING_UDID"
fi

echo "  Booting: $EXISTING_UDID"
xcrun simctl boot "$EXISTING_UDID" 2>/dev/null || true

# Open Simulator.app so the window is visible
open -a Simulator

# Wait for the device to finish booting
echo "  Waiting for boot to complete..."
xcrun simctl bootstatus "$EXISTING_UDID" -b 2>/dev/null || true

echo "  ✅ Simulator booted"
echo "UDID=$EXISTING_UDID"

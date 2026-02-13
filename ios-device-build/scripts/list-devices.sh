#!/bin/bash
# List connected physical iOS devices
set -euo pipefail

echo "=== Connected Physical iOS Devices ==="
xcrun xctrace list devices 2>&1 | awk '/== Devices ==/{found=1; next} /== Devices Offline ==|== Simulators ==/{found=0} found && NF' | grep -v "$(scutil --get ComputerName)" || true

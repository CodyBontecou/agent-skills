#!/bin/bash
# Build an iOS app and install it on a simulator
# Usage: build-and-install.sh --project|--workspace <path> --scheme <scheme> --udid <simulator-udid> [--configuration Debug]
#
# After building, installs the .app on the simulator and launches it.

set -euo pipefail

PROJECT_FLAG=""
PROJECT_PATH=""
SCHEME=""
UDID="booted"
CONFIGURATION="Debug"
BUNDLE_ID=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)       PROJECT_FLAG="-project";   PROJECT_PATH="$2"; shift 2 ;;
        --workspace)     PROJECT_FLAG="-workspace";  PROJECT_PATH="$2"; shift 2 ;;
        --scheme)        SCHEME="$2";        shift 2 ;;
        --udid)          UDID="$2";          shift 2 ;;
        --configuration) CONFIGURATION="$2"; shift 2 ;;
        --bundle-id)     BUNDLE_ID="$2";     shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -z "$PROJECT_FLAG" ] || [ -z "$PROJECT_PATH" ] || [ -z "$SCHEME" ]; then
    echo "Error: Missing required arguments"
    echo "Usage: build-and-install.sh --project|--workspace <path> --scheme <scheme> --udid <udid> [--configuration Debug]"
    exit 1
fi

DERIVED_DATA="build/DerivedData"

echo ""
echo "=== Building for Simulator ==="
echo "  Project:       $PROJECT_PATH"
echo "  Scheme:        $SCHEME"
echo "  Simulator:     $UDID"
echo "  Configuration: $CONFIGURATION"
echo ""

xcodebuild \
    $PROJECT_FLAG "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,id=$UDID" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA" \
    build 2>&1

if [ $? -ne 0 ]; then
    echo ""
    echo "=== BUILD FAILED ==="
    exit 1
fi

echo ""
echo "=== Build Succeeded ==="

# Find the .app bundle (iphonesimulator variant)
APP_PATH=$(find "$DERIVED_DATA" -name "*.app" -path "*/Build/Products/${CONFIGURATION}-iphonesimulator/*" -not -path "*/PlugIns/*" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find .app bundle in DerivedData"
    echo "Searched: $DERIVED_DATA/Build/Products/${CONFIGURATION}-iphonesimulator/"
    exit 1
fi

echo "  App: $APP_PATH"

# Extract bundle ID if not provided
if [ -z "$BUNDLE_ID" ]; then
    BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null || echo "")
    if [ -z "$BUNDLE_ID" ]; then
        BUNDLE_ID=$(xcodebuild $PROJECT_FLAG "$PROJECT_PATH" -scheme "$SCHEME" -showBuildSettings 2>/dev/null | grep PRODUCT_BUNDLE_IDENTIFIER | awk '{print $NF}')
    fi
fi

echo "  Bundle ID: $BUNDLE_ID"

echo ""
echo "=== Installing on Simulator ==="
xcrun simctl install "$UDID" "$APP_PATH" 2>&1

echo ""
echo "=== Launching ==="
xcrun simctl launch "$UDID" "$BUNDLE_ID" 2>&1

echo ""
echo "=== ✅ App running on simulator ==="
echo "BUNDLE_ID=$BUNDLE_ID"
echo "APP_PATH=$APP_PATH"

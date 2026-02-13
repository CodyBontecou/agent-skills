#!/bin/bash
# Build an iOS or macOS app and install+launch it
# Usage: build-and-run.sh --project|--workspace <path> --scheme <scheme> --platform ios|macos [--device-id <udid>] --bundle-id <bundle_id> [--configuration Debug|Release]

set -euo pipefail

PROJECT_FLAG=""
PROJECT_PATH=""
SCHEME=""
PLATFORM="ios"
DEVICE_ID=""
BUNDLE_ID=""
CONFIGURATION="Debug"

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)        PROJECT_FLAG="-project";    PROJECT_PATH="$2"; shift 2 ;;
        --workspace)      PROJECT_FLAG="-workspace";  PROJECT_PATH="$2"; shift 2 ;;
        --scheme)         SCHEME="$2";         shift 2 ;;
        --platform)       PLATFORM="$2";       shift 2 ;;
        --device-id)      DEVICE_ID="$2";      shift 2 ;;
        --bundle-id)      BUNDLE_ID="$2";      shift 2 ;;
        --configuration)  CONFIGURATION="$2";  shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Validate common required args
if [ -z "$PROJECT_FLAG" ] || [ -z "$PROJECT_PATH" ] || [ -z "$SCHEME" ] || [ -z "$BUNDLE_ID" ]; then
    echo "Error: Missing required arguments"
    echo "Usage: build-and-run.sh --project|--workspace <path> --scheme <scheme> --platform ios|macos [--device-id <udid>] --bundle-id <bundle_id> [--configuration Debug|Release]"
    exit 1
fi

# Platform-specific validation and destination
case "$PLATFORM" in
    ios)
        if [ -z "$DEVICE_ID" ]; then
            echo "Error: --device-id is required for iOS builds"
            exit 1
        fi
        DESTINATION="platform=iOS,id=$DEVICE_ID"
        PRODUCTS_SUBDIR="${CONFIGURATION}-iphoneos"
        ;;
    macos)
        DESTINATION="platform=macOS"
        PRODUCTS_SUBDIR="${CONFIGURATION}"
        ;;
    *)
        echo "Error: --platform must be 'ios' or 'macos'"
        exit 1
        ;;
esac

DERIVED_DATA="build/DerivedData"

echo ""
echo "=== Building ==="
echo "  Project:       $PROJECT_PATH"
echo "  Scheme:        $SCHEME"
echo "  Platform:      $PLATFORM"
[ "$PLATFORM" = "ios" ] && echo "  Device:        $DEVICE_ID"
echo "  Configuration: $CONFIGURATION"
echo "  Bundle ID:     $BUNDLE_ID"
echo "  Destination:   $DESTINATION"
echo ""

xcodebuild \
    $PROJECT_FLAG "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA" \
    -allowProvisioningUpdates \
    build 2>&1

if [ $? -ne 0 ]; then
    echo ""
    echo "=== BUILD FAILED ==="
    exit 1
fi

echo ""
echo "=== Build Succeeded ==="

# Find the .app bundle
APP_PATH=$(find "$DERIVED_DATA" -name "*.app" -path "*/Build/Products/${PRODUCTS_SUBDIR}/*" -not -path "*/dSYMs/*" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find .app bundle in DerivedData"
    echo "Searched: $DERIVED_DATA/Build/Products/${PRODUCTS_SUBDIR}/"
    exit 1
fi

echo "  App: $APP_PATH"

case "$PLATFORM" in
    ios)
        echo ""
        echo "=== Installing on device ==="
        xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH" 2>&1

        echo ""
        echo "=== Launching on device ==="
        xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID" 2>&1

        echo ""
        echo "=== Done! App is running on device ==="
        ;;
    macos)
        echo ""
        echo "=== Launching macOS app ==="
        open "$APP_PATH"

        echo ""
        echo "=== Done! App is running on Mac ==="
        ;;
esac

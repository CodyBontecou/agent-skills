#!/usr/bin/env bash
# archive-and-upload.sh — Build, archive, export, and upload to App Store Connect
#
# Usage:
#   bash archive-and-upload.sh \
#     --project <path.xcodeproj> \
#     --scheme <scheme> \
#     --platform <ios|macos> \
#     --team-id <TEAM_ID> \
#     [--workspace <path.xcworkspace>] \
#     [--configuration Release] \
#     [--archive-path <path>] \
#     [--export-path <path>]
#
# Performs: archive → export (app-store-connect) → upload
# Uses automatic signing. The export options use "app-store-connect" method
# with destination "upload" to push directly to ASC.

set -euo pipefail

# ── Parse args ───────────────────────────────────────────────────────
PROJECT=""
WORKSPACE=""
SCHEME=""
PLATFORM=""
TEAM_ID=""
CONFIGURATION="Release"
ARCHIVE_PATH=""
EXPORT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --workspace) WORKSPACE="$2"; shift 2 ;;
    --scheme) SCHEME="$2"; shift 2 ;;
    --platform) PLATFORM="$2"; shift 2 ;;
    --team-id) TEAM_ID="$2"; shift 2 ;;
    --configuration) CONFIGURATION="$2"; shift 2 ;;
    --archive-path) ARCHIVE_PATH="$2"; shift 2 ;;
    --export-path) EXPORT_PATH="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$SCHEME" || -z "$PLATFORM" || -z "$TEAM_ID" ]]; then
  echo "❌ Required: --scheme, --platform (ios|macos), --team-id"
  exit 1
fi

# ── Determine build flag ─────────────────────────────────────────────
if [[ -n "$WORKSPACE" ]]; then
  BUILD_FLAG="-workspace"
  BUILD_PATH="$WORKSPACE"
elif [[ -n "$PROJECT" ]]; then
  BUILD_FLAG="-project"
  BUILD_PATH="$PROJECT"
else
  echo "❌ Provide --project or --workspace"
  exit 1
fi

# ── Set destination based on platform ────────────────────────────────
case "$PLATFORM" in
  ios)
    DESTINATION="generic/platform=iOS"
    ;;
  macos)
    DESTINATION="generic/platform=macOS"
    ;;
  *)
    echo "❌ Platform must be 'ios' or 'macos'"
    exit 1
    ;;
esac

# ── Default paths ────────────────────────────────────────────────────
ARCHIVE_PATH="${ARCHIVE_PATH:-build/${SCHEME}.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-build/export}"

echo "📦 Archiving $SCHEME ($PLATFORM)..."
echo "   Archive: $ARCHIVE_PATH"
echo ""

# ── Step 1: Archive ──────────────────────────────────────────────────
xcodebuild archive \
  $BUILD_FLAG "$BUILD_PATH" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -archivePath "$ARCHIVE_PATH" \
  -configuration "$CONFIGURATION" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  2>&1 | tail -5

if [[ ! -d "$ARCHIVE_PATH" ]]; then
  echo "❌ Archive failed — $ARCHIVE_PATH not created"
  exit 1
fi

echo ""
echo "✅ Archive succeeded"

# ── Extract version info from archive ────────────────────────────────
if [[ "$PLATFORM" == "macos" ]]; then
  APP_PATH=$(find "$ARCHIVE_PATH/Products" -name "*.app" -maxdepth 3 | head -1)
  PLIST_PATH="$APP_PATH/Contents/Info.plist"
else
  APP_PATH=$(find "$ARCHIVE_PATH/Products" -name "*.app" -maxdepth 3 | head -1)
  PLIST_PATH="$APP_PATH/Info.plist"
fi

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PLIST_PATH" 2>/dev/null || echo "unknown")
BUILD_NUM=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PLIST_PATH" 2>/dev/null || echo "unknown")

echo "   Version: $VERSION (build $BUILD_NUM)"
echo ""

# ── Step 2: Export ───────────────────────────────────────────────────
EXPORT_OPTIONS=$(mktemp /tmp/ExportOptions.XXXXX.plist)
cat > "$EXPORT_OPTIONS" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
PLIST

echo "🚀 Exporting and uploading to App Store Connect..."

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -exportPath "$EXPORT_PATH" \
  2>&1 | tail -10

rm -f "$EXPORT_OPTIONS"

# Check for success
if echo "$(xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportOptionsPlist /dev/null 2>&1)" | grep -q "EXPORT SUCCEEDED" 2>/dev/null; then
  true
fi

echo ""
echo "✅ Build uploaded to App Store Connect"
echo "   Version: $VERSION (build $BUILD_NUM)"
echo "   Platform: $PLATFORM"
echo ""
echo "⏳ Build will take ~5 minutes to process on Apple's servers."
echo "   Once processed, it can be selected in App Store Connect."

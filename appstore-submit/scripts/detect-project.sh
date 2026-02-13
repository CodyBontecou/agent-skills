#!/usr/bin/env bash
# detect-project.sh — Detect Xcode project, schemes, targets, bundle IDs, and versions
#
# Usage: bash detect-project.sh [--dir <project-dir>]
#
# Outputs structured info about the project for use by the submission skill.

set -eo pipefail

DIR="."
if [[ "${1:-}" == "--dir" ]]; then DIR="${2:-.}"; fi

cd "$DIR"

# Find project or workspace
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" ! -path "*/xcodeproj/*" | head -1)
PROJECT=$(find . -maxdepth 1 -name "*.xcodeproj" | head -1)

if [[ -n "$WORKSPACE" ]]; then
  PROJECT_TYPE="workspace"
  PROJECT_PATH="$WORKSPACE"
  BUILD_FLAG="-workspace"
elif [[ -n "$PROJECT" ]]; then
  PROJECT_TYPE="xcodeproj"
  PROJECT_PATH="$PROJECT"
  BUILD_FLAG="-project"
else
  echo "❌ No .xcodeproj or .xcworkspace found in $DIR"
  exit 1
fi

echo "PROJECT_TYPE=$PROJECT_TYPE"
echo "PROJECT_PATH=$PROJECT_PATH"
echo ""

# List schemes
echo "=== Schemes ==="
SCHEMES=$(xcodebuild $BUILD_FLAG "$PROJECT_PATH" -list 2>/dev/null | awk '/Schemes:/,/^$/' | grep -v "Schemes:" | sed 's/^[[:space:]]*//' | grep -v '^$')
echo "$SCHEMES"
echo ""

# For each scheme, get bundle ID, version, and supported platforms
echo "=== Scheme Details ==="
while IFS= read -r scheme; do
  [[ -z "$scheme" ]] && continue
  echo "--- $scheme ---"

  SETTINGS=$(xcodebuild $BUILD_FLAG "$PROJECT_PATH" -scheme "$scheme" -showBuildSettings 2>/dev/null)

  BUNDLE_ID=$(echo "$SETTINGS" | grep " PRODUCT_BUNDLE_IDENTIFIER " | head -1 | awk '{print $NF}')
  VERSION=$(echo "$SETTINGS" | grep "MARKETING_VERSION" | head -1 | awk '{print $NF}')
  BUILD_NUM=$(echo "$SETTINGS" | grep "CURRENT_PROJECT_VERSION" | head -1 | awk '{print $NF}')
  TEAM=$(echo "$SETTINGS" | grep "DEVELOPMENT_TEAM" | head -1 | awk '{print $NF}')
  PLATFORMS=$(echo "$SETTINGS" | grep "SUPPORTED_PLATFORMS" | head -1 | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}')
  PRODUCT_NAME=$(echo "$SETTINGS" | grep " PRODUCT_NAME " | head -1 | awk '{print $NF}')

  echo "  BUNDLE_ID=$BUNDLE_ID"
  echo "  PRODUCT_NAME=$PRODUCT_NAME"
  echo "  VERSION=$VERSION"
  echo "  BUILD_NUMBER=$BUILD_NUM"
  echo "  TEAM_ID=$TEAM"
  echo "  PLATFORMS=$PLATFORMS"
  echo ""
done <<< "$SCHEMES"

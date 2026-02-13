#!/bin/bash
# Detect iOS/macOS project type, available schemes, and per-scheme platform support
# Outputs structured info for the agent to parse

set -euo pipefail

echo "=== Project Detection ==="

# Check for .xcworkspace first (takes priority)
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" -not -path "./**/project.xcworkspace" | head -1)
XCODEPROJ=$(find . -maxdepth 1 -name "*.xcodeproj" | head -1)
PACKAGE_SWIFT=""
[ -f "Package.swift" ] && PACKAGE_SWIFT="Package.swift"

PROJECT_FLAG=""
PROJECT_PATH=""

if [ -n "$WORKSPACE" ]; then
    echo "TYPE=workspace"
    echo "PATH=$WORKSPACE"
    PROJECT_FLAG="-workspace"
    PROJECT_PATH="$WORKSPACE"
elif [ -n "$XCODEPROJ" ]; then
    echo "TYPE=xcodeproj"
    echo "PATH=$XCODEPROJ"
    PROJECT_FLAG="-project"
    PROJECT_PATH="$XCODEPROJ"
elif [ -n "$PACKAGE_SWIFT" ]; then
    echo "TYPE=swift-package"
    echo "PATH=Package.swift"
    echo ""
    echo "Note: Swift packages cannot be directly installed on a device."
    echo "You need an .xcodeproj or .xcworkspace wrapping the package."
    exit 0
else
    echo "TYPE=none"
    echo "ERROR: No .xcworkspace, .xcodeproj, or Package.swift found in $(pwd)"
    exit 1
fi

echo ""
echo "=== Schemes ==="
xcodebuild $PROJECT_FLAG "$PROJECT_PATH" -list 2>&1

# Detect platforms per scheme
echo ""
echo "=== Platform Support Per Scheme ==="
SCHEMES=$(xcodebuild $PROJECT_FLAG "$PROJECT_PATH" -list 2>/dev/null | awk '/Schemes:/{found=1; next} found && /^$/{exit} found{gsub(/^[ \t]+/, ""); print}')

for SCHEME in $SCHEMES; do
    PLATFORMS=$(xcodebuild $PROJECT_FLAG "$PROJECT_PATH" -scheme "$SCHEME" -showBuildSettings 2>/dev/null \
        | grep "SUPPORTED_PLATFORMS" | sed 's/.*= //' | head -1)
    if [ -z "$PLATFORMS" ]; then
        PLATFORMS="(unknown)"
    fi
    echo "  $SCHEME: $PLATFORMS"
done

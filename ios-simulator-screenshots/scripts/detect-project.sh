#!/bin/bash
# Detect iOS project type, available schemes, and bundle ID
# Outputs structured info for the agent to parse
# Usage: detect-project.sh [project-dir]

set -euo pipefail

DIR="${1:-.}"
cd "$DIR"

echo "=== iOS Project Detection ==="
echo "  Directory: $(pwd)"

# Check for .xcworkspace first (takes priority)
WORKSPACE=$(find . -maxdepth 1 -name "*.xcworkspace" -not -path "./**/project.xcworkspace" | head -1)
XCODEPROJ=$(find . -maxdepth 1 -name "*.xcodeproj" | head -1)

if [ -n "$WORKSPACE" ]; then
    echo "  TYPE=workspace"
    echo "  PATH=$WORKSPACE"
    echo ""
    echo "=== Schemes ==="
    xcodebuild -workspace "$WORKSPACE" -list 2>&1
elif [ -n "$XCODEPROJ" ]; then
    echo "  TYPE=xcodeproj"
    echo "  PATH=$XCODEPROJ"
    echo ""
    echo "=== Schemes ==="
    xcodebuild -project "$XCODEPROJ" -list 2>&1
else
    echo "  TYPE=none"
    echo "  ERROR: No .xcworkspace or .xcodeproj found in $(pwd)"
    exit 1
fi

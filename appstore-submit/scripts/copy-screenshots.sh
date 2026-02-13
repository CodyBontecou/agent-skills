#!/usr/bin/env bash
# copy-screenshots.sh — Copy and organize screenshots for fastlane deliver
#
# Usage:
#   bash copy-screenshots.sh \
#     --source <dir-with-pngs> \
#     [--locale en-US] \
#     [-o fastlane/screenshots]
#
# Copies all PNG files from the source directory into the locale-specific
# fastlane screenshots folder. Files are sorted alphabetically so the
# App Store ordering matches the filename order.

set -euo pipefail

LOCALE="en-US"
OUTPUT_DIR="fastlane/screenshots"
SOURCE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    --locale) LOCALE="$2"; shift 2 ;;
    -o) OUTPUT_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$SOURCE" ]]; then
  echo "❌ --source <directory> is required"
  exit 1
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "❌ Source directory not found: $SOURCE"
  exit 1
fi

DEST="$OUTPUT_DIR/$LOCALE"
mkdir -p "$DEST"

echo "📸 Copying screenshots from $SOURCE → $DEST"
echo ""

COUNT=0
for f in "$SOURCE"/*.png; do
  [[ -f "$f" ]] || continue
  BASENAME=$(basename "$f")
  cp "$f" "$DEST/$BASENAME"
  # Get dimensions
  DIMS=$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | grep pixel | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
  echo "  ✅ $BASENAME ($DIMS)"
  COUNT=$((COUNT + 1))
done

echo ""
echo "✅ $COUNT screenshots copied to $DEST"

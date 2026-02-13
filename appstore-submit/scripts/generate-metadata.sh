#!/usr/bin/env bash
# generate-metadata.sh — Create the fastlane metadata directory structure
#
# Usage:
#   bash generate-metadata.sh \
#     --name "App Name" \
#     --subtitle "Short tagline" \
#     --description-file <path> \
#     --keywords "word1,word2,word3" \
#     --support-url "https://..." \
#     --privacy-url "https://..." \
#     --marketing-url "https://..." \
#     --copyright "2025 Author Name" \
#     --release-notes "What's new text" \
#     --primary-category "MZGenre.HealthAndFitness" \
#     --secondary-category "MZGenre.Productivity" \
#     [--locale en-US] \
#     [-o fastlane/metadata]
#
# If --description-file is provided, its contents are used as the description.
# Otherwise a description.txt placeholder is created.

set -euo pipefail

# ── Defaults ─────────────────────────────────────────────────────────
LOCALE="en-US"
OUTPUT_DIR="fastlane/metadata"
NAME=""
SUBTITLE=""
DESCRIPTION_FILE=""
KEYWORDS=""
SUPPORT_URL=""
PRIVACY_URL=""
MARKETING_URL=""
COPYRIGHT=""
RELEASE_NOTES=""
PRIMARY_CATEGORY=""
SECONDARY_CATEGORY=""

# ── Parse args ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --subtitle) SUBTITLE="$2"; shift 2 ;;
    --description-file) DESCRIPTION_FILE="$2"; shift 2 ;;
    --keywords) KEYWORDS="$2"; shift 2 ;;
    --support-url) SUPPORT_URL="$2"; shift 2 ;;
    --privacy-url) PRIVACY_URL="$2"; shift 2 ;;
    --marketing-url) MARKETING_URL="$2"; shift 2 ;;
    --copyright) COPYRIGHT="$2"; shift 2 ;;
    --release-notes) RELEASE_NOTES="$2"; shift 2 ;;
    --primary-category) PRIMARY_CATEGORY="$2"; shift 2 ;;
    --secondary-category) SECONDARY_CATEGORY="$2"; shift 2 ;;
    --locale) LOCALE="$2"; shift 2 ;;
    -o) OUTPUT_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Create directory ─────────────────────────────────────────────────
LOCALE_DIR="$OUTPUT_DIR/$LOCALE"
mkdir -p "$LOCALE_DIR"

# ── Write files ──────────────────────────────────────────────────────
write_if_set() {
  local file="$1"
  local value="$2"
  if [[ -n "$value" ]]; then
    echo "$value" > "$LOCALE_DIR/$file"
    echo "  ✅ $file"
  fi
}

echo "📝 Generating metadata in $LOCALE_DIR"
echo ""

write_if_set "name.txt" "$NAME"
write_if_set "subtitle.txt" "$SUBTITLE"
write_if_set "keywords.txt" "$KEYWORDS"
write_if_set "support_url.txt" "$SUPPORT_URL"
write_if_set "privacy_url.txt" "$PRIVACY_URL"
write_if_set "marketing_url.txt" "$MARKETING_URL"
write_if_set "copyright.txt" "$COPYRIGHT"
write_if_set "primary_category.txt" "$PRIMARY_CATEGORY"
write_if_set "secondary_category.txt" "$SECONDARY_CATEGORY"

if [[ -n "$RELEASE_NOTES" ]]; then
  echo "$RELEASE_NOTES" > "$LOCALE_DIR/release_notes.txt"
  echo "  ✅ release_notes.txt"
fi

if [[ -n "$DESCRIPTION_FILE" && -f "$DESCRIPTION_FILE" ]]; then
  cp "$DESCRIPTION_FILE" "$LOCALE_DIR/description.txt"
  echo "  ✅ description.txt (from $DESCRIPTION_FILE)"
elif [[ -n "$DESCRIPTION_FILE" ]]; then
  echo "  ⚠️  Description file not found: $DESCRIPTION_FILE"
fi

echo ""
echo "✅ Metadata generated in $LOCALE_DIR"
echo ""
echo "Files:"
ls -1 "$LOCALE_DIR/" 2>/dev/null | sed 's/^/  /'

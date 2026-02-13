#!/usr/bin/env bash
#
# Validate that a static portfolio site is compatible with the
# ugc.community contact form integration.
#
# Usage: validate.sh [root_dir]
#   root_dir defaults to the current working directory.
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed (details printed to stdout)

set -euo pipefail

ROOT="${1:-.}"
ERRORS=0

header() { printf '\n\033[1m%s\033[0m\n' "$1"; }
pass()   { printf '  \033[32m✔\033[0m %s\n' "$1"; }
fail()   { printf '  \033[31m✘\033[0m %s\n' "$1"; ERRORS=$((ERRORS + 1)); }
warn()   { printf '  \033[33m⚠\033[0m %s\n' "$1"; }
info()   { printf '  \033[36mℹ\033[0m %s\n' "$1"; }

# -------------------------------------------------------
# 1. index.html exists
# -------------------------------------------------------
header "File structure"

if [ -f "$ROOT/index.html" ]; then
  pass "index.html exists"
else
  fail "index.html not found at project root"
fi

# -------------------------------------------------------
# 2. script.js exists (platform appends contact handler here)
# -------------------------------------------------------
if [ -f "$ROOT/script.js" ]; then
  pass "script.js exists (contact handler will be injected here)"
else
  fail "script.js not found — the platform injects the contact form handler into this file at serve-time"
fi

# -------------------------------------------------------
# 3. Contact form with correct id
# -------------------------------------------------------
header "Contact form (<form id=\"contact-form\">)"

FORM_FILE=""
while IFS= read -r f; do
  if grep -q 'id="contact-form"' "$f" 2>/dev/null; then
    FORM_FILE="$f"
    break
  fi
done < <(find "$ROOT" -name '*.html' -type f 2>/dev/null)

if [ -n "$FORM_FILE" ]; then
  pass "Found contact-form in $FORM_FILE"
else
  fail "No <form id=\"contact-form\"> found in any HTML file"
  info "The platform handler targets document.getElementById('contact-form')"
fi

# -------------------------------------------------------
# 4. Required name attributes on inputs
# -------------------------------------------------------
header "Required form fields (name attributes)"

REQUIRED_NAMES=("name" "email" "company" "message")

if [ -n "$FORM_FILE" ]; then
  FORM_CONTENT=$(cat "$FORM_FILE")

  for field in "${REQUIRED_NAMES[@]}"; do
    if echo "$FORM_CONTENT" | grep -qE "name=[\"']${field}[\"']"; then
      pass "name=\"$field\" found"
    else
      fail "name=\"$field\" NOT found in $FORM_FILE"
    fi
  done
else
  for field in "${REQUIRED_NAMES[@]}"; do
    fail "name=\"$field\" — skipped (no form file found)"
  done
fi

# -------------------------------------------------------
# 5. Submit button
# -------------------------------------------------------
header "Submit button"

if [ -n "$FORM_FILE" ]; then
  if grep -qE 'type="submit"|type='\''submit'\''' "$FORM_FILE" 2>/dev/null; then
    pass "type=\"submit\" button found"
  else
    fail "No element with type=\"submit\" found inside form HTML"
    info "The handler needs a [type=\"submit\"] element to show loading/success states"
  fi
fi

# -------------------------------------------------------
# 6. Check for conflicting custom submit handlers
# -------------------------------------------------------
header "Potential conflicts"

if [ -f "$ROOT/script.js" ]; then
  if grep -qE "contact-form.*submit|addEventListener.*submit" "$ROOT/script.js" 2>/dev/null; then
    warn "script.js already contains a submit handler — it may conflict with the injected one"
    info "The platform appends its own submit listener to script.js at serve-time"
    info "Remove any custom contact-form submit handling to avoid double submissions"
  else
    pass "No conflicting submit handlers in script.js"
  fi
fi

# -------------------------------------------------------
# Summary
# -------------------------------------------------------
header "Summary"

if [ "$ERRORS" -eq 0 ]; then
  printf '  \033[32m✔ All checks passed — contact form is ready for ugc.community\033[0m\n'
  exit 0
else
  printf '  \033[31m✘ %d issue(s) found — see above for details\033[0m\n' "$ERRORS"
  exit 1
fi

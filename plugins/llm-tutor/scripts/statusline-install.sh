#!/usr/bin/env bash
# statusline-install.sh — wrap the existing statusline so llm-tutor's segment
# renders alongside whatever the user already has.
#
# What this does to ~/.claude/settings.json:
#   1. Reads the current statusLine block (whole object).
#   2. Saves it to ~/.claude/llm-tutor/wrapped-statusline.json (uninstall
#      restores from this).
#   3. Swaps statusLine.command to point at our wrapper script.
#   4. Creates the enable flag file so the segment renders by default.
#
# Stable wrapper path: the wrapper script lives in the plugin's cache dir,
# which has a version-number path that changes on every release. To insulate
# settings.json from version churn, we symlink the wrapper to
# ~/.claude/llm-tutor/statusline-wrapper.sh (stable HOME-relative path) and
# point settings.json at the symlink.
#
# Idempotent: if statusLine.command is already the symlink, no-op.
#
# Refuses to wrap itself: if we detect the wrapper symlink in any nested
# command field, refuse to install. This stops the "install twice → recurse"
# foot-gun.

set -e

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
WRAPPED_FILE="$STATE_DIR/wrapped-statusline.json"
ENABLED_FLAG="$STATE_DIR/statusline-enabled"
WRAPPER_SYMLINK="$STATE_DIR/statusline-wrapper.sh"
SEGMENT_SYMLINK="$STATE_DIR/statusline-segment.sh"
SETTINGS="$HOME/.claude/settings.json"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_REAL="$SCRIPT_DIR/statusline-wrapper.sh"
SEGMENT_REAL="$SCRIPT_DIR/statusline-segment.sh"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required." >&2
  exit 1
fi

mkdir -p "$STATE_DIR"

# Stable symlinks. The wrapper script in the plugin cache lives at a
# version-numbered path; the symlink under $STATE_DIR is what settings.json
# references, so version bumps don't require resetting settings.json.
ln -sf "$WRAPPER_REAL" "$WRAPPER_SYMLINK"
ln -sf "$SEGMENT_REAL" "$SEGMENT_SYMLINK"

# --- read current statusLine block ---
current_block="null"
if [ -f "$SETTINGS" ]; then
  current_block=$(jq -c '.statusLine // null' "$SETTINGS")
fi

current_cmd=$(echo "$current_block" | jq -r '.command // empty')

# Already wrapped? Detect by matching the wrapper symlink path in the
# current command. The current command might be the symlink path directly
# (typical), or a shell snippet that includes it.
if [ -n "$current_cmd" ] && [[ "$current_cmd" == *"$WRAPPER_SYMLINK"* ]]; then
  # Already installed; ensure flag is on and exit.
  touch "$ENABLED_FLAG"
  echo "llm-tutor statusline integration is already installed."
  echo "Segment enabled (flag: $ENABLED_FLAG)."
  exit 0
fi

# --- save the original ---
if [ "$current_block" = "null" ]; then
  # No prior statusLine. Save an explicit "none" marker so uninstall knows
  # to delete the key rather than restore something.
  echo '{"none": true}' > "$WRAPPED_FILE"
  echo "No existing statusLine found in $SETTINGS — installing standalone."
else
  echo "$current_block" | jq '.' > "$WRAPPED_FILE"
  echo "Saved original statusLine to $WRAPPED_FILE."
fi

# --- swap to our wrapper ---
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

tmp=$(mktemp)
jq --arg cmd "$WRAPPER_SYMLINK" \
   '.statusLine = {type: "command", command: $cmd}' \
   "$SETTINGS" > "$tmp"
mv "$tmp" "$SETTINGS"

# --- enable by default ---
touch "$ENABLED_FLAG"

echo
echo "Installed. Your existing statusline (if any) will still render, with"
echo "llm-tutor's segment appended as an extra row when a session is active."
echo
echo "  Toggle off: /tutor-statusline-toggle off"
echo "  Toggle on:  /tutor-statusline-toggle on"
echo "  Uninstall:  /tutor-statusline-uninstall"
echo
echo "Restart Claude Code (or wait for the next statusline render) to see it."

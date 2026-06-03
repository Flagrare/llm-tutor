#!/usr/bin/env bash
# statusline-uninstall.sh — undo /tutor-statusline-install.
#
# Restores the original statusLine block from wrapped-statusline.json. If
# the user had no statusLine before installing (wrapped-statusline.json
# contains {"none": true}), removes the statusLine key from settings.json
# entirely.
#
# Always removes the symlinks and the enable flag. Leaves state.json,
# tutoring progress, and the saved-original file alone — the user can
# /tutor-statusline-install again later without re-losing their original.

set -e

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
WRAPPED_FILE="$STATE_DIR/wrapped-statusline.json"
ENABLED_FLAG="$STATE_DIR/statusline-enabled"
WRAPPER_SYMLINK="$STATE_DIR/statusline-wrapper.sh"
SEGMENT_SYMLINK="$STATE_DIR/statusline-segment.sh"
SETTINGS="$HOME/.claude/settings.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required." >&2
  exit 1
fi

if [ ! -f "$WRAPPED_FILE" ]; then
  echo "llm-tutor statusline integration doesn't appear to be installed."
  echo "(No $WRAPPED_FILE found.)"
  # Defensive: still remove flag + symlinks if they happen to exist.
  rm -f "$ENABLED_FLAG" "$WRAPPER_SYMLINK" "$SEGMENT_SYMLINK"
  exit 0
fi

# --- restore settings.json ---
if [ -f "$SETTINGS" ]; then
  saved_block=$(cat "$WRAPPED_FILE")
  is_none=$(echo "$saved_block" | jq -r '.none // false')

  tmp=$(mktemp)
  if [ "$is_none" = "true" ]; then
    # Originally had no statusLine. Remove the key entirely.
    jq 'del(.statusLine)' "$SETTINGS" > "$tmp"
    echo "Removed statusLine key from $SETTINGS (was empty before install)."
  else
    # Restore the saved block verbatim.
    jq --argjson b "$saved_block" '.statusLine = $b' "$SETTINGS" > "$tmp"
    echo "Restored original statusLine in $SETTINGS."
  fi
  mv "$tmp" "$SETTINGS"
fi

# --- clean up llm-tutor's wrapper artifacts ---
rm -f "$ENABLED_FLAG" "$WRAPPER_SYMLINK" "$SEGMENT_SYMLINK" "$WRAPPED_FILE"

echo
echo "Uninstalled. Tutoring state (XP, cycles, topics) is preserved in $STATE_DIR/state.json."
echo "Restart Claude Code to fully reload the statusline."

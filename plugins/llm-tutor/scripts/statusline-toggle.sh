#!/usr/bin/env bash
# statusline-toggle.sh — turn the llm-tutor statusline segment on/off
# without uninstalling the wrapper.
#
# When off, the wrapper still runs but only emits the original statusline
# output — no extra row. So toggling off is zero-cost for the user's view
# but keeps the wrapper installed.
#
# Usage:
#   statusline-toggle.sh           Toggle between on/off
#   statusline-toggle.sh on        Force on
#   statusline-toggle.sh off       Force off

set -e

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
ENABLED_FLAG="$STATE_DIR/statusline-enabled"
WRAPPER_SYMLINK="$STATE_DIR/statusline-wrapper.sh"

mkdir -p "$STATE_DIR"

# Warn (but don't refuse) if the wrapper isn't installed — toggling without
# install just creates an inert flag file.
if [ ! -e "$WRAPPER_SYMLINK" ]; then
  echo "Note: wrapper isn't installed yet. Run /tutor-statusline-install"
  echo "for the toggle to actually affect what renders."
  echo
fi

arg="${1:-}"
case "$arg" in
  on|true)
    target="on"
    ;;
  off|false)
    target="off"
    ;;
  "")
    if [ -f "$ENABLED_FLAG" ]; then
      target="off"
    else
      target="on"
    fi
    ;;
  *)
    echo "Usage: statusline-toggle.sh [on|off]" >&2
    exit 1
    ;;
esac

if [ "$target" = "on" ]; then
  touch "$ENABLED_FLAG"
  echo "llm-tutor statusline segment: on"
else
  rm -f "$ENABLED_FLAG"
  echo "llm-tutor statusline segment: off (wrapper still installed; original statusline renders unchanged)"
fi

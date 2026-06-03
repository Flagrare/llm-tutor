#!/usr/bin/env bash
# statusline-icons.sh — switch icon mode for the llm-tutor segment.
#
# Mirrors claude-statusline's /statusline-icons UX. Cycles through the four
# modes with no arg; accepts an explicit mode. Persists the choice in
# ~/.claude/llm-tutor/statusline.conf so the wrapper picks it up on next
# render.
#
# Usage:
#   statusline-icons.sh                 Cycle to next mode
#   statusline-icons.sh emoji           Set explicit mode
#   statusline-icons.sh nerd
#   statusline-icons.sh unicode
#   statusline-icons.sh ascii

set -e

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
CONF_FILE="$STATE_DIR/statusline.conf"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEGMENT_SH="$SCRIPT_DIR/statusline-segment.sh"

mkdir -p "$STATE_DIR"
[ -f "$CONF_FILE" ] || printf "ICONS=emoji\n" > "$CONF_FILE"

# Read current mode (falls back to emoji on missing/garbled conf).
current=$(grep -E '^ICONS=' "$CONF_FILE" 2>/dev/null | tail -1 | cut -d= -f2)
case "$current" in emoji|nerd|unicode|ascii) ;; *) current="emoji" ;; esac

# Resolve target mode.
arg="${1:-}"
case "$arg" in
  emoji|nerd|unicode|ascii)
    target="$arg"
    ;;
  "")
    case "$current" in
      emoji)   target="nerd"    ;;
      nerd)    target="unicode" ;;
      unicode) target="ascii"   ;;
      ascii)   target="emoji"   ;;
    esac
    ;;
  *)
    echo "Usage: statusline-icons.sh [emoji|nerd|unicode|ascii]" >&2
    echo "  no arg = cycle to next mode" >&2
    exit 1
    ;;
esac

# Persist. Replace existing ICONS= line in-place, or append if missing.
if grep -qE '^ICONS=' "$CONF_FILE" 2>/dev/null; then
  sed -i '' "s/^ICONS=.*/ICONS=${target}/" "$CONF_FILE" 2>/dev/null \
    || sed -i "s/^ICONS=.*/ICONS=${target}/" "$CONF_FILE"
else
  printf "ICONS=%s\n" "$target" >> "$CONF_FILE"
fi

echo "llm-tutor statusline icons: $target"
echo
echo "Preview:"
ICONS="$target" ICONS_FROM_ENV=1 bash "$SEGMENT_SH" 2>/dev/null || true
echo

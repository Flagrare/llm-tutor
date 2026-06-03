#!/usr/bin/env bash
# statusline-segment.sh — render a one-line llm-tutor status segment.
#
# Designed to be shelled out to from ANY statusline (claude-statusline,
# powerlevel10k, starship, custom bash). Outputs a single line — tier name,
# cycles balance, and (when applicable) the active topic slug + concept
# progress.
#
# Exits 0 with empty output when:
#   - the state file is missing (user has never run /tutor-start), or
#   - jq is missing.
# This is deliberate: callers can wire the script unconditionally without
# guarding for "is llm-tutor installed".
#
# State file location resolves the same way state.sh resolves it:
#   $CLAUDE_PLUGIN_DATA/state.json  (set by Claude Code in plugin context)
#   else $HOME/.claude/llm-tutor/state.json
#
# Usage:
#   statusline-segment.sh           Default: emoji + ANSI dim. Drop-in for
#                                   any color-capable statusline.
#   statusline-segment.sh --plain   Plain ASCII, no color, no emoji. For
#                                   statuslines that style their own output.
#   statusline-segment.sh --json    Emit raw signals as JSON. For consumers
#                                   that want to format everything themselves.
#
# Output examples:
#   default:  Greenhorn ⚡4/5 python-decorat… 2/5
#   --plain:  Greenhorn 4/5 python-decorat... 2/5
#   --json:   {"tier_index":1,"tier_name":"Greenhorn","xp":12, …}
#
# Requires: jq (silent no-op if missing).

set -euo pipefail

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
STATE_FILE="$STATE_DIR/state.json"

# Resolve symlinks so we find the real plugin scripts directory even when
# this script is invoked via the stable symlink at
# ~/.claude/llm-tutor/statusline-segment.sh (created by statusline-install.sh).
resolve_symlink() {
  local p="$1" dir
  while [ -L "$p" ]; do
    dir="$(cd "$(dirname "$p")" && pwd)"
    p="$(readlink "$p")"
    case "$p" in
      /*) ;;
       *) p="$dir/$p" ;;
    esac
  done
  printf "%s" "$p"
}
SCRIPT_REAL="$(resolve_symlink "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_REAL")" && pwd)"
TIER_SH="$SCRIPT_DIR/tier.sh"

# Max chars for the topic slug before it gets truncated with an ellipsis.
# 20 is enough for "python-decorators" but tight enough to keep the segment
# narrow on small terminals.
SLUG_MAX_LEN=20

# Silent exit when prerequisites aren't there. A statusline rendering 30
# times a minute should never see noise from a missing tool.
[ -f "$STATE_FILE" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# --- read state ---
XP=$(jq -r '.user.xp // 0' "$STATE_FILE")
CYCLES=$(jq -r '.user.cycles // 0' "$STATE_FILE")
CYCLES_CAP=$(jq -r '.user.cycles_cap // 5' "$STATE_FILE")

TIER_NAME=$(bash "$TIER_SH" name "$XP" 2>/dev/null || echo "")
TIER_INDEX=$(bash "$TIER_SH" index "$XP" 2>/dev/null || echo "")

# Most recently started in-progress topic, if any.
# Empty string when there is none — caller decides whether to render.
ACTIVE_TOPIC=$(jq -r '
  [.topics // {} | to_entries[] | select(.value.status == "in_progress")]
  | sort_by(.value.started_at) | reverse
  | .[0].key // ""
' "$STATE_FILE")

if [ -n "$ACTIVE_TOPIC" ]; then
  ACQUIRED=$(jq -r --arg s "$ACTIVE_TOPIC" '
    [.topics[$s].concepts[]? | select(.status == "acquired")] | length
  ' "$STATE_FILE")
  TOTAL=$(jq -r --arg s "$ACTIVE_TOPIC" '
    (.topics[$s].concepts // []) | length
  ' "$STATE_FILE")
else
  ACQUIRED=0
  TOTAL=0
fi

# --- render mode ---
mode="default"
case "${1:-}" in
  --plain) mode="plain" ;;
  --json)  mode="json"  ;;
  "")      mode="default" ;;
  *)       echo "unknown flag: $1" >&2; exit 2 ;;
esac

if [ "$mode" = "json" ]; then
  jq -n \
    --argjson xp "$XP" \
    --argjson cycles "$CYCLES" \
    --argjson cycles_cap "$CYCLES_CAP" \
    --arg tier_name "$TIER_NAME" \
    --argjson tier_index "${TIER_INDEX:-0}" \
    --arg active_topic "$ACTIVE_TOPIC" \
    --argjson acquired "$ACQUIRED" \
    --argjson total "$TOTAL" \
    '{tier_index: $tier_index, tier_name: $tier_name,
      xp: $xp, cycles: $cycles, cycles_cap: $cycles_cap,
      active_topic: (if $active_topic == "" then null else $active_topic end),
      acquired: $acquired, total: $total}'
  exit 0
fi

# Truncate the slug with an ellipsis when it exceeds SLUG_MAX_LEN.
# Plain mode uses "..." (ASCII); default uses "…" (single codepoint).
truncate_slug() {
  local slug="$1" ellipsis="$2"
  if [ "${#slug}" -le "$SLUG_MAX_LEN" ]; then
    printf "%s" "$slug"
  else
    printf "%s%s" "${slug:0:$SLUG_MAX_LEN}" "$ellipsis"
  fi
}

if [ "$mode" = "plain" ]; then
  out="$TIER_NAME ${CYCLES}/${CYCLES_CAP}"
  if [ -n "$ACTIVE_TOPIC" ]; then
    slug_disp=$(truncate_slug "$ACTIVE_TOPIC" "...")
    out="$out $slug_disp ${ACQUIRED}/${TOTAL}"
  fi
  printf "%s" "$out"
  exit 0
fi

# --- default: ANSI dim tier name + emoji ⚡ for cycles ---
DIM=$'\033[38;5;240m'
YELLOW=$'\033[33m'
RESET=$'\033[0m'

# Highlight cycles when at most 1 left, so the user notices before the
# next /tutor-start fails.
if [ "$CYCLES" -le 1 ]; then
  cycles_str="${YELLOW}⚡${CYCLES}/${CYCLES_CAP}${RESET}"
else
  cycles_str="⚡${CYCLES}/${CYCLES_CAP}"
fi

out="${DIM}${TIER_NAME}${RESET} ${cycles_str}"
if [ -n "$ACTIVE_TOPIC" ]; then
  slug_disp=$(truncate_slug "$ACTIVE_TOPIC" "…")
  out="$out ${slug_disp} ${ACQUIRED}/${TOTAL}"
fi
printf "%s" "$out"

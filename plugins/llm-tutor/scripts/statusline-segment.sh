#!/usr/bin/env bash
# statusline-segment.sh — render the llm-tutor status row.
#
# Designed to be shelled out to from ANY statusline (claude-statusline,
# powerlevel10k, starship, custom bash). Outputs a single line: a persona
# tag, current tier with XP-toward-next-tier as a 5-block bar, cycles
# balance, and (when applicable) the active topic with concept progress
# as a second 5-block bar.
#
# The renderer is designed to OWN its row visually — persona-colored, glyph-
# rich, with progress bars instead of N/M fractions — so it doesn't get lost
# among other statusline content.
#
# Exits 0 with empty output when:
#   - the state file is missing (user has never run /tutor-start), or
#   - jq is missing.
# This is deliberate: callers can wire the script unconditionally without
# guarding for "is llm-tutor installed".
#
# Configuration:
#   ICONS=emoji|nerd|unicode|ascii   in ~/.claude/llm-tutor/statusline.conf
#                                    (overridable via env)
#   LLM_TUTOR_PERSONA=echo|cipher|vex|""    typically set by the wrapper,
#                                           which reads Claude Code's
#                                           output_style.name from stdin.
#
# Usage:
#   statusline-segment.sh           Default render
#   statusline-segment.sh --plain   ASCII, no color, no glyphs (mode override)
#   statusline-segment.sh --json    Raw signals for custom statuslines
#
# Requires: jq (silent no-op if missing).

set -u

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
STATE_FILE="$STATE_DIR/state.json"
CONF_FILE="$STATE_DIR/statusline.conf"

# Resolve symlinks so the script finds the real plugin scripts directory
# even when invoked via ~/.claude/llm-tutor/statusline-segment.sh
# (the stable symlink created by statusline-install.sh).
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

# Topic display-name truncation. Default 40 — wide enough for almost any
# real subject (the user picked the wording, we shouldn't second-guess it).
# Overridable in ~/.claude/llm-tutor/statusline.conf as SLUG_MAX_LEN=N.
# Set to 0 to disable truncation entirely.
SLUG_MAX_LEN=40

# Silent exit when prerequisites aren't there. A statusline rendering several
# times a minute should never produce noise from a missing tool.
[ -f "$STATE_FILE" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# --- icon mode resolution ---
# Precedence: ICONS env var > conf file > default emoji.
ICONS="${ICONS:-emoji}"
if [ -z "${ICONS_FROM_ENV:-}" ] && [ -f "$CONF_FILE" ]; then
  # shellcheck source=/dev/null
  source "$CONF_FILE"
fi
# Special-case --plain — equivalent to ascii mode with color stripped.
PLAIN_MODE="false"
JSON_MODE="false"
case "${1:-}" in
  --plain) PLAIN_MODE="true"; ICONS="ascii" ;;
  --json)  JSON_MODE="true" ;;
  "")      ;;
  *)       echo "unknown flag: $1" >&2; exit 2 ;;
esac

# --- read state ---
XP=$(jq -r '.user.xp // 0' "$STATE_FILE")
CYCLES=$(jq -r '.user.cycles // 0' "$STATE_FILE")
CYCLES_CAP=$(jq -r '.user.cycles_cap // 5' "$STATE_FILE")

TIER_NAME=$(bash "$TIER_SH" name "$XP" 2>/dev/null || echo "")
TIER_INDEX=$(bash "$TIER_SH" index "$XP" 2>/dev/null || echo "1")
NEXT_RAW=$(bash "$TIER_SH" next "$XP" 2>/dev/null || echo "max")

# XP progress within current tier (0..5 cells filled). Use the
# threshold-difference between current tier and next; XP-needed-for-next is
# returned by tier.sh next as "<name>|<needed>".
xp_bar_filled=5
if [ "$NEXT_RAW" != "max" ]; then
  next_needed=$(echo "$NEXT_RAW" | cut -d'|' -f2)
  # Threshold of current tier = XP - (next_needed - threshold_step). The tier
  # table is canonical in tier.sh; we re-derive the current tier's threshold
  # by walking the table for index TIER_INDEX. Cheaper: read it once via
  # tier.sh table parsing.
  # Threshold pairs we need: current_threshold and next_threshold.
  current_threshold=$(bash "$TIER_SH" table | awk -v idx="$TIER_INDEX" '
    NR==idx { gsub(/^[ \t]+/, ""); print $3; exit }
  ')
  next_threshold=$(( XP + next_needed ))
  span=$(( next_threshold - current_threshold ))
  earned=$(( XP - current_threshold ))
  if [ "$span" -gt 0 ]; then
    xp_bar_filled=$(( earned * 5 / span ))
    [ "$xp_bar_filled" -gt 5 ] && xp_bar_filled=5
    [ "$xp_bar_filled" -lt 0 ] && xp_bar_filled=0
  fi
fi

# Most recently started in-progress topic, if any.
ACTIVE_TOPIC=$(jq -r '
  [.topics // {} | to_entries[] | select(.value.status == "in_progress")]
  | sort_by(.value.started_at) | reverse
  | .[0].key // ""
' "$STATE_FILE")

ACQUIRED=0
TOTAL=0
concept_bar_filled=0
ACTIVE_DISPLAY=""
if [ -n "$ACTIVE_TOPIC" ]; then
  ACQUIRED=$(jq -r --arg s "$ACTIVE_TOPIC" '
    [.topics[$s].concepts[]? | select(.status == "acquired")] | length
  ' "$STATE_FILE")
  TOTAL=$(jq -r --arg s "$ACTIVE_TOPIC" '
    (.topics[$s].concepts // []) | length
  ' "$STATE_FILE")
  if [ "$TOTAL" -gt 0 ]; then
    concept_bar_filled=$(( ACQUIRED * 5 / TOTAL ))
    [ "$concept_bar_filled" -gt 5 ] && concept_bar_filled=5
    [ "$concept_bar_filled" -lt 0 ] && concept_bar_filled=0
  fi
  # Read the topic's display_name (set at /tutor-start time from the
  # user's original subject). Topics created before the schema added this
  # field don't have one — fall back to the slug-key in that case so the
  # statusline keeps working for legacy state files.
  ACTIVE_DISPLAY=$(jq -r --arg s "$ACTIVE_TOPIC" '
    .topics[$s].display_name // ""
  ' "$STATE_FILE")
  [ -z "$ACTIVE_DISPLAY" ] && ACTIVE_DISPLAY="$ACTIVE_TOPIC"
fi

# --- persona resolution ---
# Persona comes from the wrapper via LLM_TUTOR_PERSONA env var (the wrapper
# extracts output_style.name from Claude Code's status JSON). If empty or
# unrecognized, we render in a neutral cool gray.
PERSONA="${LLM_TUTOR_PERSONA:-}"
PERSONA="$(printf "%s" "$PERSONA" | tr '[:upper:]' '[:lower:]')"
case "$PERSONA" in
  echo|cipher|vex) ;;
  *) PERSONA="" ;;
esac

# --- JSON mode short-circuit ---
if [ "$JSON_MODE" = "true" ]; then
  jq -n \
    --argjson xp "$XP" \
    --argjson cycles "$CYCLES" \
    --argjson cycles_cap "$CYCLES_CAP" \
    --arg tier_name "$TIER_NAME" \
    --argjson tier_index "$TIER_INDEX" \
    --argjson xp_bar_filled "$xp_bar_filled" \
    --arg active_topic "$ACTIVE_TOPIC" \
    --arg active_display "$ACTIVE_DISPLAY" \
    --argjson acquired "$ACQUIRED" \
    --argjson total "$TOTAL" \
    --argjson concept_bar_filled "$concept_bar_filled" \
    --arg persona "$PERSONA" \
    --arg icons "$ICONS" \
    '{tier_index: $tier_index, tier_name: $tier_name,
      xp: $xp, xp_bar_filled: $xp_bar_filled,
      cycles: $cycles, cycles_cap: $cycles_cap,
      active_topic: (if $active_topic == "" then null else $active_topic end),
      active_display: (if $active_display == "" then null else $active_display end),
      acquired: $acquired, total: $total, concept_bar_filled: $concept_bar_filled,
      persona: (if $persona == "" then null else $persona end),
      icons: $icons}'
  exit 0
fi

# --- glyph map (4 modes) ---
# Persona avatar (PERSONA_ICON), tier emblem (TIER_ICON), cycles bolt
# (BOLT_ICON), topic marker (TOPIC_ICON), and progress-bar cells
# (BAR_FILL / BAR_EMPTY).
case "$ICONS" in
  nerd)
    PERSONA_ICON=$'\xf3\xb0\x9d\x89'   # nf-md-school                U+F0749
    TIER_ICON=$'\xf3\xb0\x97\xa3'      # nf-md-trophy_outline        U+F05E3
    BOLT_ICON=$'\xef\x83\xa7'          # nf-fa-bolt                  U+F0E7
    TOPIC_ICON=$'\xef\x80\xad'         # nf-fa-book                  U+F02D
    BAR_FILL="▰"
    BAR_EMPTY="▱"
    SEP="·"
    ;;
  unicode)
    PERSONA_ICON="※"   # U+203B REFERENCE MARK — "this entity speaks"
    TIER_ICON="✦"      # U+2726 BLACK FOUR-POINTED STAR
    BOLT_ICON="⚡"     # U+26A1 HIGH VOLTAGE SIGN (text-presentation)
    TOPIC_ICON="▷"     # U+25B7 WHITE RIGHT-POINTING TRIANGLE
    BAR_FILL="▰"
    BAR_EMPTY="▱"
    SEP="·"
    ;;
  ascii)
    PERSONA_ICON=""    # bracketed letter handled inline ([E]/[C]/[V])
    TIER_ICON="^"
    BOLT_ICON="*"
    TOPIC_ICON=">"
    BAR_FILL="#"
    BAR_EMPTY="-"
    SEP="|"            # not "-" — would visually collide with bar's empty cells
    ;;
  *) # emoji default
    PERSONA_ICON="🎙"   # studio microphone — "voice"
    TIER_ICON="🏷"      # label/tag — tier badge
    BOLT_ICON="⚡"      # high voltage — cycles
    TOPIC_ICON="📖"     # open book — topic
    BAR_FILL="▰"
    BAR_EMPTY="▱"
    SEP="·"
    ;;
esac

# Emoji are full-width in most terminals (2 columns of display, 1 char of
# string length), so a single space after them reads as visually cramped.
# Pad with an extra space in emoji mode only; other modes stay tight.
if [ "$ICONS" = "emoji" ]; then
  ICON_PAD=" "
else
  ICON_PAD=""
fi

# --- color palette ---
# Persona colors picked for monochrome-readable contrast:
#   Echo   cyan        (calm, observational)
#   Cipher purple      (mysterious, puzzle-framed)
#   Vex    red-orange  (direct, pushy)
#   None   cool gray   (neutral instructor)
# Cycles warn when ≤1 (the next /tutor-start will be cycle-out).
if [ "$PLAIN_MODE" = "true" ]; then
  ACCENT=""
  ACCENT_BOLD=""
  DIM=""
  WARN=""
  RESET=""
else
  case "$PERSONA" in
    echo)   ACCENT=$'\033[38;5;87m'  ;;  # bright cyan
    cipher) ACCENT=$'\033[38;5;141m' ;;  # soft purple
    vex)    ACCENT=$'\033[38;5;208m' ;;  # red-orange
    *)      ACCENT=$'\033[38;5;110m' ;;  # cool gray-blue (no persona)
  esac
  ACCENT_BOLD=$'\033[1m'"$ACCENT"
  DIM=$'\033[38;5;240m'
  WARN=$'\033[38;5;220m'  # warm yellow (cycles low)
  RESET=$'\033[0m'
fi

# --- helpers ---
truncate_slug() {
  local slug="$1" ellipsis="$2"
  # SLUG_MAX_LEN=0 means no truncation. Any other value: truncate when
  # the string exceeds it. Validate that SLUG_MAX_LEN is a positive int
  # before applying; garbage values silently fall back to no truncation
  # rather than erroring.
  if ! [[ "$SLUG_MAX_LEN" =~ ^[0-9]+$ ]]; then
    printf "%s" "$slug"; return
  fi
  if [ "$SLUG_MAX_LEN" -eq 0 ] || [ "${#slug}" -le "$SLUG_MAX_LEN" ]; then
    printf "%s" "$slug"
  else
    printf "%s%s" "${slug:0:$SLUG_MAX_LEN}" "$ellipsis"
  fi
}

persona_label() {
  # Persona name styling per mode. In ASCII mode we use bracketed letters
  # so the row works in any terminal; in other modes we use the persona
  # icon + the persona's name (or "tutor" when no persona is selected).
  local p="${PERSONA:-tutor}"
  local upper="$(printf "%s" "$p" | tr '[:lower:]' '[:upper:]')"
  if [ "$ICONS" = "ascii" ]; then
    if [ -n "$PERSONA" ]; then
      printf "[%s] %s" "${upper:0:1}" "$upper"
    else
      printf "[T] TUTOR"
    fi
  else
    printf "%s%s %s" "$PERSONA_ICON" "$ICON_PAD" "$upper"
  fi
}

cycles_block() {
  # Color cycles by remaining balance: warn when ≤1. The cap renders dim so
  # the eye focuses on the live number, not the constant. The glyph-to-text
  # gap matches the rest of the row (ICON_PAD widens it in emoji mode).
  local color="$ACCENT"
  if [ "$CYCLES" -le 1 ] && [ -n "$WARN" ]; then color="$WARN"; fi
  printf "%s%s%s %d%s%s/%d%s" \
    "$color" "$BOLT_ICON" "$ICON_PAD" "$CYCLES" "$RESET" "$DIM" "$CYCLES_CAP" "$RESET"
}

# Plain ellipsis for ASCII, single-codepoint … for everything else.
[ "$ICONS" = "ascii" ] && ELLIPSIS="..." || ELLIPSIS="…"

# Build a styled 5-cell bar: filled cells in accent, empty cells in dim.
# Only emit the accent prefix when there's actually a filled portion (avoids
# a stray no-op ANSI escape when filled=0).
styled_bar() {
  local filled=$1 i out=""
  if [ "$filled" -gt 0 ]; then
    out+="$ACCENT"
    for (( i=0; i<filled; i++ )); do out+="$BAR_FILL"; done
  fi
  if [ "$filled" -lt 5 ]; then
    out+="$DIM"
    for (( i=filled; i<5; i++ )); do out+="$BAR_EMPTY"; done
  fi
  out+="$RESET"
  printf "%s" "$out"
}

# --- assemble the row ---
# Layout:
#   <persona-label>  ·  <tier-icon> <Tier> <xp-bar>  ·  <bolt> <N>/<cap>  ·  <topic-icon> <slug> <concept-bar>
#
# Persona label is bold accent. Tier name is bold accent. Bars use accent
# for filled, dim for empty. Cycles glow yellow when ≤1. Topic slug is dim
# (it's auxiliary context — the bar is the live signal).
xp_bar_styled=$(styled_bar "$xp_bar_filled")
concept_bar_styled=$(styled_bar "$concept_bar_filled")
sep="${DIM} ${SEP} ${RESET}"

# Build the row segment-by-segment.
out=""
out+="${ACCENT_BOLD}$(persona_label)${RESET}"
out+="${sep}"
out+="${ACCENT}${TIER_ICON}${RESET}${ICON_PAD} ${ACCENT_BOLD}${TIER_NAME}${RESET} ${xp_bar_styled}"
out+="${sep}"
out+="$(cycles_block)"

if [ -n "$ACTIVE_TOPIC" ]; then
  slug_disp=$(truncate_slug "$ACTIVE_DISPLAY" "$ELLIPSIS")
  out+="${sep}"
  out+="${ACCENT}${TOPIC_ICON}${RESET}${ICON_PAD} ${DIM}${slug_disp}${RESET} ${concept_bar_styled}"
fi

# --- separator rule when appended below another statusline ---
# The wrapper sets LLM_TUTOR_APPENDED=1 when there's an original statusline
# above us. We emit a dim full-width horizontal rule on its own line above
# the segment so the user's eye registers "this is a separate section"
# rather than "row 3 of the same statusline."
if [ -n "${LLM_TUTOR_APPENDED:-}" ]; then
  # Width detection: $COLUMNS isn't always exported; tput cols is the
  # reliable fallback. 80 is the last resort. The rule character is mode-
  # aware so ASCII-mode users don't see broken UTF-8.
  width="${COLUMNS:-}"
  if ! [[ "$width" =~ ^[0-9]+$ ]] || [ "$width" -le 0 ]; then
    width=$(tput cols 2>/dev/null || echo 80)
  fi
  case "$ICONS" in
    ascii) rule_char="-" ;;
    *)     rule_char="─" ;;  # U+2500 BOX DRAWINGS LIGHT HORIZONTAL
  esac
  rule=""
  for (( i=0; i<width; i++ )); do rule="${rule}${rule_char}"; done
  printf "%s%s%s\n%s" "$DIM" "$rule" "$RESET" "$out"
else
  printf "%s" "$out"
fi

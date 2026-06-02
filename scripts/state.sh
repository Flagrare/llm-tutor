#!/usr/bin/env bash
# state.sh — read/write helper for llm-tutor's state.json
#
# Resolves the state file path from $CLAUDE_PLUGIN_DATA (set by Claude Code
# when running inside the plugin context) or falls back to
# $HOME/.claude/llm-tutor/state.json for development/testing.
#
# Usage:
#   state.sh init                       Create empty state file if missing.
#   state.sh path                       Print resolved state file path.
#   state.sh get <jq-path>              Read any JSON path. Example: state.sh get .user.xp
#   state.sh set <jq-path> <value>      Write any path (atomic). Value parsed as JSON.
#   state.sh add <jq-path> <delta>      Add a number to a numeric path.
#   state.sh maybe-init-topic <slug>    Create topic entry if missing.
#   state.sh refill-cycles              Refill cycles to cap if a day has passed.
#
# Examples:
#   state.sh get .user.xp
#   state.sh set .user.xp 1290
#   state.sh add .user.xp 50
#   state.sh add .user.cycles -1            # spend a cycle
#   state.sh set '.topics["python-decorators"].status' '"in_progress"'
#   state.sh maybe-init-topic "python-decorators"
#   state.sh refill-cycles
#
# Requires: jq, GNU date or BSD date.

set -euo pipefail

STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/llm-tutor}"
STATE_FILE="$STATE_DIR/state.json"
SCHEMA_VERSION=1

# Cross-platform UTC ISO 8601 timestamp (matches existing repo convention).
now_iso() {
  if date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null | grep -q T; then
    date -u +%Y-%m-%dT%H:%M:%SZ
  else
    # macOS BSD date fallback (same flag works actually, but kept defensive)
    date -u "+%Y-%m-%dT%H:%M:%SZ"
  fi
}

# Initial state document. Schema version + empty user defaults + empty topics.
seed_state_json() {
  local now
  now=$(now_iso)
  jq -n --argjson v "$SCHEMA_VERSION" --arg now "$now" '{
    schema_version: $v,
    user: {
      xp: 0,
      cycles: 5,
      cycles_cap: 5,
      cycles_last_reset: $now
    },
    topics: {}
  }'
}

# Atomic write: write to .tmp in the same directory, then rename.
# Avoids torn reads if multiple hooks/skills write concurrently.
write_state() {
  local content="$1"
  mkdir -p "$STATE_DIR"
  local tmp="${STATE_FILE}.tmp.$$"
  printf '%s\n' "$content" > "$tmp"
  mv "$tmp" "$STATE_FILE"
}

ensure_initialized() {
  if [ ! -f "$STATE_FILE" ]; then
    write_state "$(seed_state_json)"
  fi
}

# Subcommand: init
cmd_init() {
  if [ -f "$STATE_FILE" ]; then
    echo "state already initialized at $STATE_FILE" >&2
    return 0
  fi
  write_state "$(seed_state_json)"
  echo "initialized: $STATE_FILE"
}

# Subcommand: path
cmd_path() {
  echo "$STATE_FILE"
}

# Subcommand: get <jq-path>
cmd_get() {
  ensure_initialized
  jq -r "$1" "$STATE_FILE"
}

# Subcommand: set <jq-path> <value>
# Value is parsed as JSON: numbers are numbers, strings need quotes ("foo"),
# objects need braces ({"a": 1}). Pass strings as '"foo"' to be safe.
cmd_set() {
  ensure_initialized
  local path="$1" value="$2"
  local new
  new=$(jq --argjson v "$value" "$path = \$v" "$STATE_FILE")
  write_state "$new"
}

# Subcommand: add <jq-path> <delta>
# Delta can be negative (spend a cycle: add .user.cycles -1).
cmd_add() {
  ensure_initialized
  local path="$1" delta="$2"
  local new
  new=$(jq --argjson d "$delta" "$path = (($path // 0) + \$d)" "$STATE_FILE")
  write_state "$new"
}

# Subcommand: maybe-init-topic <slug>
# Creates an empty topic entry if it doesn't already exist. Idempotent.
cmd_maybe_init_topic() {
  ensure_initialized
  local slug="$1"
  local exists
  exists=$(jq -r --arg s "$slug" '.topics[$s] // null' "$STATE_FILE")
  if [ "$exists" != "null" ]; then
    return 0
  fi
  local now
  now=$(now_iso)
  local new
  new=$(jq --arg s "$slug" --arg now "$now" '.topics[$s] = {
    status: "in_progress",
    started_at: $now,
    current_concept_index: 0,
    cycles_paid: false,
    calibration: null,
    concepts: [],
    feedback_log: []
  }' "$STATE_FILE")
  write_state "$new"
}

# Subcommand: refill-cycles
# If a day has passed since cycles_last_reset, refill cycles to cycles_cap.
# Uses epoch comparison for cross-platform safety.
cmd_refill_cycles() {
  ensure_initialized
  local last_reset cap now_epoch last_epoch
  last_reset=$(jq -r '.user.cycles_last_reset' "$STATE_FILE")
  cap=$(jq -r '.user.cycles_cap' "$STATE_FILE")
  now_epoch=$(date -u +%s)

  # Parse ISO 8601 to epoch (BSD/GNU compatible attempt).
  if [[ "$(uname -s)" == "Darwin" ]]; then
    last_epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$last_reset" +%s 2>/dev/null || echo 0)
  else
    last_epoch=$(date -u -d "$last_reset" +%s 2>/dev/null || echo 0)
  fi

  local elapsed=$(( now_epoch - last_epoch ))
  if [ "$elapsed" -ge 86400 ]; then
    local now_iso_str
    now_iso_str=$(now_iso)
    local new
    new=$(jq --argjson cap "$cap" --arg now "$now_iso_str" '.user.cycles = $cap | .user.cycles_last_reset = $now' "$STATE_FILE")
    write_state "$new"
    echo "refilled: cycles=$cap last_reset=$now_iso_str"
  fi
}

# Dispatch
main() {
  if [ $# -eq 0 ]; then
    grep -E "^#( |$)" "$0" | sed 's/^# \{0,1\}//'
    exit 0
  fi
  local cmd="$1"; shift
  case "$cmd" in
    init)              cmd_init "$@" ;;
    path)              cmd_path "$@" ;;
    get)               cmd_get "$@" ;;
    set)               cmd_set "$@" ;;
    add)               cmd_add "$@" ;;
    maybe-init-topic)  cmd_maybe_init_topic "$@" ;;
    refill-cycles)     cmd_refill_cycles "$@" ;;
    *)
      echo "unknown subcommand: $cmd" >&2
      echo "run \`$0\` (no args) for usage" >&2
      exit 2
      ;;
  esac
}

main "$@"

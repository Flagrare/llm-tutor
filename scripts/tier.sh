#!/usr/bin/env bash
# tier.sh — XP → tier name + index mapping for llm-tutor.
#
# Single source of truth for the 10-tier system. Other skills (tutor-status,
# tutor-done) call into this rather than duplicating the table.
#
# Tier philosophy: titles tell the story of *becoming less dependent on the
# tutor*. The terminal tier ("Self-Hosting") explicitly names the design
# victory — the tutor has worked itself out of a job.
#
# Tiers and thresholds:
#   1.  Greenhorn      0 XP    (Arrive)
#   2.  Booted         75 XP   (Arrive)
#   3.  Patched        200 XP  (Build)
#   4.  Linked         400 XP  (Build)
#   5.  Wired          650 XP  (Build)
#   6.  Threaded       950 XP  (Synthesize)
#   7.  Synced         1300 XP (Synthesize)
#   8.  Forking        1800 XP (Separate)
#   9.  Decoupled      2500 XP (Separate)
#   10. Self-Hosting   3500 XP (Separate)
#
# Usage:
#   tier.sh name <xp>    → prints tier name (e.g., "Wired")
#   tier.sh index <xp>   → prints tier index (e.g., 5)
#   tier.sh all <xp>     → prints "index|name" (e.g., "5|Wired")
#   tier.sh next <xp>    → prints "next_tier_name|xp_needed_to_reach_it"
#                          if not at max; prints "max" if already there
#   tier.sh table        → prints the full tier table for display

set -euo pipefail

# Tier table: index|name|min_xp
# Edit here to change tier names or thresholds. Everything downstream
# (tutor-status, tutor-done) reads from this single source.
TIERS=(
  "1|Greenhorn|0"
  "2|Booted|75"
  "3|Patched|200"
  "4|Linked|400"
  "5|Wired|650"
  "6|Threaded|950"
  "7|Synced|1300"
  "8|Forking|1800"
  "9|Decoupled|2500"
  "10|Self-Hosting|3500"
)

xp_to_tier() {
  local xp=$1
  local result_idx=1
  local result_name="Greenhorn"
  for tier in "${TIERS[@]}"; do
    IFS='|' read -r idx name min_xp <<< "$tier"
    if [ "$xp" -ge "$min_xp" ]; then
      result_idx=$idx
      result_name=$name
    fi
  done
  echo "$result_idx|$result_name"
}

cmd_name()  { xp_to_tier "$1" | cut -d'|' -f2; }
cmd_index() { xp_to_tier "$1" | cut -d'|' -f1; }
cmd_all()   { xp_to_tier "$1"; }

cmd_next() {
  local xp=$1
  local current_idx
  current_idx=$(xp_to_tier "$xp" | cut -d'|' -f1)
  if [ "$current_idx" -ge 10 ]; then
    echo "max"
    return
  fi
  local next_idx=$((current_idx + 1))
  for tier in "${TIERS[@]}"; do
    IFS='|' read -r idx name min_xp <<< "$tier"
    if [ "$idx" = "$next_idx" ]; then
      local needed=$((min_xp - xp))
      echo "$name|$needed"
      return
    fi
  done
}

cmd_table() {
  for tier in "${TIERS[@]}"; do
    IFS='|' read -r idx name min_xp <<< "$tier"
    printf "  %2d. %-14s %5d XP\n" "$idx" "$name" "$min_xp"
  done
}

main() {
  if [ $# -eq 0 ]; then
    grep -E "^#( |$)" "$0" | sed 's/^# \{0,1\}//'
    exit 0
  fi
  local cmd="$1"; shift
  case "$cmd" in
    name)  cmd_name "$@" ;;
    index) cmd_index "$@" ;;
    all)   cmd_all "$@" ;;
    next)  cmd_next "$@" ;;
    table) cmd_table ;;
    *) echo "unknown subcommand: $cmd" >&2; exit 2 ;;
  esac
}

main "$@"

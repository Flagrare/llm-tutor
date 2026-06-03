---
name: tutor-status
description: "Show the llm-tutor dashboard — XP total, cycles balance with time-until-next-refill, active topics with progress, completed topics with XP earned, and lifetime stats. Invoke with no arguments. Triggers: '/tutor-status', 'show me my tutor status', 'how am I doing', 'check my XP', 'where am I at with the tutor'."
---

# Tutor Status

The dashboard reader for llm-tutor. Shows the user's current state at a glance — XP, cycles, what they're working on, what they've finished.

This skill is read-only — it doesn't modify state, doesn't charge cycles, doesn't reward feedback. It just queries `state.json` and renders a formatted overview.

---

## Step 0 — Defensive setup

```bash
STATE="$CLAUDE_PLUGIN_ROOT/scripts/state.sh"

# Ensure state file exists (idempotent — no-op if already initialized)
bash "$STATE" init >/dev/null

# Refill cycles if daily reset is due (defensive — the hook should have
# done this, but doesn't hurt to be sure on a status query)
bash "$STATE" refill-cycles >/dev/null 2>&1 || true
```

---

## Step 1 — Read the pieces

```bash
XP=$(bash "$STATE" get .user.xp)
CYCLES=$(bash "$STATE" get .user.cycles)
CYCLES_CAP=$(bash "$STATE" get .user.cycles_cap)
LAST_RESET=$(bash "$STATE" get .user.cycles_last_reset)

# Current tier + progress toward next tier
TIER="$CLAUDE_PLUGIN_ROOT/scripts/tier.sh"
TIER_NAME=$(bash "$TIER" name "$XP")
TIER_INDEX=$(bash "$TIER" index "$XP")
NEXT=$(bash "$TIER" next "$XP")
# NEXT is either "max" or "<name>|<xp_needed>"

# Topic counts
TOPICS_JSON=$(bash "$STATE" get .topics)
ACTIVE_TOPICS=$(echo "$TOPICS_JSON" | jq 'to_entries | map(select(.value.status == "in_progress"))')
COMPLETED_TOPICS=$(echo "$TOPICS_JSON" | jq 'to_entries | map(select(.value.status == "completed"))')

ACTIVE_COUNT=$(echo "$ACTIVE_TOPICS" | jq 'length')
COMPLETED_COUNT=$(echo "$COMPLETED_TOPICS" | jq 'length')
```

---

## Step 2 — Compute time until next cycles refill

The cycles hook refills 24 hours after `cycles_last_reset`. Compute the remaining time.

```bash
NOW_EPOCH=$(date -u +%s)
if [[ "$(uname -s)" == "Darwin" ]]; then
  LAST_EPOCH=$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_RESET" +%s 2>/dev/null || echo 0)
else
  LAST_EPOCH=$(date -u -d "$LAST_RESET" +%s 2>/dev/null || echo 0)
fi

ELAPSED=$((NOW_EPOCH - LAST_EPOCH))
REMAINING=$((86400 - ELAPSED))

if [ "$REMAINING" -le 0 ]; then
  REFILL_TEXT="due now"
else
  HOURS=$((REMAINING / 3600))
  MINS=$(( (REMAINING % 3600) / 60 ))
  if [ "$HOURS" -gt 0 ]; then
    REFILL_TEXT="next refill in ${HOURS}h ${MINS}m"
  else
    REFILL_TEXT="next refill in ${MINS}m"
  fi
fi
```

---

## Step 3 — Render the dashboard

The output structure:

```
llm-tutor status

XP:     $XP
Cycles: $CYCLES / $CYCLES_CAP     ($REFILL_TEXT)

Active topics ($ACTIVE_COUNT):
  → slug-1                  progress: N/M concepts acquired
  → slug-2                  progress: N/M concepts acquired

Completed topics ($COMPLETED_COUNT):
  ✓ slug-1                  +N XP   (YYYY-MM-DD)
  ✓ slug-2                  +N XP   (YYYY-MM-DD)
```

### Header

```bash
echo "llm-tutor status"
echo

# Tier line: "Tier 6: Threaded   (350 XP to Synced)" or "Tier 10: Self-Hosting   (max)"
if [ "$NEXT" = "max" ]; then
  printf "Tier %s: %s     (max)\n" "$TIER_INDEX" "$TIER_NAME"
else
  NEXT_NAME=$(echo "$NEXT" | cut -d'|' -f1)
  NEXT_NEEDED=$(echo "$NEXT" | cut -d'|' -f2)
  printf "Tier %s: %s     (%s XP to %s)\n" "$TIER_INDEX" "$TIER_NAME" "$NEXT_NEEDED" "$NEXT_NAME"
fi
printf "XP:     %s\n" "$XP"
printf "Cycles: %s / %s     (%s)\n" "$CYCLES" "$CYCLES_CAP" "$REFILL_TEXT"
echo
```

### Active topics

```bash
echo "Active topics ($ACTIVE_COUNT):"

if [ "$ACTIVE_COUNT" -eq 0 ]; then
  echo "  (none — run /tutor-start <subject> to begin one)"
else
  echo "$ACTIVE_TOPICS" | jq -r '.[] |
    "  → \(.key)|\(.value.concepts | map(select(.status == "acquired")) | length)/\(.value.concepts | length)"' | \
  while IFS='|' read -r line acquired_total; do
    printf "  %-32s progress: %s concepts acquired\n" "$line" "$acquired_total"
  done
fi
echo
```

Wait — that pipe-and-while pattern won't render the `→` prefix nicely. Let me restructure: extract slug + acquired + total via jq, then format in the loop.

```bash
echo "Active topics ($ACTIVE_COUNT):"
if [ "$ACTIVE_COUNT" -eq 0 ]; then
  echo "  (none — run /tutor-start <subject> to begin one)"
else
  echo "$ACTIVE_TOPICS" | jq -r '.[] |
    "\(.key)|\(.value.concepts | map(select(.status == "acquired")) | length)|\(.value.concepts | length)"' | \
  while IFS='|' read -r slug acquired total; do
    printf "  → %-30s progress: %s/%s concepts acquired\n" "$slug" "$acquired" "$total"
  done
fi
echo
```

### Completed topics

```bash
echo "Completed topics ($COMPLETED_COUNT):"
if [ "$COMPLETED_COUNT" -eq 0 ]; then
  echo "  (none yet)"
else
  echo "$COMPLETED_TOPICS" | jq -r '.[] |
    "\(.key)|\(.value.xp_earned_total // 0)|\(.value.completed_at // "?")"' | \
  while IFS='|' read -r slug xp completed_at; do
    # Truncate ISO timestamp to date only
    completed_date="${completed_at%%T*}"
    printf "  ✓ %-30s +%s XP   (%s)\n" "$slug" "$xp" "$completed_date"
  done
fi
echo
```

### Lifetime stats (optional one-liner)

If at least one topic completed, show the totals:

```bash
if [ "$COMPLETED_COUNT" -gt 0 ]; then
  LIFETIME_XP=$(echo "$COMPLETED_TOPICS" | jq '[.[].value.xp_earned_total // 0] | add')
  FEEDBACK_COUNT=$(echo "$COMPLETED_TOPICS" | jq '[.[].value.feedback_log[]?] | length')
  echo "Lifetime: $COMPLETED_COUNT topics done, $LIFETIME_XP XP earned, $FEEDBACK_COUNT sessions with feedback."
fi
```

If no topics completed AND no active topics, show the cold-start message instead:

```bash
if [ "$COMPLETED_COUNT" -eq 0 ] && [ "$ACTIVE_COUNT" -eq 0 ]; then
  echo "No topics yet — run /tutor-start <subject> to begin."
fi
```

---

## Hard rules

1. **Read-only.** This skill never modifies state. The defensive `init` and `refill-cycles` calls in Step 0 are state.sh's responsibility — they're idempotent and write only when truly required.
2. **No persona voice.** Render the dashboard, don't editorialize. Don't say "Nice progress!" or "Keep it up!" — that's not what a status command does.
3. **Truncate ISO dates to date-only for display.** `2026-05-28T14:30:00Z` → `2026-05-28`. Time-of-day clutters the table.
4. **Preserve column alignment.** Use `%-30s` style padding so slugs line up; otherwise the dashboard reads as ragged.
5. **Show the cycles refill ETA always.** Even when cycles is at cap. The user might want to know "the cap is already at 5, so I have 5 to spend right now, and the next reset is in Xh."

---

## Edge cases

- **No state file at all** (user has never invoked any /tutor-* command) → Step 0's `init` creates an empty one. Status shows XP=0, cycles=5/5, no topics. That's fine.
- **`cycles_last_reset` malformed** → `LAST_EPOCH` defaults to 0, `REMAINING` becomes huge negative, "due now" displays. Acceptable degradation.
- **A topic exists but its `concepts` array is empty** (failed `/tutor-start`) → `progress: 0/0 concepts acquired` displays. Not pretty but honest. User can re-run `/tutor-start` to repair.
- **A completed topic missing `xp_earned_total`** (pre-this-version state) → `// 0` fallback shows `+0 XP`. Mildly weird but not broken.
- **A completed topic missing `completed_at`** → `?` shows. Acceptable.
